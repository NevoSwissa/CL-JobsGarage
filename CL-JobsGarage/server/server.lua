local QBCore = exports['qb-core']:GetCoreObject()

function HasPermission(job, gang)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local hasJob = false
    local hasGang = false
    if type(job) == "table" then
        for _, j in ipairs(job) do
            if Player.PlayerData.job.name == j then
                hasJob = true
                break
            end
        end
    elseif job == "all" or Player.PlayerData.job.name == job then
        hasJob = true
    end
    if type(gang) == "table" then
        for _, g in ipairs(gang) do
            if Player.PlayerData.gang.name == g then
                hasGang = true
                break
            end
        end
    elseif gang == "all" or Player.PlayerData.gang.name == gang then
        hasGang = true
    end
    return hasJob or hasGang
end

function IsVehicleAllowed(sellList, vehicle)
    for k, v in pairs(sellList) do
        if v.Vehicle == vehicle then
            return true
        end
    end
    return false
end

function GetVehicleTrunkItems(vehicles, vehicle)
    for _, v in ipairs(vehicles) do
        if v.Vehicle == vehicle then
            return v.VehicleSettings['TrunkItems'] or nil
        end
    end
    return nil
end

function CheckForMissingVehicles()
    local result = MySQL.Sync.fetchAll("SELECT vehicleinfo FROM cl_jobsgarage WHERE status = 0")
    if result then
        for _, v in ipairs(result) do
            local vehicleInfo = json.decode(v.vehicleinfo)
            local plate = vehicleInfo.plate
            if FindVehicleByPlate(plate) then
                goto skip
            end
            if not FindVehicleByPlate(plate) then
                MySQL.Sync.execute("UPDATE cl_jobsgarage SET status = 2 WHERE vehicleinfo LIKE @plate AND status = 0", {["@plate"] = '%"plate":"' .. plate .. '"%'})
            end
            ::skip::
        end
    end
end

function FindVehicleByPlate(plate)
    local vehicles = GetAllVehicles()
    for i = 1, #vehicles do
        local vehicle = vehicles[i]
        local vehiclePlate = GetVehicleNumberPlateText(vehicle)
        if trim(vehiclePlate) == trim(plate) then
            return vehicle
        end
    end
    return false
end

function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(100)
        if Config.AutoRespawn then 
            MySQL.Async.execute('UPDATE cl_jobsgarage SET status = 1 WHERE status IN (0, 3)', {})
        else 
            MySQL.Async.execute('UPDATE cl_jobsgarage SET status = 1 WHERE status = 3', {})
            CheckForMissingVehicles()
        end
    end
end)

AddEventHandler("playerConnecting", function()
    if Config.AutoRespawn then 
        MySQL.Async.execute('UPDATE cl_jobsgarage SET status = 1 WHERE status IN (0, 3)', {})
    else 
        MySQL.Async.execute('UPDATE cl_jobsgarage SET status = 1 WHERE status = 3', {})
        CheckForMissingVehicles()
    end
end)

