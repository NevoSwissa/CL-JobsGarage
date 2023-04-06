Config = {}

Config.UseLogs = false -- Set to true to enable discord logs, using default QBCore logs system

Config.BanWhenExploit = false -- Set to true if you want to ban players / cheaters (Just another safety system)

Config.DepotFine = 100 -- The amount of money the player needs to pay for depot, set to nil to disable

Config.AutoRespawn = false -- Set to true if you want all the vehicles to auto resspawn at the available vehicles (If false, checks for missing vehicles to put in the vehicle depot)

Config.CompanyFunds = {
    Enable = false, -- Set to false to disable the company funds feature (Havent been tested completely. NOT recommended to use)
    CheckDistance = 10.0, -- The radius that the script checks for nearby players (If Enable)
}

Config.UseBlips = true -- Set to false to disable all script blips

Config.RentMaximum = 60 -- The rent maximum allowed in minutes

Config.Target = "qb-target" -- The name of your target

Config.FuelSystem = "LegacyFuel" -- The fuel system, LegacyFuel by default

Config.SetVehicleTransparency = 'none' -- The vehicle transparency level for the preview. Options : low, medium, high, none

Config.Locals = {
    Targets = {
        GarageTarget = {
            Icon = "fa fa-list fa-bounce",
            Label = "Open Garage - ",  
        },

        MainTarget = {
            Distance = 5.0,
            Icon = "fa fa-car fa-bounce",
            Label = "Vehicles - ",  
        },
    },

    Notifications = {
        RentOver = "The rent time for ",
        RentWarning = "Return the vehicle or it will get deleted ! vehicle ",
        NoRentedVehicle = "There are no rented vehicles on your name",
        NoMoney = "You dont have enough money",
        VehicleReturned = "Vehicle returned. Vehicle ",
        SuccessfullyRented = " successfully rented for ",
        SuccessfullyBought = " successfully bought from ",
        NotDriver = "You must be the driver !",
        ExtraTurnedOn = " vehicle extra successfully got turned on",
        VehicleOccupied = "Vehicle is occupied",
        NotOwner = "You are not the owner of the vehicle",
        NoFunds = "There isnt enough funds for ",
        SuccessfullyStored = "You have successfully stored your vehicle at ",
        VehicleFixed = "Your vehicle successfully got fixed",
        ErrorStoring = "Error occured while storing vehicle",
        NoVehicles = "No vehicles were found at ",
        ExtraTurnedOff = " vehicle extra successfully got turned off",
        NoJob = " doesnt have the correct job",
        NoRank = " doesnt have the correct required rank",
        VehicleInSpawn = 'Theres a vehicle in the spawn area !',
        NotInVehicle = "You are not in any vehicle !",
        LiverySet = "Vehicle livery has been successfully set to ",
        LeftVehicle = "You have left the vehicle",
        IncorrectVehicle = "Incorrect vehicle ! you rented "
    },
}

