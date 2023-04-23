local QBCore = exports['qb-core']:GetCoreObject()

local PolicePeds = {}

local PlayerRentedVehicle = {}

local Parking = {}

local LocationBlips = {}

local PlayerData = {}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    SetScriptBlips()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    UpdateParkingVehicles()
    PlayerData = {}
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
    SetScriptBlips()
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate', function(GangInfo)
    PlayerData.gang = GangInfo
    SetScriptBlips()
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        PlayerData = QBCore.Functions.GetPlayerData()
        SetScriptBlips()
        local vehiclesRemoved = 0 
        for k, v in pairs(Config.Locations['Stations']) do
            if v.UsePolyZone and v.GeneralInformation['PolyZoneInformation']['ParkingCoords'] then
                local parkingSpots = v.GeneralInformation['PolyZoneInformation']['ParkingCoords']
                for i = 1, #parkingSpots do
                    local spotCoords = parkingSpots[i]
                    local vehicle = QBCore.Functions.GetClosestVehicle(vector3(spotCoords.x, spotCoords.y, spotCoords.z))
                    local distnace = CalculateDistance(GetEntityCoords(vehicle), GetEntityCoords(PlayerPedId()))
                    if DoesEntityExist(vehicle) then
                        if distnace < 2.5 then
                            local driver = GetPedInVehicleSeat(vehicle, -1)
                            if driver ~= PlayerPedId() then
                                QBCore.Functions.DeleteVehicle(vehicle)
                                vehiclesRemoved = vehiclesRemoved + 1
                                if vehiclesRemoved >= #parkingSpots then 
                                    return
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