RegisterServerEvent("CL-PoliceGarageV2:GetData", function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Config.BanWhenExploit and not HasPermission(data.rjob, data.rgang) then ExploitBan(src, 'Banned for exploiting') end
    if data.type == "availablevehicles" or data.type == "vehicledepot" then
        CheckForMissingVehicles()
        MySQL.Async.fetchAll("SELECT * FROM cl_jobsgarage WHERE citizenid = @citizenid AND station = @station", { ['@citizenid'] = Player.PlayerData.citizenid, ['@station'] = data.station }, function(result)
            local vehicles = {}
            local anyVehicles = false
            for i = 1, #result do
                local vehicleinfo = json.decode(result[i].vehicleinfo) or {}
                if data.type ~= "vehicledepot" then
                    if result[i].status == 1 and IsVehicleAllowed(data.selllist, result[i].vehicle) then
                        anyVehicles = true
                        table.insert(vehicles, {
                            vehicle = result[i].vehicle,
                            mods = result[i].mods,
                            status = result[i].status,
                            trunkitems = GetVehicleTrunkItems(data.selllist, result[i].vehicle),
                            vehicleinfo = vehicleinfo,
                        })
                    elseif result[i].status == 3 and IsVehicleAllowed(data.selllist, result[i].vehicle) then
                        anyVehicles = true
                        table.insert(vehicles, {
                            vehicle = result[i].vehicle,
                            mods = result[i].mods,
                            status = result[i].status,
                            trunkitems = GetVehicleTrunkItems(data.selllist, result[i].vehicle),
                            vehicleinfo = vehicleinfo,
                            id = result[i].id,
                            showcar = true,
                        })
                    end
                elseif result[i].status == 2 and IsVehicleAllowed(data.selllist, result[i].vehicle) then
                    anyVehicles = true
                    table.insert(vehicles, {
                        vehicle = result[i].vehicle,
                        mods = result[i].mods,
                        status = result[i].status,
                        vehicleinfo = vehicleinfo,
                        trunkitems = GetVehicleTrunkItems(data.selllist, result[i].vehicle),
                        deleted = true
                    })
                elseif data.type == "vehicledepot" and result[i].status == 0 and IsVehicleAllowed(data.selllist, result[i].vehicle) then
                    anyVehicles = true
                    table.insert(vehicles, {
                        vehicle = result[i].vehicle,
                        vehicleinfo = vehicleinfo,
                        locate = true
                    })
                end
            end
            if not anyVehicles then
                TriggerClientEvent('QBCore:Notify', src, Config.Locals["Notifications"]['GarageNotifications']["NoVehicles"] .. data.station, "error")
                return
            end
            local depot = data.type == "vehicledepot" and "vehicledepot" or nil
            local data = {
                job = data.rjob,
                gang = data.rgang,
                coordsinfo = data.coordsinfo,
                station = data.station,
                purchasablevehicles = data.selllist,
                vehicledepot = depot,
                vehicles = vehicles
            }
            TriggerClientEvent("CL-PoliceGarageV2:OpenVehiclesMenu", src, data)
        end)
    else
        ExploitBan(src, 'Banned for exploiting')
    end
end)

RegisterServerEvent("CL-PoliceGarageV2:AddData", function(type, vehicle, plate, job, gang, station, body, engine, fuel, mods, selllist, status)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Config.BanWhenExploit and not HasPermission(job, gang) then ExploitBan(src, 'Banned for exploiting') end
    if type == "vehiclepurchased" then
        local data = {
            plate = plate,
            engine = body,
            body = engine,
            fuel = fuel,
        }
        MySQL.insert('INSERT INTO cl_jobsgarage (citizenid, vehicle, station, mods, vehicleinfo, status) VALUES (?, ?, ?, ?, ?, ?)', {
            Player.PlayerData.citizenid,
            vehicle,
            station,
            '{}',
            json.encode(data),
            0,
        })
    elseif type == "storevehicle" then
        MySQL.Async.fetchAll("SELECT * FROM cl_jobsgarage WHERE station = @station AND vehicleinfo LIKE @plate", { 
            ['@station'] = station,
            ['@plate'] = "%" .. plate .. "%"
        }, function(result)
            if result[1] then
                if result[1].status == 0 then
                    if result[1].citizenid == Player.PlayerData.citizenid and IsVehicleAllowed(selllist, result[1].vehicle) then
                        local id = result[1].id
                        local vehicleinfo = json.encode({
                            engine = engine,
                            body = body,
                            fuel = fuel,
                            plate = plate,
                        })
                        local modsJson = json.encode(mods)
                        MySQL.Async.execute("UPDATE cl_jobsgarage SET vehicleinfo = @vehicleinfo, mods = @mods, status = @status WHERE id = @id", {
                            ['@vehicleinfo'] = vehicleinfo,
                            ['@mods'] = modsJson,
                            ['@status'] = status,
                            ['@id'] = id
                        }, function(rowsChanged)
                            if rowsChanged > 0 then
                                TriggerClientEvent('QBCore:Notify', src, Config.Locals["Notifications"]['GarageNotifications']["SuccessfullyStored"] .. station, 'success')
                            else
                                TriggerClientEvent('QBCore:Notify', src, Config.Locals["Notifications"]['GarageNotifications']["ErrorStoring"], 'error')
                            end
                        end)
                    else
                        TriggerClientEvent('QBCore:Notify', src, Config.Locals["Notifications"]['GarageNotifications']["ErrorStoring"], 'error')
                        return
                    end
                end
            else
                TriggerClientEvent('QBCore:Notify', src, Config.Locals["Notifications"]['GarageNotifications']["ErrorStoring"], 'error')
            end
        end)
    else
        ExploitBan(src, 'Banned for exploiting')
    end
end)