Config.Locations = {
    Stations = {
        ["MRPD"] = { -- Full template, inculdes all script features (The string is the garage name used as the station / garage name)
            UseRent = true, -- Set to false to disable the rent feature for this station (Garage WONT WORK if UseRent and UsePurchasable are set to false)
            UseOwnable = true, -- Set to false to disable ownable vehicles (If set to true vehicles can be stored inside the script garage)
            UseExtras = true, -- Set to false to disable the extras feature
            UsePurchasable = true, -- Set to false to disable purchasable vehicles (Garage WONT WORK if both UseRent and UsePurchasable are set to false)
            UseLiveries = true, -- Set to false to disable the livery feature
            JobRequired = "police", -- The job required for this station garage; For 1 job use, for multiple jobs JobRequired = {"job1", "job2"}, for all job use JobRequired = "all"
            VehiclesInformation = {
                RentVehicles = { -- Rent vehicles information, if UseRent set to true as : UseRent = true
                    ["Bati"] = {
                        Vehicle = "bati", -- The vehicle to spawn
                        PricePerMinute = 50, -- The price to charge for that vehicle every minute
                    }, 
                },
                PurchaseVehicles = { -- Purchasable vehicles, make sure you have the vehicle information set in qb-core > shared > vehicles.lua
                    ["Police Vehicle 1"] = {
                        Vehicle = "police", -- The vehicle to spawn
                        TotalPrice = 5000, -- The total price it costs to buy this vehicle
                        Rank = 1, -- The rank required to purchase this vehicle. Set to 0 to enable all ranks
                        VehicleSettings = { -- Everthing inside those brackets is totally optional (For things you dont want to use simply remove)
                            DefaultExtras = { 1, 2 }, -- Default extras that the vehicle will spawn with the numbers to represent the vehicle extra id (Keep empty to remove all extras or delete to disable this feature)
                            DefaultLiveries = { -- Default liveries that the player would be spawned if the player have the required rank.
                                ["Supervisor"] = { -- The livery name for example : Supervisor, patrol ghost etc
                                    RankRequired = 0, -- The minimum required rank for this livery
                                    LiveryID = 1, -- The livery id
                                },                 
                                ["Patrol"] = { -- The livery name for example : Supervisor, patrol ghost etc
                                    RankRequired = 2, -- The minimum required rank for this livery
                                    LiveryID = 5, -- The livery id
                                },
                            },
                            TrunkItems = { -- Trunk items the vehicle would spawn with
                                [1] = {
                                    name = "heavyarmor",
                                    amount = 2,
                                    info = {},
                                    type = "item",
                                    slot = 1,
                                },
                            },
                        },
                    }, 
                    ["Police Vehicle 2"] = {
                        Vehicle = "police2", -- The vehicle to spawn
                        TotalPrice = 0, -- The total price it costs to buy this vehicle
                        Rank = 0, -- The rank required to purchase this vehicle. Set to 0 to enable all ranks
                        VehicleSettings = { -- Everthing inside those brackets is totally optional
                            -- Example of how it should look like if you dont want to use any of those features
                        },
                    }, 
                },
                SpawnCoords = {
                    VehicleSpawn = vector4(438.42324, -1021.07, 28.677057, 101.4219), -- Vehicle spawn and vehicle clear check coords
                    PreviewSpawn = vector4(453.6509, -1023.771, 28.494075, 62.526172), -- Preview vehicle spawn coords
                    CheckRadius = 5.0, -- The radius the script checks for vehicle
                    CameraInformation = {
                        CameraCoords = vector3(447.5325, -1020.384, 30.494419), -- Vehicle preview camera coords
                        CameraRotation = vector3(-10.00, 0.00, 240.494419), -- Vehicle preview camera rotation coords
                        CameraFOV = 80.0, -- The vehicle preview camera fov value
                    },
                },
            },
            GeneralInformation = {
                Blip = { -- Blip information
                    BlipId = 357, -- The blip id. More can be found at : https://docs.fivem.net/docs/game-references/blips/
                    BlipColour = 2, -- The blip colour. More can be found at : https://docs.fivem.net/docs/game-references/blips/
                    BlipScale = 0.4, -- The blip scale
                    Title = "MRPD - Garage" -- The blip title string
                },
                TargetInformation = { -- This is the required information for the target
                    Ped = "a_m_y_smartcaspat_01", -- The ped model. More models can be found at : https://docs.fivem.net/docs/game-references/ped-models/
                    Coords = vector4(459.05987, -1017.118, 27.153299, 96.337463), -- The ped coords
                    Scenario = "WORLD_HUMAN_CLIPBOARD", -- Ped scenario. More can be found at : https://wiki.rage.mp/index.php?title=Scenarios
                },
            },  
        },
        ["EMS"] = { -- Full template, inculdes all script features (The string is the garage name used as the station / garage name)
            UseRent = false, -- Set to false to disable the rent feature for this station (Garage WONT WORK if UseRent and UsePurchasable are set to false)
            UseOwnable = true, -- Set to false to disable ownable vehicles (If set to true vehicles can be stored inside the script garage)
            UseExtras = false, -- Set to false to disable the extras feature
            UsePurchasable = true, -- Set to false to disable purchasable vehicles (Garage WONT WORK if both UseRent and UsePurchasable are set to false)
            UseLiveries = true, -- Set to false to disable the livery feature
            JobRequired = "ambulance", -- The job required for this station garage; For 1 job use, for multiple jobs JobRequired = {"job1", "job2"}, for all job use JobRequired = "all"
            VehiclesInformation = {
                PurchaseVehicles = { -- Purchasable vehicles, make sure you have the vehicle information set in qb-core > shared > vehicles.lua
                    ["Ambulance"] = {
                        Vehicle = "ambulance", -- The vehicle to spawn
                        TotalPrice = 2500, -- The total price it costs to buy this vehicle
                        Rank = 0, -- The rank required to purchase this vehicle. Set to 0 to enable all ranks
                        VehicleSettings = { -- Everthing inside those brackets is totally optional (For things you dont want to use simply remove)
                            TrunkItems = { -- Trunk items the vehicle would spawn with
                                [1] = {
                                    name = "bandage",
                                    amount = 10,
                                    info = {},
                                    type = "item",
                                    slot = 1,
                                },
                            },
                        },
                    }, 
                },
                SpawnCoords = {
                    VehicleSpawn = vector4(329.83569, -558.4447, 28.743787, 68.21807), -- Vehicle spawn and vehicle clear check coords
                    PreviewSpawn = vector4(329.83569, -558.4447, 28.743787, 68.21807), -- Preview vehicle spawn coords
                    CheckRadius = 5.0, -- The radius the script checks for vehicle
                    CameraInformation = {
                        CameraCoords = vector3(317.73193, -554.0252, 31.443788), -- Vehicle preview camera coords
                        CameraRotation = vector3(-10.00, 0.00, 251.38), -- Vehicle preview camera rotation coords
                        CameraFOV = 80.0, -- The vehicle preview camera fov value
                    },
                },
            },
            GeneralInformation = {
                Blip = { -- Blip information
                    BlipId = 357, -- The blip id. More can be found at : https://docs.fivem.net/docs/game-references/blips/
                    BlipColour = 2, -- The blip colour. More can be found at : https://docs.fivem.net/docs/game-references/blips/
                    BlipScale = 0.4, -- The blip scale
                    Title = "EMS - Garage" -- The blip title string
                },
                TargetInformation = { -- This is the required information for the target
                    Ped = "a_m_y_smartcaspat_01", -- The ped model. More models can be found at : https://docs.fivem.net/docs/game-references/ped-models/
                    Coords = vector4(333.86819, -561.9299, 27.743787, 347.48379), -- The ped coords
                    Scenario = "WORLD_HUMAN_CLIPBOARD", -- Ped scenario. More can be found at : https://wiki.rage.mp/index.php?title=Scenarios
                },
            },  
        },
    },
}