local function ShowHelpNotification(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function FormatString(str)
    local code = ""
    for word in str:gmatch("%S+") do
        local len = #word
        if len >= 4 then
            code = code .. word:sub(1, 2)
        else
            code = code .. word:upper()
        end
    end
    return code
end

function StartLoop(veh, vehname, time, player, station)
    local Notified = false
    local normalTime = time * 60000
    local reducedTime = math.floor(normalTime * 0.8)
    repeat
        if station ~= PlayerRentedVehicle[player].station then
            PlayerRentedVehicle[player] = nil
            break
        end
        if not DoesEntityExist(veh) then
            PlayerRentedVehicle[player] = nil
            QBCore.Functions.Notify(vehname .. Config.Locals['Notifications']['GeneralNotifications']['HasDeleted'], "error")           
            break
        end
        Wait(1000)
        normalTime = normalTime - 1000
        reducedTime = reducedTime - 1000
        if normalTime <= 0 then
            PlayerRentedVehicle[player] = nil
            QBCore.Functions.DeleteVehicle(veh)
            QBCore.Functions.Notify(Config.Locals['Notifications']['RentNotifications']['RentOver'] .. vehname .. " is over")           
            break
        end
        if reducedTime <= 0 and not Notified then
            QBCore.Functions.Notify(Config.Locals['Notifications']['RentNotifications']['RentWarning'] .. vehname)
            Notified = true
        end
    until false or not PlayerRentedVehicle[player] 
end

function HasPermission(job, gang)
    local hasJob = false
    local hasGang = false
    if type(job) == "table" then
        for _, j in ipairs(job) do
            if PlayerData.job.name == j then
                hasJob = true
                break
            end
        end
    elseif job == "all" or PlayerData.job.name == job then
        hasJob = true
    end
    if type(gang) == "table" then
        for _, g in ipairs(gang) do
            if PlayerData.gang.name == g then
                hasGang = true
                break
            end
        end
    elseif gang == "all" or PlayerData.gang.name == gang then
        hasGang = true
    end
    return hasJob or hasGang
end

function SetScriptBlips()
    for k, v in pairs(Config.Locations['Stations']) do
        local blip = LocationBlips[k]
        if v.UseBlip then
            if HasPermission(v.JobRequired, v.GangRequired) then
                if not blip then
                    local blipCoords = v.UseTarget and v.GeneralInformation['TargetInformation']['Coords'] or v.GeneralInformation['MarkerInformation']['MarkerCoords']['MainCoords']
                    blip = AddBlipForCoord(blipCoords.x, blipCoords.y, blipCoords.z)
                    SetBlipDisplay(blip, 4)
                    SetBlipAsShortRange(blip, true)
                    LocationBlips[k] = blip
                end
                SetBlipSprite(blip, v.GeneralInformation['Blip']['BlipId'])
                SetBlipScale(blip, v.GeneralInformation['Blip']['BlipScale'])
                SetBlipColour(blip, v.GeneralInformation['Blip']['BlipColour'])
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(v.GeneralInformation['Blip']['Title'])
                EndTextCommandSetBlipName(blip)
            elseif blip then
                RemoveBlip(blip)
                LocationBlips[k] = nil
            end
        end
    end
end

function GetNearbyPlayers(playerPed, distance)
    local playerList = {}
    local playerPed = playerPed or PlayerPedId()
    local myPos = GetEntityCoords(playerPed)
    local foundNearbyPlayers = false
    for _, player in ipairs(GetActivePlayers()) do
        local targetPed = GetPlayerPed(player)
        local targetPos = GetEntityCoords(targetPed)
        local distanceBetween = #(myPos - targetPos)
        if targetPed ~= playerPed then
            if distanceBetween <= distance then
                table.insert(playerList, {
                    id = GetPlayerServerId(player),
                    name = GetPlayerName(player)
                })
                foundNearbyPlayers = true
            end
        end
    end
    if not foundNearbyPlayers then
        return nil
    end
    return playerList
end

function ApplyVehicleDamage(vehicle, engine, body)
    local bodyHealth = tonumber(body + 0.0)
    local engineHealth = tonumber(engine + 0.0)
    SetVehicleBodyHealth(vehicle, bodyHealth)
    SetVehicleEngineHealth(vehicle, engineHealth)
    if bodyHealth < 900 or engineHealth < 900 and Config.VisuallyDamageCars then
        local tire1, tire2, tire3, tire4 = false, false, false, false
        if math.random() < 0.25 then
            tire1 = true
        end
        if math.random() < 0.25 then
            tire2 = true
        end
        if math.random() < 0.25 then
            tire3 = true
        end
        if math.random() < 0.25 then
            tire4 = true
        end
        if tire1 then
            SetVehicleTyreBurst(vehicle, 0, true, 1000.0)
        end
        if tire2 then
            SetVehicleTyreBurst(vehicle, 1, true, 1000.0)
        end
        if tire3 then
            SetVehicleTyreBurst(vehicle, 4, true, 1000.0)
        end
        if tire4 then
            SetVehicleTyreBurst(vehicle, 5, true, 1000.0)
        end
    end
end

function SetTrunkItemsInfo(trunkitems)
	local items = {}
	for _, item in pairs(trunkitems) do
		local itemInfo = QBCore.Shared.Items[item.name:lower()]
		items[item.slot] = {
			name = itemInfo["name"],
			amount = tonumber(item.amount),
			info = item.info,
			label = itemInfo["label"],
			description = itemInfo["description"] and itemInfo["description"] or "",
			weight = itemInfo["weight"],
			type = itemInfo["type"],
			unique = itemInfo["unique"],
			useable = itemInfo["useable"],
			image = itemInfo["image"],
			slot = item.slot,
		}
	end
	return items
end

function IsParkingOccupied(parking)
    for _, v in pairs(Parking) do
        if v.parkingSpot == parking then
            return true
        end
    end
    return false
end

function IsVehicleAllowed(vehicleid)
    for k, v in pairs(Parking) do
        if k == vehicleid then
            return true
        end
    end
    return false
end

function UpdateParkingVehicles()
    QBCore.Functions.TriggerCallback('CL-PoliceGarageV2:GetParkingVehicle', function(result)
        if result ~= nil then
            if result.vehicle ~= nil then
                QBCore.Functions.DeleteVehicle(result.vehicle)
                Parking[result.id] = nil
            end
        end
    end, Parking)
end

function SetVehicleParkingSpot(data)
    if data.removedata == nil then
        QBCore.Functions.TriggerCallback('CL-PoliceGarageV2:GetVehicle', function(result)
            if result then
                QBCore.Functions.SpawnVehicle(result.vehicle, function(veh)
                    SetEntityHeading(veh, data.coords.w)
                    SetVehicleNumberPlateText(veh, data.plate)
                    QBCore.Functions.SetVehicleProperties(veh, result.mods)
                    PlaceObjectOnGroundProperly(veh)
                    FreezeEntityPosition(veh, true)
                    SetVehicleDoorsLocked(veh, true)
                    SetEntityCollision(veh, false, true)
                    SetEntityAlpha(veh, 155)
                    Parking[result.id] = {plate = data.plate, vehicle = veh, parkingSpot = data.parkingSpot, parkingPos = data.coords}
                end, data.coords, false, false)
            end
        end, data.plate)
    elseif data.removedata then
        local parkingSpot = data.parkingSpot
        local vehicleToRemove = nil
        for k, v in pairs(Parking) do
            if v.parkingSpot == parkingSpot and IsParkingOccupied(parkingSpot) and data.id == k then
                vehicleToRemove = v.vehicle
                break
            end
        end
        if vehicleToRemove ~= nil then
            QBCore.Functions.DeleteVehicle(vehicleToRemove)
            Parking[data.id] = nil
        end      
    end
end

function CalculateDistance(coords1, coords2)
    local distance = math.sqrt((coords2.x - coords1.x)^2 + (coords2.y - coords1.y)^2 + (coords2.z - coords1.z)^2)
    return distance
end

CreateThread(function()
    for k, v in pairs(Config.Locations['Stations']) do
        if not v.UsePurchasable and not v.UseRent or v.JobRquired and v.GangRequired or v.UseTarget and v.UseMarker or not v.UseTarget and not v.UseMarker or v.UseMarker and v.UsePolyZone then return end
        local generalInfo = v.GeneralInformation
        if v.UseTarget then
            local pedCoords = generalInfo['TargetInformation']['Coords']
            local pedModel = generalInfo['TargetInformation']['Ped']
            local pedExists = false
            for i, ped in ipairs(PolicePeds) do
                if DoesEntityExist(ped) and GetEntityModel(ped) == pedModel and GetEntityCoords(ped) == pedCoords then
                    pedExists = true
                    break
                end
            end
            if not pedExists then
                QBCore.Functions.LoadModel(pedModel)
                local ped = CreatePed(0, pedModel, pedCoords.x, pedCoords.y, pedCoords.z, pedCoords.w, false, true)
                PlaceObjectOnGroundProperly(ped)
                FreezeEntityPosition(ped, true)
                SetEntityInvincible(ped, true)
                SetBlockingOfNonTemporaryEvents(ped, true)
                TaskStartScenarioInPlace(ped, generalInfo['TargetInformation']['Scenario'], 0, true)
                table.insert(PolicePeds, ped) 
                exports[Config.Target]:AddTargetEntity(ped, {
                    options = {
                        { 
                            event = "CL-PoliceGarageV2:OpenMainMenu",
                            icon = Config.Locals['Targets']['MainTarget']['Icon'],
                            label = Config.Locals['Targets']['MainTarget']['Label'] .. k,
                            rjob = v.JobRequired,
                            rgang = v.GangRequired,
                            userent = v.UseRent,
                            usepurchasable = v.UsePurchasable,
                            useownable = v.UseOwnable,
                            useliveries = v.UseLiveries,
                            useextras = v.UseExtras,
                            rentvehicles = v.VehiclesInformation['RentVehicles'],
                            purchasevehicles = v.VehiclesInformation['PurchaseVehicles'],
                            coordsinfo = v.VehiclesInformation['SpawnCoords'],
                            station = k,
                            canInteract = function()
                                return HasPermission(v.JobRequired, v.GangRequired)
                            end,
                        },
                        { 
                            event = "CL-PoliceGarageV2:OpenGarageMenu",
                            icon = Config.Locals['Targets']['GarageTarget']['Icon'],
                            label = Config.Locals['Targets']['GarageTarget']['Label'] .. k,
                            rjob = v.JobRequired,
                            rgang = v.GangRequired,
                            purchasevehicles = v.VehiclesInformation['PurchaseVehicles'],
                            coordsinfo = v.VehiclesInformation['SpawnCoords'],
                            station = k,
                            canInteract = function()
                                if v.UseOwnable then
                                    return HasPermission(v.JobRequired, v.GangRequired)
                                end
                                return false
                            end,
                        },
                    },
                    distance = Config.Locals['Targets']['MainTarget']['Distance'],
                })
            end 
        elseif v.UseMarker then
            local sleep
            while true do 
                sleep = 2000
                if HasPermission(v.JobRequired, v.GangRequired) then
                    local playerCoords = GetEntityCoords(PlayerPedId())
                    local distanceToMainMarker = CalculateDistance(playerCoords, generalInfo['MarkerInformation']['MarkerCoords']['MainCoords'])
                    local distanceToGarageMarker = generalInfo['MarkerInformation']['MarkerCoords']['GarageCoords'] and CalculateDistance(playerCoords, generalInfo['MarkerInformation']['MarkerCoords']['GarageCoords']) or math.huge
                    local closestMarkerDistance = math.min(distanceToMainMarker, distanceToGarageMarker)
                    if closestMarkerDistance < 10.0 then
                        DrawMarker(generalInfo['MarkerInformation']['MarkerType'], generalInfo['MarkerInformation']['MarkerCoords']['MainCoords'].x, generalInfo['MarkerInformation']['MarkerCoords']['MainCoords'].y, generalInfo['MarkerInformation']['MarkerCoords']['MainCoords'].z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.7, 0.7, 0.5, 0.5, generalInfo['MarkerInformation']['MarkerColor'].R, generalInfo['MarkerInformation']['MarkerColor'].G, generalInfo['MarkerInformation']['MarkerColor'].B, 255, false, false, false, true, false, false, false)
                        if v.UseOwnable and generalInfo['MarkerInformation']['MarkerCoords']['GarageCoords'] then
                            DrawMarker(generalInfo['MarkerInformation']['MarkerType'], generalInfo['MarkerInformation']['MarkerCoords']['GarageCoords'].x, generalInfo['MarkerInformation']['MarkerCoords']['GarageCoords'].y, generalInfo['MarkerInformation']['MarkerCoords']['GarageCoords'].z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.7, 0.7, 0.5, 0.5, generalInfo['MarkerInformation']['MarkerColor'].R, generalInfo['MarkerInformation']['MarkerColor'].G, generalInfo['MarkerInformation']['MarkerColor'].B, 255, false, false, false, true, false, false, false)
                        end
                        sleep = 0
                        if closestMarkerDistance <= 1.5 then
                            if closestMarkerDistance == distanceToMainMarker then
                                ShowHelpNotification(Config.Locals['Targets']['MainTarget']['Label'] .. " ~INPUT_PICKUP~")
                                if IsControlJustReleased(0, 51) then 
                                    TriggerEvent("CL-PoliceGarageV2:OpenMainMenu", {
                                        rjob = v.JobRequired,
                                        rgang = v.GangRequired,
                                        userent = v.UseRent,
                                        usepurchasable = v.UsePurchasable,
                                        useownable = v.UseOwnable,
                                        useliveries = v.UseLiveries,
                                        useextras = v.UseExtras,
                                        rentvehicles = v.VehiclesInformation['RentVehicles'],
                                        purchasevehicles = v.VehiclesInformation['PurchaseVehicles'],
                                        coordsinfo = v.VehiclesInformation['SpawnCoords'],
                                        station = k,
                                    })
                                end
                            else
                                ShowHelpNotification(Config.Locals['Targets']['GarageTarget']['Label'] .. " ~INPUT_PICKUP~")
                                if IsControlJustReleased(0, 51) and v.UseOwnable then 
                                    TriggerEvent("CL-PoliceGarageV2:OpenGarageMenu", {
                                        rjob = v.JobRequired,
                                        rgang = v.GangRequired,
                                        purchasevehicles = v.VehiclesInformation['PurchaseVehicles'],
                                        coordsinfo = v.VehiclesInformation['SpawnCoords'],
                                        station = k
                                    })
                                end
                            end
                            sleep = 0
                        end
                    end
                end
                Wait(sleep)
            end
        end         
        if v.UsePolyZone then
            local zone = PolyZone:Create(generalInfo['PolyZoneInformation']['ShapeCoords'], {
                name = k,
                minZ = generalInfo['PolyZoneInformation']['MinZ'],
                maxZ = generalInfo['PolyZoneInformation']['MaxZ'],
                debugPoly = generalInfo['PolyZoneInformation']['DeBug']
            })
            local parkingSpots = generalInfo['PolyZoneInformation']['ParkingCoords']
            local currentParkingSpot = nil
            local ped = PlayerPedId()
            local playerCoords = GetEntityCoords(ped)
            zone:onPlayerInOut(function(isPointInside)
                if isPointInside then
                    inRange = true
                    CreateThread(function()
                        repeat
                            Wait(0)
                            if HasPermission(v.JobRequired, v.GangRequired) and IsPedInAnyVehicle(ped) then
                                local ped = PlayerPedId()
                                local playerCoords = GetEntityCoords(ped)
                                local canStoreVehicle = false
                                for i = 1, #parkingSpots do
                                    local spotCoords = parkingSpots[i]
                                    local distance = #(vector3(playerCoords.x - spotCoords.x, playerCoords.y - spotCoords.y, playerCoords.z - spotCoords.z))
                                    if distance < 2.5 and not IsParkingOccupied(i) then 
                                        if Config.ShowMarker then DrawMarker(2, spotCoords.x, spotCoords.y, spotCoords.z - 0.90, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.5, 255, 255, 255, 200, 0, 0, 0, 0, 0, 0, 0) end
                                        if IsControlJustReleased(0, 51) and v.UsePolyZone then 
                                            canStoreVehicle = true
                                            currentParkingSpot = i
                                            currentSpotCoords = spotCoords
                                        end
                                    end
                                end
                                if canStoreVehicle then
                                    local store_vehicle_data = {
                                        type = "storevehicle",
                                        job = v.JobRequired,
                                        gang = v.GangRequired,
                                        selllist = v.VehiclesInformation['PurchaseVehicles'],
                                        station = k,
                                        parkingSpot = currentParkingSpot,
                                        parkingPos = currentSpotCoords,
                                    }
                                    TriggerEvent("CL-PoliceGarageV2:Utility", store_vehicle_data)
                                else
                                    ShowHelpNotification("Park your vehicle at one of the designated parking spots to store it.")
                                end
                            end
                        until not inRange
                    end)
                else
                    inRange = false
                end
            end)
        end
    end
end)

RegisterNetEvent('CL-PoliceGarageV2:OpenGarageMenu', function(data)
    local GarageMenu = {
        {
            header = data.station .. " - Garage",
            icon = "fa-solid fa-circle-info",
            isMenuHeader = true,
        }
    }
    table.insert(GarageMenu, {
        header = "Available Vehicles",
        txt = "View your stored vehicles",
        icon = "fa-solid fa-list",
        params = {
            isServer = true,
            event = "CL-PoliceGarageV2:GetData",
            args = {
                type = "availablevehicles",
                station = data.station,
                coordsinfo = data.coordsinfo,
                selllist = data.purchasevehicles,
                rjob = data.rjob,
                rgang = data.rgang,
            },
        },
    })
    table.insert(GarageMenu, {
        header = "Vehicle Depot",
        txt = "Get back your destroyed vehicles",
        icon = "fa-solid fa-circle-xmark",
        params = {
            isServer = true,
            event = "CL-PoliceGarageV2:GetData",
            args = {
                type = "vehicledepot",
                rjob = data.rjob,
                rgang = data.rgang,
                coordsinfo = data.coordsinfo,
                selllist = data.purchasevehicles,
                station = data.station,
            },
        },
    })
    if IsPedInAnyVehicle(PlayerPedId(), false) then
        table.insert(GarageMenu, {
            header = "Store Vehicle",
            txt = "Store your vehicle at " .. data.station,
            icon = "fa-solid fa-warehouse",
            params = {
                event = "CL-PoliceGarageV2:Utility",
                args = {
                    type = "storevehicle",
                    job = data.rjob,
                    gang = data.rgang,
                    selllist = data.purchasevehicles,
                    station = data.station,
                },
            },
        })
    end
    table.insert(GarageMenu, {
        header = "Close",
        icon = "fa-solid fa-xmark",
        params = {
            event = "qb-menu:client:closeMenu",
        },
    })
    exports['qb-menu']:openMenu(GarageMenu)
end)

RegisterNetEvent('CL-PoliceGarageV2:OpenVehiclesMenu', function(data)
    if not HasPermission(data.job, data.gang) then return end
    local VehiclesMenu = {
        {
            header = data.vehicledepot and "Vehicle Depot" or (data.station .. " - Garage"),
            icon = "fa-solid fa-circle-info",
            isMenuHeader = true,
        }
    }
    for k, v in pairs(data.vehicles) do
        local vehicleName
        for name, vehicle in pairs(data.purchasablevehicles) do
            if vehicle.Vehicle == v.vehicle then
                vehicleName = name
                break
            end
        end
        if not vehicleName then
            vehicleName = QBCore.Shared.Vehicles[v.vehicle] and QBCore.Shared.Vehicles[v.vehicle].name or "N/A"
        end
        if v.deleted then
            vehicleName = (type(Config.DepotFine) == "number" and (Config.DepotFine .. "$ ") or "Depot - ") .. vehicleName
        end
        if not v.locate then
            table.insert(VehiclesMenu, {
                header = vehicleName .. " ┇ " .. v.vehicleinfo['plate'],
                txt = "Fuel : " .. (v.vehicleinfo['fuel'] and math.floor(v.vehicleinfo['fuel']) or "N/A") .. "<br> Body : " .. (v.vehicleinfo['body'] and QBCore.Shared.Round(v.vehicleinfo['body'] / 10, 0) or "N/A") .. "%<br> Engine : " .. (v.vehicleinfo['engine'] and QBCore.Shared.Round(v.vehicleinfo['engine'] / 10, 0) or "N/A") .. "%",
                icon = "fa-solid fa-car",
                params = {
                    event = "CL-PoliceGarageV2:TakeVehicle",
                    args = {
                        coordsinfo = data.coordsinfo,
                        vehicle = v.vehicle,
                        vehiclename = vehicleName,
                        fine = v.deleted and Config.DepotFine or 0,
                        showcar = v.showcar and true or nil,
                        status = v.status,
                        trunkitems = v.trunkitems,
                        mods = v.mods,
                        id = v.id,
                        vehicleinfo = v.vehicleinfo,
                    },
                },
            })
        else
            table.insert(VehiclesMenu, {
                header = vehicleName .. " ┇ Locate",
                txt = "Locate your vehicle",
                icon = "fa-solid fa-location-crosshairs",
                params = {
                    event = "CL-PoliceGarageV2:LocateVehicle",
                    args = {
                        vehiclename = vehicleName,
                        plate = v.vehicleinfo['plate'],
                    },
                },
            })
        end
    end
    table.insert(VehiclesMenu, {
        header = "Close",
        icon = "fa-solid fa-xmark",
        params = {
            event = "qb-menu:client:closeMenu",
        },
    })
    exports['qb-menu']:openMenu(VehiclesMenu)
end)

RegisterNetEvent('CL-PoliceGarageV2:OpenMainMenu', function(data)
    local MainMenu = {
        {
            header = data.station .. " - Garage",
            icon = "fa-solid fa-circle-info",
            isMenuHeader = true,
        }
    }
    if data.userent then
        table.insert(MainMenu, {
            header = "Rent Vehicles",
            txt = "View and rent vehicles for a selected amount of time",
            icon = "fa-solid fa-file-contract",
            params = {
                event = "CL-PoliceGarageV2:OpenRentingMenu",
                args = {
                    rentvehicles = data.rentvehicles,
                    coordsinfo = data.coordsinfo,
                    station = data.station,
                    job = data.rjob,
                    gang = data.gang,
                    userent = data.userent,
                    purchasevehicles = data.purchasevehicles,
                    useownable = data.useownable,
                    useextras = data.useextras,
                    useliveries = data.useliveries,
                    usepurchasable = data.usepurchasable,
                },
            }
        })
    end
    if data.usepurchasable then
        table.insert(MainMenu, {
            header = "Purchase Vehicles",
            txt = "View and purchase vehicles to use as your own",
            icon = "fa-solid fa-money-check-dollar",
            params = {
                event = "CL-PoliceGarageV2:OpenPurchaseMenu",
                args = {
                    purchasevehicles = data.purchasevehicles,
                    coordsinfo = data.coordsinfo,
                    station = data.station,
                    job = data.rjob,
                    gang = data.rgang,
                    useownable = data.useownable,
                    usepurchasable = data.usepurchasable,
                    useliveries = data.useliveries,
                    useextras = data.useextras,
                    userent = data.userent,
                    rentvehicles = data.rentvehicles,
                },
            }
        })
    end
    if IsPedInAnyVehicle(PlayerPedId(), false) and data.useliveries then
        table.insert(MainMenu, {
            header = "Choose Livery",
            txt = "Change your vehicle livery",
            icon = "fa-solid fa-spray-can",
            params = {
                event = "CL-PoliceGarageV2:StartSelection",
                args = {
                    vehicle = GetVehiclePedIsIn(PlayerPedId(), false),
                    coordsinfo = data.coordsinfo,
                    type = "livery",
                },
            }
        })
    end
    if IsPedInAnyVehicle(PlayerPedId(), false) and data.useextras then
        table.insert(MainMenu, {
            header = "Choose Extras",
            txt = "Add or remove extras",
            icon = "fa-solid fa-plus-minus",
            params = {
                event = "CL-PoliceGarageV2:OpenExtrasMenu",
                args = {
                    vehicle = GetVehiclePedIsIn(PlayerPedId(), false),
                    station = data.station,
                    userent = data.userent,
                    rentvehicles = data.rentvehicles,
                    purchasevehicles = data.purchasevehicles,
                    coordsinfo = data.coordsinfo,
                    job = data.rjob,
                    gang = data.rgang,
                    useownable = data.useownable,
                    useextras = data.useextras,
                    usepurchasable = data.usepurchasable,
                    useliveries = data.useliveries,
                },
            }
        })
    end
    if PlayerRentedVehicle[PlayerPedId()] and PlayerRentedVehicle[PlayerPedId()].station == data.station and data.userent and GetVehiclePedIsIn(PlayerPedId(), false) == PlayerRentedVehicle[PlayerPedId()].vehicle then
        table.insert(MainMenu, {
            header = "Return Vehicle",
            txt = "Return your rented vehicle",
            icon = "fa-solid fa-left-long",
            params = {
                event = "CL-PoliceGarageV2:ReturnRentedVehicle",
            }
        })
    end
    table.insert(MainMenu, {
        header = "Close",
        icon = "fa-solid fa-xmark",
        params = {
            event = "qb-menu:client:closeMenu",
        },
    })
    exports['qb-menu']:openMenu(MainMenu)
end)

RegisterNetEvent("CL-PoliceGarageV2:OpenExtrasMenu", function(data)
    local ExtrasMenu = {
        {
            header = data.station .. " - Extras Selection",
            icon = "fa-solid fa-circle-info",
            isMenuHeader = true,
        }
    }
    local hasExtras = false
    for i = 1, 13 do
        if DoesExtraExist(data.vehicle, i) then
            hasExtras = true
            if IsVehicleExtraTurnedOn(data.vehicle, i) then
                table.insert(ExtrasMenu, {
                    header = "Toggle Extra " .. i .. " Off",
                    icon = "fa-solid fa-xmark",
                    params = {
                        event = "CL-PoliceGarageV2:VehicleExtra",
                        args = {
                            vehicle = data.vehicle,
                            extraid = i,
                            userent = data.userent,
                            rentvehicles = data.rentvehicles,
                            purchasevehicles = data.purchasevehicles,
                            coordsinfo = data.coordsinfo,
                            job = data.job,
                            gang = data.gang,
                            station = data.station,
                            useownable = data.useownable,
                            useextras = data.useextras,
                            usepurchasable = data.usepurchasable,
                            useliveries = data.useliveries,
                        },
                    },
                })
            else
                table.insert(ExtrasMenu, {
                    header = "Toggle Extra " .. i .. " On",
                    icon = "fa-solid fa-circle-check",
                    params = {
                        event = "CL-PoliceGarageV2:VehicleExtra",
                        args = {
                            vehicle = data.vehicle,
                            extraid = i,
                            userent = data.userent,
                            rentvehicles = data.rentvehicles,
                            purchasevehicles = data.purchasevehicles,
                            coordsinfo = data.coordsinfo,
                            job = data.job,
                            gang = data.gang,
                            station = data.station,
                            useownable = data.useownable,
                            useextras = data.useextras,
                            usepurchasable = data.usepurchasable,
                            useliveries = data.useliveries,
                        },
                    },
                })
            end
        end
    end
    if not hasExtras then
        table.insert(ExtrasMenu, {
            header = "No Extras Available",
            icon = "fa-solid fa-exclamation-circle",
            isMenuHeader = true,
        })
    end
    table.insert(ExtrasMenu, {
        header = "Go Back",
        icon = "fa-solid fa-left-long",
        params = {
            event = "CL-PoliceGarageV2:OpenMainMenu",
            args = {
                userent = data.userent,
                rentvehicles = data.rentvehicles,
                purchasevehicles = data.purchasevehicles,
                coordsinfo = data.coordsinfo,
                rjob = data.job,
                rgang = data.gang,
                station = data.station,
                useownable = data.useownable,
                useextras = data.useextras,
                usepurchasable = data.usepurchasable,
                useliveries = data.useliveries,
            },
        },
    })
    exports['qb-menu']:openMenu(ExtrasMenu)
end)

RegisterNetEvent("CL-PoliceGarageV2:OpenRentingMenu", function(data)
    if QBCore.Functions.SpawnClear(vector3(data.coordsinfo['VehicleSpawn'].x, data.coordsinfo['VehicleSpawn'].y, data.coordsinfo['VehicleSpawn'].z), data.coordsinfo['CheckRadius']) then
        local RentingMenu = {
            {
                header = data.station .. " - Garage",
                icon = "fa-solid fa-circle-info",
                isMenuHeader = true,
            }
        }
        if not PlayerRentedVehicle[PlayerPedId()] then
            for k, v in pairs(data.rentvehicles) do
                table.insert(RentingMenu, {
                    header = "Rent " .. k,
                    txt = "Rent: " .. k .. "<br> For: " .. v.PricePerMinute .. "$ (Per Minute)",
                    icon = "fa-solid fa-car",
                    params = {
                        event = "CL-PoliceGarageV2:ChooseRent",
                        args = {
                            price = v.PricePerMinute,
                            vehiclename = k,
                            vehicle = v.Vehicle,
                            coordsinfo = data.coordsinfo,
                            station = data.station,
                            job = data.job,
                            gang = data.gang,
                        }
                    }
                })
            end
        elseif PlayerRentedVehicle[PlayerPedId()].station ~= data.station then
            for k, v in pairs(data.rentvehicles) do
                table.insert(RentingMenu, {
                    header = "Rent " .. k,
                    txt = "Rent: " .. k .. "<br> For: " .. v.PricePerMinute .. "$ (Per Minute)",
                    icon = "fa-solid fa-car",
                    params = {
                        event = "CL-PoliceGarageV2:ChooseRent",
                        args = {
                            price = v.PricePerMinute,
                            vehiclename = k,
                            vehicle = v.Vehicle,
                            coordsinfo = data.coordsinfo,
                            station = data.station,
                            job = data.job,
                            gang = data.gang,
                        }
                    }
                })
            end
        elseif GetVehiclePedIsIn(PlayerPedId(), false) ~= PlayerRentedVehicle[PlayerPedId()].vehicle or not IsPedInAnyVehicle(PlayerPedId(), false) then
            table.insert(RentingMenu, {
                header = "Return " .. PlayerRentedVehicle[PlayerPedId()].name .. " Before Renting",
                icon = "fa-solid fa-exclamation-circle",
                isMenuHeader = true,
            })
        end
        if PlayerRentedVehicle[PlayerPedId()] and PlayerRentedVehicle[PlayerPedId()].station == data.station and GetVehiclePedIsIn(PlayerPedId(), false) == PlayerRentedVehicle[PlayerPedId()].vehicle then
            table.insert(RentingMenu, {
                header = "Return Vehicle",
                txt = "Return your rented vehicle",
                icon = "fa-solid fa-left-long",
                params = {
                    event = "CL-PoliceGarageV2:ReturnRentedVehicle",
                }
            })
        end
        table.insert(RentingMenu, {
            header = "Go Back",
            icon = "fa-solid fa-left-long",
            params = {
                event = "CL-PoliceGarageV2:OpenMainMenu",
                args = {
                    userent = data.userent,
                    rentvehicles = data.rentvehicles,
                    purchasevehicles = data.purchasevehicles,
                    coordsinfo = data.coordsinfo,
                    rjob = data.job,
                    rgang = data.gang,
                    station = data.station,
                    useownable = data.useownable,
                    useextras = data.useextras,
                    usepurchasable = data.usepurchasable,
                    useliveries = data.useliveries,
                },
            },
        })
        exports['qb-menu']:openMenu(RentingMenu)
    else
        QBCore.Functions.Notify(Config.Locals["Notifications"]['GeneralNotifications']["VehicleInSpawn"], "error")
    end
end)

RegisterNetEvent("CL-PoliceGarageV2:OpenPurchaseMenu", function(data)
    local VehicleMenu = {
        {
            header = data.station .. " - Garage",
            icon = "fa-solid fa-circle-info",
            isMenuHeader = true,
        }
    }
    local sortedVehicles = {}
    for k, v in pairs(data.purchasevehicles) do
        local rankLevel = data.job and PlayerData.job.grade.level or data.gang and PlayerData.gang.grade.level or 0
        if rankLevel >= v.Rank then
            table.insert(sortedVehicles, {name = k, vehicle = v})
        end
    end
    table.sort(sortedVehicles, function(a, b)
        local rankLevel = data.job and PlayerData.job.grade.level or data.gang and PlayerData.gang.grade.level or 0
        return math.abs(rankLevel - a.vehicle.Rank) < math.abs(rankLevel - b.vehicle.Rank)
    end)
    for i = 1, #sortedVehicles do
        local k, v = sortedVehicles[i].name, sortedVehicles[i].vehicle
        local priceText = (v.TotalPrice ~= 0) and (v.TotalPrice .. "$") or "Free"
        table.insert(VehicleMenu, {
            header = "Purchase " .. k,
            txt = "Purchase: " .. k .. "<br> For: " .. priceText,
            icon = "fa-solid fa-circle-check",
            params = {
                event = "CL-PoliceGarageV2:StartPreview",
                args = {
                    price = v.TotalPrice,
                    vehiclename = k,
                    vehicle = v.Vehicle,
                    trunkitems = v.VehicleSettings['TrunkItems'],
                    extras = v.VehicleSettings['DefaultExtras'],
                    liveries = v.VehicleSettings['DefaultLiveries'],
                    colors = v.VehicleSettings['DefaultColors'],
                    coordsinfo = data.coordsinfo,
                    station = data.station,
                    job = data.job,
                    gang = data.gang,
                    useownable = data.useownable,
                    useliveries = data.useliveries,
                    rank = v.Rank,
                    useextras = data.useextras,
                    usepurchasable = data.usepurchasable,
                    userent = data.userent,
                    rentvehicles = data.rentvehicles,
                    purchasevehicles = data.purchasevehicles,
                }
            }
        })
    end
    table.insert(VehicleMenu, {
        header = "Go Back",
        icon = "fa-solid fa-left-long",
        params = {
            event = "CL-PoliceGarageV2:OpenMainMenu",
            args = {
                userent = data.userent,
                rentvehicles = data.rentvehicles,
                purchasevehicles = data.purchasevehicles,
                coordsinfo = data.coordsinfo,
                rjob = data.job,
                rgang = data.gang,
                station = data.station,
                useownable = data.useownable,
                useextras = data.useextras,
                usepurchasable = data.usepurchasable,
                useliveries = data.useliveries,
            },
        },
    })
    exports['qb-menu']:openMenu(VehicleMenu)
end)

RegisterNetEvent("CL-PoliceGarageV2:OpenNearMenu", function(data)
    local PlayersMenu = {
        {
            header = "Nearby Players",
            icon = "fa-solid fa-circle-info",
            isMenuHeader = true,
        }
    }
    table.insert(PlayersMenu, {
        header = "You",
        txt = "Purchase " .. data.vehiclename .. " for yourself",
        icon = "fa-solid fa-user-check",
        params = {
            isServer = true,
            event = "CL-PoliceGarageV2:BuyVehicle",
            args = {
                id = tonumber(GetPlayerServerId(PlayerId())),
                name = GetPlayerName(PlayerId()),
                buyer = tonumber(GetPlayerServerId(PlayerId())),
                paymenttype = data.paymenttype, 
                price = data.price,
                vehiclename = data.vehiclename,
                vehicle = data.vehicle,
                coordsinfo = data.coordsinfo,
                rank = data.rank,
                job = data.job,
                station = data.station,
                useownable = data.useownable,
                colors = data.colors,
                extras = data.extras,
                trunkitems = data.trunkitems,
                liveries = data.liveries,
            },
        }
    })
    if not GetNearbyPlayers(PlayerPedId(), Config.CompanyFunds['CheckDistance'], data.job) then
        table.insert(PlayersMenu, {
            header = "No Nearby Players",
            icon = "fa-solid fa-user-check",
            isMenuHeader = true,
        })
    else
        for k, v in pairs(GetNearbyPlayers(PlayerPedId(), Config.CompanyFunds['CheckDistance'], data.job)) do
            table.insert(PlayersMenu, {
                header = v.name,
                txt = "Purchase " .. data.vehiclename .. " for " .. v.name,
                icon = "fa-solid fa-user-check",
                params = {
                    isServer = true,
                    event = "CL-PoliceGarageV2:BuyVehicle",
                    args = {
                        id = v.id,
                        name = v.name,
                        buyer = tonumber(GetPlayerServerId(PlayerId())),
                        paymenttype = data.paymenttype, 
                        price = data.price,
                        vehiclename = data.vehiclename,
                        vehicle = data.vehicle,
                        coordsinfo = data.coordsinfo,
                        rank = data.rank,
                        job = data.job,
                        station = data.station,
                        useownable = data.useownable,
                        colors = data.colors,
                        extras = data.extras,
                        trunkitems = data.trunkitems,
                        liveries = data.liveries,
                    },
                }
            })
        end
    end
    table.insert(PlayersMenu, {
        header = "Go Back",
        icon = "fa-solid fa-left-long",
        params = {
            event = "CL-PoliceGarageV2:ChoosePayment",
            args = {
                price = data.price,
                vehiclename = data.vehiclename,
                vehicle = data.vehicle,
                coordsinfo = data.coordsinfo,
                job = data.job,
                colors = data.colors,
                gang = data.gang,
                station = data.station,
                rank = data.rank,
                useownable = data.useownable,
                trunkitems = data.trunkitems,
                extras = data.extras,
                liveries = data.liveries,
            },
        },
    })
    exports['qb-menu']:openMenu(PlayersMenu)
end)

RegisterNetEvent('CL-PoliceGarageV2:TakeVehicle', function(data)
    if not IsPedInAnyVehicle(PlayerPedId(), false) then
        if data.showcar == nil then
            if QBCore.Functions.SpawnClear(vector3(data.coordsinfo['VehicleSpawn'].x, data.coordsinfo['VehicleSpawn'].y, data.coordsinfo['VehicleSpawn'].z), data.coordsinfo['CheckRadius']) then
                QBCore.Functions.TriggerCallback('CL-PoliceGarageV2:SpawnVehicle', function(result)
                    if result then
                        local veh = NetToVeh(result.net)
                        SetVehicleNumberPlateText(veh, data.vehicleinfo['plate'])
                        ApplyVehicleDamage(veh, data.vehicleinfo['engine'], data.vehicleinfo['body'])
                        SetVehRadioStation(veh, 'OFF')
                        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
                        if data.trunkitems ~= nil then TriggerServerEvent("inventory:server:addTrunkItems", data.vehicleinfo['plate'], SetTrunkItemsInfo(data.trunkitems)) end
                        QBCore.Functions.SetVehicleProperties(veh, result.mods)
                        exports[Config.FuelSystem]:SetFuel(veh, tonumber(data.vehicleinfo['fuel'] + 0.0))
                        SetVehicleEngineOn(veh, true, true)
                        QBCore.Functions.Notify(Config.Locals['Notifications']['GarageNotifications']['TakeOut'] .. data.vehiclename, 'success')
                    end
                end, data)
            else
                QBCore.Functions.Notify(Config.Locals["Notifications"]['GeneralNotifications']["VehicleInSpawn"], "error")
            end
        elseif data.showcar then
            if Parking[data.id] and IsVehicleAllowed(data.id) then
                local newdata = {
                    coords = Parking[data.id].parkingPos,
                    showcar = data.showcar,
                    vehicle = data.vehicle,
                    vehicleinfo = data.vehicleinfo,
                }
                QBCore.Functions.TriggerCallback('CL-PoliceGarageV2:SpawnVehicle', function(result)
                    if result then
                        local veh = NetToVeh(result.net)
                        SetVehicleNumberPlateText(veh, data.vehicleinfo['plate'])
                        ApplyVehicleDamage(veh, data.vehicleinfo['engine'], data.vehicleinfo['body'])
                        SetVehRadioStation(veh, 'OFF')
                        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
                        if data.trunkitems ~= nil then TriggerServerEvent("inventory:server:addTrunkItems", data.vehicleinfo['plate'], SetTrunkItemsInfo(data.trunkitems)) end
                        QBCore.Functions.SetVehicleProperties(veh, result.mods)
                        exports[Config.FuelSystem]:SetFuel(veh, tonumber(data.vehicleinfo['fuel'] + 0.0))
                        SetVehicleEngineOn(veh, true, true)
                        QBCore.Functions.Notify(Config.Locals['Notifications']['GarageNotifications']['TakeOut'] .. data.vehiclename, 'success')
                        local vehicleinfo = {
                            removedata = true,
                            parkingSpot = Parking[data.id].parkingSpot,
                            id = data.id,
                        }
                        SetVehicleParkingSpot(vehicleinfo)
                    end
                end, newdata)
            end
        end
    else
        QBCore.Functions.Notify(Config.Locals['Notifications']['GarageNotifications']['InVehicle'], 'error')
    end
end)

RegisterNetEvent("CL-PoliceGarageV2:Utility", function(data)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    local vehicleplate = QBCore.Functions.GetPlate(vehicle)
    if data.type == "storevehicle" then
        if GetVehicleNumberOfPassengers(vehicle) == 0 then
            if IsPedInAnyVehicle(ped, false) then
                QBCore.Functions.TriggerCallback('CL-PoliceGarageV2:IsPlayerOwner', function(result)
                    if result then
                        local totalFuel = exports[Config.FuelSystem]:GetFuel(vehicle)
                        local vehicleMods = QBCore.Functions.GetVehicleProperties(vehicle)
                        TriggerServerEvent("qb-vehicletuning:server:SaveVehicleProps", vehicleMods)
                        if data.parkingSpot and data.parkingPos then TriggerServerEvent("CL-PoliceGarageV2:AddData", data.type, nil, vehicleplate, data.job, data.gang, data.station, math.ceil(GetVehicleBodyHealth(vehicle)), math.ceil(GetVehicleEngineHealth(vehicle)), math.floor(totalFuel), vehicleMods, data.selllist, 3) else TriggerServerEvent("CL-PoliceGarageV2:AddData", data.type, nil, vehicleplate, data.job, data.gang, data.station, math.ceil(GetVehicleBodyHealth(vehicle)), math.ceil(GetVehicleEngineHealth(vehicle)), math.floor(totalFuel), vehicleMods, data.selllist, 1) end 
                        TaskLeaveVehicle(ped, vehicle, 1)
                        Citizen.Wait(2000)
                        Wait(200)
                        QBCore.Functions.DeleteVehicle(vehicle)
                        if data.parkingSpot and data.parkingPos then
                            local parkingInfo = {
                                parkingSpot = data.parkingSpot,
                                coords = data.parkingPos,
                                plate = vehicleplate,
                            }
                            SetVehicleParkingSpot(parkingInfo)
                        end
                    else
                        QBCore.Functions.Notify(Config.Locals["Notifications"]['GarageNotifications']["NotOwner"], "error")
                    end
                end, data.station, vehicleplate, data.selllist)
            else
                QBCore.Functions.Notify(Config.Locals["Notifications"]['GeneralNotifications']["NotInVehicle"], "error")
            end
        else
            QBCore.Functions.Notify(Config.Locals["Notifications"]['GarageNotifications']["VehicleOccupied"], "error")
        end
    end
end)

RegisterNetEvent("CL-PoliceGarageV2:LocateVehicle", function(data)
    QBCore.Functions.TriggerCallback('CL-PoliceGarageV2:GetVehicleCoords', function(result)
        if result then
            QBCore.Functions.Notify("Waypoint for " .. data.vehiclename .. " has been added", "success")
            SetNewWaypoint(result.x, result.y)
        end
    end, data.plate)
end)

RegisterNetEvent("CL-PoliceGarageV2:SpawnRentedVehicle", function(vehicle, vehiclename, amount, time, realtime, spawncoords, paymenttype, job, gang, station)
    QBCore.Functions.SpawnVehicle(vehicle, function(veh)
        local player = PlayerPedId()
        SetVehicleDirtLevel(veh, 0.0)
		PlayerRentedVehicle[player] = {vehicle = veh, station = station, name = vehiclename, amount = amount, paymenttype = paymenttype, time = time, starttime = realtime, job = job, gang = gang}
        SetVehicleNumberPlateText(veh, FormatString(station)..tostring(math.random(1000, 9999)))
        exports[Config.FuelSystem]:SetFuel(veh, 100.0)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
        SetVehicleEngineOn(veh, true, true)
        StartLoop(veh, vehiclename, time, player, station)
    end, spawncoords, true, true)
end)

RegisterNetEvent("CL-PoliceGarageV2:SpawnPurchasedVehicle", function(vehicle, vehiclename, spawncoords, checkradius, job, gang, useownable, trunkitems, extras, liveries, colors, station)
    QBCore.Functions.SpawnVehicle(vehicle, function(veh)
        SetVehicleNumberPlateText(veh, FormatString(station)..tostring(math.random(1000, 9999)))
        exports[Config.FuelSystem]:SetFuel(veh, 100.0)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        SetVehicleModKit(veh, 0)
        SetVehicleDirtLevel(veh, 0.0)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
        SetVehicleEngineOn(veh, true, true)
        local totalFuel = exports[Config.FuelSystem]:GetFuel(veh)
        if trunkitems then
            TriggerServerEvent("inventory:server:addTrunkItems", QBCore.Functions.GetPlate(veh), SetTrunkItemsInfo(trunkitems))
        end
        if extras then
            for i = 0, 13 do
                if DoesExtraExist(veh, i) then
                    SetVehicleExtra(veh, i, 1)
                end
            end         
            for i = 1, #extras do
                local extra = extras[i]
                if DoesExtraExist(veh, extra) then
                    SetVehicleExtra(veh, extra, 0)
                end
            end
        end
        if liveries then
            local matchedLivery = nil
            for k, v in pairs(liveries) do
                if job and (PlayerData.job.grade.level >= v.RankRequired or (gang and PlayerData.gang.grade.level >= v.RankRequired)) then
                    if not matchedLivery then
                        matchedLivery = {name = k, data = v}
                    end
                end
            end
            if matchedLivery then
                SetVehicleLivery(veh, matchedLivery.data.LiveryID)
                Citizen.Wait(5000)
                QBCore.Functions.Notify(Config.Locals['Notifications']['GeneralNotifications']['LiverySet'] .. matchedLivery.name, "success")
            end
        end
        if colors then
            if colors.PrimaryColor then SetVehicleCustomPrimaryColour(veh, colors.PrimaryColor.R, colors.PrimaryColor.G, colors.PrimaryColor.B) end
            if colors.SecondaryColor then SetVehicleCustomSecondaryColour(veh, colors.SecondaryColor.R, colors.SecondaryColor.G, colors.SecondaryColor.B) end
        end
        if useownable then
            TriggerServerEvent("CL-PoliceGarageV2:AddData", "vehiclepurchased", vehicle, QBCore.Functions.GetPlate(veh), job, gang, station, math.ceil(GetVehicleBodyHealth(vehicle)), math.ceil(GetVehicleEngineHealth(vehicle)), math.floor(totalFuel))
        end
    end, spawncoords, true)
end)

RegisterNetEvent("CL-PoliceGarageV2:ReturnRentedVehicle", function()
	local player = PlayerPedId()
    if not PlayerRentedVehicle[player] then
        QBCore.Functions.Notify(Config.Locals['Notifications']['RentNotifications']['IncorrectVehicle'] .. PlayerRentedVehicle[player].vehiclename, "error")
        return
    end
    if IsPedInAnyVehicle(player, false) then
        QBCore.Functions.TriggerCallback('CL-PoliceGarageV2:GetRealTime', function(result)
            if not PlayerRentedVehicle[player] then
                QBCore.Functions.Notify(Config.Locals['Notifications']['RentNotifications']['NoRentedVehicle'])
                return
            end
            TaskLeaveVehicle(player, PlayerRentedVehicle[player].vehicle, 1)
            Citizen.Wait(2000)
            local remainingTime = (PlayerRentedVehicle[player].time * 60) - (result - PlayerRentedVehicle[player].starttime)
            local refund = math.floor(PlayerRentedVehicle[player].amount * (remainingTime / (PlayerRentedVehicle[player].time * 60)))
            QBCore.Functions.Notify(Config.Locals['Notifications']['RentNotifications']['VehicleReturned'] .. PlayerRentedVehicle[player].name .. " Refund amount : " .. refund .. "$")
            TriggerServerEvent("CL-PoliceGarageV2:RefundRent", PlayerRentedVehicle[player].paymenttype, refund, GetPlayerServerId(PlayerId()), PlayerRentedVehicle[player].job, PlayerRentedVehicle[player].gang)
            QBCore.Functions.DeleteVehicle(PlayerRentedVehicle[player].vehicle)
            PlayerRentedVehicle[player] = nil
        end)
    else
        QBCore.Functions.Notify(Config.Locals['Notifications']['GeneralNotifications']['NotInVehicle'], "error")
    end
end)

RegisterNetEvent("CL-PoliceGarageV2:StartSelection", function(data)
    local player = PlayerPedId()
    if GetPedInVehicleSeat(data.vehicle, -1) == player then
        if QBCore.Functions.SpawnClear(vector3(data.coordsinfo['PreviewSpawn'].x, data.coordsinfo['PreviewSpawn'].y, data.coordsinfo['PreviewSpawn'].z), data.coordsinfo['CheckRadius']) then
            DoScreenFadeOut(700)
            while not IsScreenFadedOut() do
                Citizen.Wait(0)
            end
            SetPedCoordsKeepVehicle(player, data.coordsinfo['PreviewSpawn'].x, data.coordsinfo['PreviewSpawn'].y, data.coordsinfo['PreviewSpawn'].z)
            SetEntityHeading(data.vehicle, data.coordsinfo['PreviewSpawn'].w)
            PlaceObjectOnGroundProperly(data.vehicle)
            FreezeEntityPosition(data.vehicle, true)
            SetEntityCollision(data.vehicle, false, true)
            DoScreenFadeIn(700)
            if data.type == "livery" then
                local oldLivery = GetVehicleLivery(data.vehicle)
                local currentLivery = oldLivery
                Citizen.CreateThread(function()
                    while true do
                        ShowHelpNotification("Switch livery ~INPUT_PICKUP~. Confirm ~INPUT_MOVE_DOWN_ONLY~. Cancel ~INPUT_FRONTEND_RRIGHT~")
                        if IsControlJustReleased(0, 177) then
                            FreezeEntityPosition(data.vehicle, false)
                            SetEntityCollision(data.vehicle, true, true)
                            SetVehicleLivery(data.vehicle, oldLivery)
                            break
                        end
                        if IsControlJustReleased(0, 31) then
                            SetVehicleLivery(data.vehicle, currentLivery)
                            FreezeEntityPosition(data.vehicle, false)
                            SetEntityCollision(data.vehicle, true, true)
                            QBCore.Functions.Notify(Config.Locals['Notifications']['GeneralNotifications']['LiverySet'] .. currentLivery, "success")
                            break
                        end
                        if IsControlJustReleased(0, 51) then
                            currentLivery = (currentLivery + 1) % (GetVehicleLiveryCount(data.vehicle) - 1)
                            if currentLivery == 0 then
                                currentLivery = 1
                            end
                            SetVehicleLivery(data.vehicle, currentLivery)
                        end
                        if not IsPedInAnyVehicle(player) then
                            FreezeEntityPosition(data.vehicle, false)
                            SetEntityCollision(data.vehicle, true, true)
                            SetVehicleLivery(data.vehicle, oldLivery)
                            QBCore.Functions.Notify(Config.Locals['Notifications']['GeneralNotifications']['LeftVehicle'], "error")
                            break
                        end
                        Wait(0)
                    end
                end)
            end
        else
            QBCore.Functions.Notify(Config.Locals["Notifications"]['GeneralNotifications']["VehicleInSpawn"], "error")
        end
    else
        QBCore.Functions.Notify(Config.Locals["Notifications"]['GeneralNotifications']["NotDriver"], "error")
    end
end)

RegisterNetEvent("CL-PoliceGarageV2:VehicleExtra", function(data)
    local Data = {
        userent = data.userent,
        rentvehicles = data.rentvehicles,
        purchasevehicles = data.purchasevehicles,
        coordsinfo = data.coordsinfo,
        job = data.job,
        gang = data.gang,
        station = data.station,
        useownable = data.useownable,
        useextras = data.useextras,
        usepurchasable = data.usepurchasable,
        useliveries = data.useliveries,
        vehicle = data.vehicle,
    }
    if IsVehicleExtraTurnedOn(data.vehicle, data.extraid) then
        QBCore.Functions.Notify(data.extraid .. Config.Locals['Notifications']['GeneralNotifications']['ExtraTurnedOff'])
        SetVehicleExtra(data.vehicle, data.extraid, 1)
        TriggerEvent("CL-PoliceGarageV2:OpenExtrasMenu", Data)
    else
        QBCore.Functions.Notify(data.extraid .. Config.Locals['Notifications']['GeneralNotifications']['ExtraTurnedOn'])
        SetVehicleExtra(data.vehicle, data.extraid, 0)
        TriggerEvent("CL-PoliceGarageV2:OpenExtrasMenu", Data)
    end
end)

RegisterNetEvent("CL-PoliceGarageV2:StartPreview", function(data)
    local player = PlayerPedId()
    if QBCore.Functions.SpawnClear(vector3(data.coordsinfo['PreviewSpawn'].x, data.coordsinfo['PreviewSpawn'].y, data.coordsinfo['PreviewSpawn'].z), data.coordsinfo['CheckRadius']) then
        if not IsCamActive(VehicleCam) then
            QBCore.Functions.SpawnVehicle(data.vehicle, function(veh)
                SetEntityVisible(player, false, 1)
                if Config.SetVehicleTransparency == 'low' then
                    SetEntityAlpha(veh, 200)
                elseif Config.SetVehicleTransparency == 'medium' then
                    SetEntityAlpha(veh, 150)
                elseif Config.SetVehicleTransparency == 'high' then
                    SetEntityAlpha(veh, 100)
                elseif Config.SetVehicleTransparency == 'none' then
                    SetEntityAlpha(veh, 255)
                end
                FreezeEntityPosition(player, true)
                SetVehicleNumberPlateText(veh, FormatString(data.station)..tostring(math.random(1000, 9999)))
                exports[Config.FuelSystem]:SetFuel(veh, 0.0)
                SetVehicleDirtLevel(veh, 0.0)
                FreezeEntityPosition(veh, true)
                SetVehicleModKit(vehicle, 0)
                SetEntityCollision(veh, false, true)
                SetVehicleEngineOn(veh, false, false)
                if data.extras then
                    for i = 0, 13 do
                        if DoesExtraExist(veh, i) then
                            SetVehicleExtra(veh, i, 1)
                        end
                    end                        
                    for i = 1, #data.extras do
                        local extra = data.extras[i]
                        if DoesExtraExist(veh, extra) then
                            SetVehicleExtra(veh, extra, 0)
                        end
                    end
                end
                if data.liveries then
                    local matchedLivery = nil
                    for k, v in pairs(data.liveries) do
                        if job and (PlayerData.job.grade.level >= v.RankRequired or (PlayerData.gang and PlayerData.gang.grade.level >= v.RankRequired)) then
                            if not matchedLivery then
                                matchedLivery = v
                            end
                        end
                    end
                    if matchedLivery then
                        SetVehicleLivery(veh, matchedLivery.LiveryID)
                    end
                end
                if data.colors then
                    if data.colors.PrimaryColor then SetVehicleCustomPrimaryColour(veh, data.colors.PrimaryColor.R, data.colors.PrimaryColor.G, data.colors.PrimaryColor.B) end
                    if data.colors.SecondaryColor then SetVehicleCustomSecondaryColour(veh, data.colors.SecondaryColor.R, data.colors.SecondaryColor.G, data.colors.SecondaryColor.B) end
                end
                DoScreenFadeOut(200)
                Citizen.Wait(500)
                SetVehicleUndriveable(veh, true)
                local camRadius = 5.0 
                local camAngle = 0.0 
                local camX = data.coordsinfo['PreviewSpawn'].x + camRadius * math.cos(camAngle)
                local camY = data.coordsinfo['PreviewSpawn'].y + camRadius * math.sin(camAngle)
                local camZ = data.coordsinfo['PreviewSpawn'].z + 1.0 
                if data.coordsinfo['CameraInformation']['CinematicCamera'] then
                    SetTimecycleModifier('MP_Arena_theme_night')
                    SetTimecycleModifierStrength(1.0)
                    VehicleCam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", camX, camY, camZ, 0.0, 0.0, 0.0, data.coordsinfo['CameraInformation']['CameraFOV'], false, 0)
                else
                    VehicleCam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", data.coordsinfo['CameraInformation']['CameraCoords'].x, data.coordsinfo['CameraInformation']['CameraCoords'].y, data.coordsinfo['CameraInformation']['CameraCoords'].z, data.coordsinfo['CameraInformation']['CameraRotation'].x, data.coordsinfo['CameraInformation']['CameraRotation'].y, data.coordsinfo['CameraInformation']['CameraCoords'].w, data.coordsinfo['CameraInformation']['CameraFOV'], false, 0)
                end
                Citizen.Wait(200)
                DoScreenFadeIn(200)
                SetCamActive(VehicleCam, true)
                RenderScriptCams(true, false, 0, true, true)
                Citizen.CreateThread(function()
                    while IsCamActive(VehicleCam) do
                        if data.coordsinfo['CameraInformation']['CinematicCamera'] then
                            camAngle = camAngle + 0.005
                            camX = data.coordsinfo['PreviewSpawn'].x + camRadius * math.cos(camAngle)
                            camY = data.coordsinfo['PreviewSpawn'].y + camRadius * math.sin(camAngle)
                            SetCamCoord(VehicleCam, camX, camY, camZ)
                            PointCamAtEntity(VehicleCam, veh)
                        end
                        ShowHelpNotification("~INPUT_PICKUP~ to confirm your purchase. ~INPUT_CELLPHONE_CANCEL~ To cancel")
                        if IsControlJustReleased(0, 177) then
                            SetTimecycleModifier('default')
                            SetEntityVisible(player, true, 1)
                            FreezeEntityPosition(player, false)
                            PlaySoundFrontend(-1, "NO", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                            QBCore.Functions.DeleteVehicle(veh)
                            DoScreenFadeOut(200)
                            Citizen.Wait(500)
                            DoScreenFadeIn(200)
                            SetCamActive(VehicleCam, false)
                            RenderScriptCams(false, false, 1, true, true)
                            local Data = {
                                userent = data.userent,
                                rentvehicles = data.rentvehicles,
                                purchasevehicles = data.purchasevehicles,
                                coordsinfo = data.coordsinfo,
                                rjob = data.job,
                                rgang = data.gang,
                                station = data.station,
                                useownable = data.useownable,
                                useextras = data.useextras,
                                usepurchasable = data.usepurchasable,
                                useliveries = data.useliveries,
                            }
                            TriggerEvent("CL-PoliceGarageV2:OpenMainMenu", Data)
                            break
                        end
                        if IsControlJustReleased(0, 38) then
                            SetTimecycleModifier('default')
                            SetEntityVisible(player, true, 1)
                            FreezeEntityPosition(player, false)
                            PlaySoundFrontend(-1, "NO", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                            QBCore.Functions.DeleteVehicle(veh)
                            DoScreenFadeOut(200)
                            Citizen.Wait(500)
                            DoScreenFadeIn(200)
                            SetCamActive(VehicleCam, false)
                            RenderScriptCams(false, false, 1, true, true)
                            TriggerEvent("CL-PoliceGarageV2:ChoosePayment", {
                                price = data.price,
                                vehiclename = data.vehiclename,
                                vehicle = data.vehicle,
                                coordsinfo = data.coordsinfo,
                                job = data.job,
                                gang = data.gang,
                                station = data.station,
                                rank = data.rank,
                                useownable = data.useownable,
                                trunkitems = data.trunkitems,
                                colors = data.colors,
                                extras = data.extras,
                                liveries = data.liveries,
                            })
                            break
                        end
                        Citizen.Wait(1)
                    end
                end)
            end, data.coordsinfo['PreviewSpawn'], true, false)
        end
    else
        QBCore.Functions.Notify(Config.Locals["Notifications"]['GeneralNotifications']["VehicleInSpawn"], "error")
    end
end)

RegisterNetEvent("CL-PoliceGarageV2:ChooseRent", function(data)
    local minutes = exports["qb-input"]:ShowInput({
        header = "Enter Number Of Minutes",
        submitText = "Submit",
        inputs = {
            {
                text = 'Minutes',
                name = 'minutes',
                type = 'number',
                isRequired = true,
            }
        }
    })
    if minutes ~= nil then
        local minutesamount = tonumber(minutes.minutes)
        if minutesamount > 0 and minutesamount <= Config.RentMaximum then
            local paymentType = exports["qb-input"]:ShowInput({
                header = "Choose Payment Type",
                submitText = "Submit",
                inputs = {
                    {
                        text = 'Payment Type',
                        name = 'paymenttype',
                        type = 'radio',
                        isRequired = true,
                        options = {
                            {
                                value = "cash",
                                text = "Cash"
                            },
                            {
                                value = "bank",
                                text = "Bank"
                            }
                        }
                    }
                }
            })
            if paymentType ~= nil then
                local finalPrice = (minutes.minutes * data.price)
                local price = exports["qb-input"]:ShowInput({
                    header = "Final Price",
                    submitText = "Rent",
                    inputs = {
                        {
                            text = 'Final Price: $' .. finalPrice,
                            name = 'finalprice',
                            type = 'checkbox',
                            options = {
                                { 
                                    value = "agree", 
                                    text = "Confirm Price",
                                    checked = true,
                                },
                            }
                        }
                    }
                })
                if price ~= nil then
                    TriggerServerEvent("CL-PoliceGarageV2:RentVehicle", paymentType.paymenttype, finalPrice, data.vehiclename, data.vehicle, minutes.minutes, data.coordsinfo, data.job, data.gang, data.station)
                end
            end
        else
            QBCore.Functions.Notify("Invalid amount ! minutes must to be more then 0 and less then " .. Config.RentMaximum .. ". Minutes choosen " .. minutes.minutes, "error")
        end
    end
end)

RegisterNetEvent("CL-PoliceGarageV2:ChoosePayment", function(data)
    local paymentOptions = {
        {
            value = "cash",
            text = "Cash"
        },
        {
            value = "bank",
            text = "Bank"
        },
    } 
    if data.job and PlayerData.job.isboss and Config.CompanyFunds['Enable'] then
        table.insert(paymentOptions, {
            value = "company",
            text = "Company Funds"
        })
    end
    local paymentType = exports["qb-input"]:ShowInput({
        header = "Choose Payment Type",
        submitText = "Submit",
        inputs = {
            {
                text = 'Payment Type',
                name = 'paymenttype',
                type = 'radio',
                isRequired = true,
                options = paymentOptions,
            },
        },
    })
    if paymentType ~= nil then
        local price = exports["qb-input"]:ShowInput({
            header = "Price",
            submitText = "Purchase",
            inputs = {
                {
                    text = 'Price: $' .. data.price,
                    name = 'finalprice',
                    type = 'checkbox',
                    options = {
                        { 
                            value = "agree", 
                            text = "Confirm Price",
                            checked = true,
                        },
                    }
                }
            }
        })
        if price ~= nil and paymentType.paymenttype == "company" and data.job and PlayerData.job.isboss and Config.CompanyFunds['Enable'] then
            TriggerEvent("CL-PoliceGarageV2:OpenNearMenu", {
                paymenttype = paymentType.paymenttype, 
                price = data.price,
                vehiclename = data.vehiclename,
                vehicle = data.vehicle,
                coordsinfo = data.coordsinfo,
                job = data.job,
                gang = data.gang,
                station = data.station,
                rank = data.rank,
                useownable = data.useownable,
                trunkitems = data.trunkitems,
                extras = data.extras,
                colors = data.colors,
                liveries = data.liveries,
            })
        else
            if price ~= nil then
                TriggerServerEvent("CL-PoliceGarageV2:BuyVehicle", {
                    paymenttype = paymentType.paymenttype, 
                    price = data.price,
                    vehiclename = data.vehiclename,
                    vehicle = data.vehicle,
                    coordsinfo = data.coordsinfo,
                    job = data.job,
                    gang = data.gang,
                    station = data.station,
                    useownable = data.useownable,
                    extras = data.extras,
                    trunkitems = data.trunkitems,
                    liveries = data.liveries,
                    colors = data.colors,
                })
            end
        end
    end
end)