RegisterServerEvent('CL-PoliceGarageV2:RentVehicle', function(paymenttype, finalPrice, vehiclename, vehicle, time, coordsinfo, job, gang, station)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    if Config.BanWhenExploit and not HasPermission(job, gang) then ExploitBan(src, 'Banned for exploiting') end
    if Player.Functions.GetMoney(paymenttype) >= finalPrice then
        TriggerClientEvent("CL-PoliceGarageV2:SpawnRentedVehicle", src, vehicle, vehiclename, finalPrice, time, os.time(), coordsinfo['VehicleSpawn'], paymenttype, job, gang, station)  
        Player.Functions.RemoveMoney(paymenttype, finalPrice)
        TriggerClientEvent('QBCore:Notify', src, vehiclename .. Config.Locals["Notifications"]['RentNotifications']["SuccessfullyRented"] .. time .. " minutes", "success")  
        if Config.UseLogs then TriggerEvent("qb-log:server:CreateLog", "default", GetCurrentResourceName(), "blue", 'New vehicle rented by: **'..GetPlayerName(src)..'** Player ID: **' ..src.. '** Rented: **' ..vehiclename.. '** For: **' ..finalPrice.. '$**'..' Rented for: **'..time .. '** minutes', false) end
    else
        TriggerClientEvent('QBCore:Notify', src, Config.Locals["Notifications"]['GeneralNotifications']["NoMoney"], "error")              
    end    
end)

RegisterServerEvent('CL-PoliceGarageV2:BuyVehicle', function(data)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    if Config.BanWhenExploit and not HasPermission(data.job, data.gang) then ExploitBan(src, 'Banned for exploiting') end
    if data.paymenttype == "company" and Config.CompanyFunds['Enable'] then
        local Reciever = QBCore.Functions.GetPlayer(data.id)
        if Reciever.PlayerData.job.name == Player.PlayerData.job.name then
            if Reciever.PlayerData.job.grade.level >= data.rank then
                local account = exports['qb-management']:GetAccount(Player.PlayerData.job.name)
                if account >= data.price then
                    exports['qb-management']:RemoveMoney(Player.PlayerData.job.name, data.price)
                    TriggerClientEvent('QBCore:Notify', data.buyer, "You have successfully purchased " .. data.vehiclename .. " for " .. data.name .. " using the company funds from " .. account, "success")  
                    TriggerClientEvent('QBCore:Notify', data.id, data.vehiclename .. Config.Locals["Notifications"]['GeneralNotifications']["SuccessfullyBought"] .. data.station .. " garage", "success")  
                    TriggerClientEvent("CL-PoliceGarageV2:SpawnPurchasedVehicle", data.id, data.vehicle, data.vehiclename, data.coordsinfo['VehicleSpawn'], data.coordsinfo['CheckRadius'], data.job, data.gang, data.useownable, data.trunkitems, data.extras, data.liveries, data.colors, data.station)
                else
                    TriggerClientEvent('QBCore:Notify', data.buyer, Config.Locals['Notifications']['GeneralNotifications']['NoFunds'] .. data.vehiclename .. " money available " .. account, "error")  
                end
            else
                TriggerClientEvent('QBCore:Notify', data.buyer, GetPlayerName(data.id) .. Config.Locals['Notifications']['GeneralNotifications']['NoRank'], "error")  
            end
        else
            TriggerClientEvent('QBCore:Notify', data.buyer, GetPlayerName(data.id) .. Config.Locals['Notifications']['GeneralNotifications']['NoJob'], "error")  
        end
    else
        if Player.Functions.GetMoney(data.paymenttype) >= data.price then
            TriggerClientEvent("CL-PoliceGarageV2:SpawnPurchasedVehicle", src, data.vehicle, data.vehiclename, data.coordsinfo['VehicleSpawn'], data.coordsinfo['CheckRadius'], data.job, data.gang, data.useownable, data.trunkitems, data.extras, data.liveries, data.colors, data.station)  
            Player.Functions.RemoveMoney(data.paymenttype, data.price)
            TriggerClientEvent('QBCore:Notify', src, data.vehiclename .. Config.Locals["Notifications"]['GeneralNotifications']["SuccessfullyBought"] .. data.station .. " garage", "success")  
            if Config.UseLogs then TriggerEvent("qb-log:server:CreateLog", "default", GetCurrentResourceName(), "blue", 'New vehicle purchased by: **'..GetPlayerName(src)..'** Player ID: **' ..src.. '** Bought: **' ..data.vehiclename.. '** For: **' ..data.price.. '$**'..' Station rented at: **'..data.station..'**', false) end
        else
            TriggerClientEvent('QBCore:Notify', src, Config.Locals["Notifications"]['GeneralNotifications']["NoMoney"], "error")              
        end  
    end
end)

RegisterServerEvent('CL-PoliceGarageV2:RefundRent', function(paymenttype, refund, clientsource, job, gang)
	local src = source
	local Player = QBCore.Functions.GetPlayer(clientsource)
    if Config.BanWhenExploit and not HasPermission(job, gang) then ExploitBan(src, 'Banned for exploiting') end
    if clientsource == src then
        Player.Functions.AddMoney(paymenttype, refund)
    else
        ExploitBan(src, 'Banned for exploiting')
    end
end)

QBCore.Functions.CreateCallback('CL-PoliceGarageV2:GetRealTime', function(source, cb)
    cb(os.time())
end)

-- Full credits to qb-garages creators
QBCore.Functions.CreateCallback('CL-PoliceGarageV2:SpawnVehicle', function(source, cb, data)
    local plate = data.vehicleinfo['plate']
    local fine = data.fine or 0
    if fine > 0 then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            if Player.Functions.RemoveMoney("cash", fine) then
                local veh = QBCore.Functions.SpawnVehicle(source, data.vehicle, data.coordsinfo['VehicleSpawn'], true)
                SetEntityHeading(veh, data.coordsinfo['VehicleSpawn'].w)
                local vehProps = {}
                local result = MySQL.query.await('SELECT mods FROM cl_jobsgarage WHERE vehicleinfo LIKE @plate', {["@plate"] = "%" .. plate .. "%"})
                if result[1] then vehProps = json.decode(result[1].mods) end
                local netId = NetworkGetNetworkIdFromEntity(veh)
                MySQL.Async.execute('UPDATE cl_jobsgarage SET status = @status WHERE vehicleinfo LIKE @plate', {["@status"] = 0, ["@plate"] = "%" .. plate .. "%"})
                cb({net = netId, mods = vehProps})
            else
                TriggerClientEvent('QBCore:Notify', source, Config.Locals['Notifications']['GeneralNotifications']['NoMoney'], "error")
            end
        end
    elseif data.showcar then
        local veh = QBCore.Functions.SpawnVehicle(source, data.vehicle, data.coords, true)
        SetEntityHeading(veh, data.coords.w)
        local vehProps = {}
        local result = MySQL.query.await('SELECT mods FROM cl_jobsgarage WHERE vehicleinfo LIKE @plate', {["@plate"] = "%" .. plate .. "%"})
        if result[1] then vehProps = json.decode(result[1].mods) end
        local netId = NetworkGetNetworkIdFromEntity(veh)
        MySQL.Async.execute('UPDATE cl_jobsgarage SET status = @status WHERE vehicleinfo LIKE @plate', {["@status"] = 0, ["@plate"] = "%" .. plate .. "%"})
        cb({net = netId, mods = vehProps})
    else
        local veh = QBCore.Functions.SpawnVehicle(source, data.vehicle, data.coordsinfo['VehicleSpawn'], true)
        SetEntityHeading(veh, data.coordsinfo['VehicleSpawn'].w)
        local vehProps = {}
        local result = MySQL.query.await('SELECT mods FROM cl_jobsgarage WHERE vehicleinfo LIKE @plate', {["@plate"] = "%" .. plate .. "%"})
        if result[1] then vehProps = json.decode(result[1].mods) end
        local netId = NetworkGetNetworkIdFromEntity(veh)
        MySQL.Async.execute('UPDATE cl_jobsgarage SET status = @status WHERE vehicleinfo LIKE @plate', {["@status"] = 0, ["@plate"] = "%" .. plate .. "%"})
        cb({net = netId, mods = vehProps})
    end
end)

QBCore.Functions.CreateCallback('CL-PoliceGarageV2:GetVehicle', function(source, cb, plate)
    local vehProps = {}
    local result = MySQL.query.await('SELECT mods, vehicle, id FROM cl_jobsgarage WHERE vehicleinfo LIKE @plate', {["@plate"] = "%" .. plate .. "%"})
    if result[1] then 
        vehProps = json.decode(result[1].mods)
    end
    cb({id = result[1].id, mods = vehProps, vehicle = result[1].vehicle})
end)

QBCore.Functions.CreateCallback('CL-PoliceGarageV2:GetStatus', function(source, cb, plate)
    local result = MySQL.Async.fetchAll('SELECT status FROM cl_jobsgarage WHERE status = 3 AND vehicleinfo LIKE @plate', {["@plate"] = "%" .. plate .. "%"})
    cb(result)
end)

QBCore.Functions.CreateCallback('CL-PoliceGarageV2:GetParkingVehicle', function(source, cb, parking)
    local parkedVehicles = {}
    for k, v in pairs(parking) do
        table.insert(parkedVehicles, {id = k, vehicle = v.vehicle})
        MySQL.Async.execute('UPDATE cl_jobsgarage SET status = @status WHERE id = @id AND status = 3', {["@status"] = 1, ["@id"] = k})
    end
    cb(parkedVehicles)
end)

QBCore.Functions.CreateCallback('CL-PoliceGarageV2:GetVehicleCoords', function(source, cb, plate)
    local vehicle = FindVehicleByPlate(plate)
    if not vehicle then
        cb(false)
    end
    local vehicleCoords = GetEntityCoords(vehicle)
    cb(vehicleCoords)
end)

QBCore.Functions.CreateCallback('CL-PoliceGarageV2:IsPlayerOwner', function(source, cb, station, plate, selllist)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local vehicleFound = false
    MySQL.Async.fetchAll("SELECT * FROM cl_jobsgarage WHERE station = @station AND vehicleinfo LIKE @plate", {
        ['@station'] = station,
        ['@plate'] = '%"plate":"' .. plate .. '"%',
    }, function(result)
        if result and #result > 0 then
            for i=1, #result do
                local vehicleinfo = json.decode(result[i].vehicleinfo)
                if IsVehicleAllowed(selllist, result[i].vehicle) then
                    if vehicleinfo and vehicleinfo['plate'] == plate then
                        if result[i].citizenid == Player.PlayerData.citizenid then
                            vehicleFound = true
                            break
                        end
                    end
                end
            end
        end
        cb(vehicleFound)
    end)
end)

function ExploitBan(id, reason)
	MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
		GetPlayerName(id),
		QBCore.Functions.GetIdentifier(id, 'license'),
		QBCore.Functions.GetIdentifier(id, 'discord'),
		QBCore.Functions.GetIdentifier(id, 'ip'),
		reason,
		2147483647,
		GetCurrentResourceName()
	})
	TriggerEvent('qb-log:server:CreateLog', 'bans', 'Player Banned', 'red', string.format('%s was banned by %s for %s', GetPlayerName(id), GetCurrentResourceName(), reason), true)
	DropPlayer(id, 'You were permanently banned by the server for: ' .. reason)
end