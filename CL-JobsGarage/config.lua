Config = {}

Config.VisuallyDamageCars = true -- Set this to false if you dont want cars to have visual damage

Config.UseLogs = false -- Set to true to enable Discord logs using the default QBCore logs system. Make sure to set at qb-smallresources > server > logs.lua > Webhooks

Config.BanWhenExploit = false -- Set to true to ban players/cheaters (a safety feature).

Config.ShowMarker = true -- Set to false to disable markers which indicates available parking spots

Config.DepotFine = 100 -- The amount of money the player needs to pay for depot. Set to nil to disable.

Config.VehicleKeys = "default" -- The vehicle keys resource, if you are using the qb-vehiclekeys by sna use : Config.VehicleKeys = "qb-vehiclekeys"

Config.AutoRespawn = false -- Set to true to enable automatic respawn for all vehicles at available vehicles. If set to false, the script checks for missing vehicles to put in the vehicle depot.

Config.CompanyFunds = {
    Enable = true, -- Set to false to disable the company funds feature (haven't been tested completely; not recommended to use). If enabled, the script checks for nearby - players within a specified radius.
    CheckDistance = 10.0, -- The radius that the script checks for nearby players (If Enable)
}

Config.RentMaximum = 60 -- The rent maximum allowed in minutes.

Config.Target = "qb-target" -- The name of your target.

Config.FuelSystem = "LegacyFuel" -- The fuel system. The default value is LegacyFuel.

Config.SetVehicleTransparency = 'none' -- The vehicle transparency level for the preview. The available options are low, medium, high, and none.

Config.Locals = { -- Contains various notification messages that the script uses. You can edit these messages to suit your needs.
    Targets = { -- DO NOT delete those, they are used both for targets & markers
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
        GeneralNotifications = { 
            NotInVehicle = "You are not in any vehicle !",
            NoMoney = "You dont have enough money",
            NoFunds = "There isnt enough funds for ",
            NotDriver = "You must be the driver of the vehicle",
            HasDeleted = " has been deleted",
            NoJob = " doesnt have the correct job",
            NoRank = " doesnt have the correct required rank",
            LeftVehicle = "You have left the vehicle",
            SuccessfullyBought = " successfully bought from ",
            VehicleInSpawn = 'Theres a vehicle in the spawn area !',
            ExtraTurnedOn = " vehicle extra successfully got turned on",
            ExtraTurnedOff = " vehicle extra successfully got turned off",
            LiverySet = "Vehicle livery has been successfully set to ",
        },
        RentNotifications = {
            RentOver = "The rent time for ",
            RentWarning = "Return the vehicle or it will get deleted ! vehicle ",
            NoRentedVehicle = "There are no rented vehicles on your name",
            VehicleReturned = "Vehicle returned. Vehicle ",
            SuccessfullyRented = " successfully rented for ",
            IncorrectVehicle = "Incorrect vehicle ! you rented "
        },
        GarageNotifications = {
            VehicleOccupied = "Vehicle is occupied",
            SuccessfullyStored = "You have successfully stored your vehicle at ",
            ErrorStoring = "An error occured while storing vehicle",
            NotOwner = "You are not the owner of the vehicle",
            InVehicle = "You cannot be inside a vehicle while taking vehicle",
            TakeOut = "Taking out ",
            NoVehicles = "No vehicles were found at ",
        },
    },
}

Config.Locations = { -- Contains information about the stations/garages available in the game. You can configure each station/garage's features and requirements here.
    Stations = {
        ["MRPD"] = { -- Used for the station name. This is a full template, inculdes all the available script features. 
            UseRent = true, -- Set to false to disable the rent feature for this station (Garage WONT work if both UseRent and UsePurchasable are set to false)
            UseTarget = true, -- Set to false to disable the use of target. If set to false UseMarker must be on
            UseMarker = false, -- Set to true to enable the use of GTA V markers
            UseBlip = true, -- Set to false to disable blips for this garage
            UsePolyZone = true, -- Set to false to not use the polyzone system. Cant be used if UseMarker only with UseTarget
            UseOwnable = true, -- Set to false to disable ownable vehicles (If set to true vehicles can be stored inside the script garage system)
            UseExtras = true, -- Set to false to disable the extras feature
            UseLiveries = true, -- Set to false to disable the livery feature
            UsePurchasable = true, -- Set to false to disable purchasable vehicles (Garage WONT WORK if both UseRent and UsePurchasable are set to false)
            JobRequired = "police", -- The job required for this station garage; For 1 job use, for multiple jobs JobRequired = {"job1", "job2"}, for all job use JobRequired = "all" (GangRequired and JobRequired cant be used together, only each)
            GangRequired = nil, -- The gang required for accesing the garage, for multiple gangs GangRequired = {"gang1", "gang2"}, for all gangs, GangRequired = "all" (GangRequired and JobRequired cant be used together, only each)
            VehiclesInformation = {
                RentVehicles = { -- Rent vehicles information, if UseRent set to true
                    ["Bati"] = { -- The vehicle name
                        Vehicle = "bati", -- The vehicle to spawn
                        PricePerMinute = 50, -- The price to charge for that vehicle every minute
                    }, 
                },
                PurchaseVehicles = { -- Purchasable vehicles list, this will be shown for the players when buying the vehicles (Gets sorted by rank)
                    ["Police Vehicle 1"] = { -- The vehicle name
                        Vehicle = "police", -- The vehicle model to spawn
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
                    ["Police Vehicle 2"] = { -- The vehicle name
                        Vehicle = "police2", -- The vehicle model to spawn
                        TotalPrice = 0, -- The total price it costs to buy this vehicle
                        Rank = 0, -- The rank required to purchase this vehicle. Set to 0 to enable all ranks
                        VehicleSettings = { -- Everthing inside those brackets is totally optional
                            -- Example of how it should look like if you dont want to use any of the optional features
                        },
                    }, 
                },
                SpawnCoords = {
                    VehicleSpawn = vector4(438.42324, -1021.07, 28.677057, 101.4219), -- Vehicle spawn and vehicle clear check coords
                    PreviewSpawn = vector4(453.6509, -1023.771, 28.494075, 62.526172), -- Preview vehicle spawn coords
                    CheckRadius = 5.0, -- The radius the script checks for vehicle
                    CameraInformation = {
                        CinematicCamera = true, -- Set to false to disable the cinematic experimental features
                        CameraCoords =vector4(448.32427, -1021.859, 29.370603, 244.79725), -- Vehicle preview camera coords
                        CameraRotation = vector2(-10.00, 0.00), -- Vehicle preview camera rotation coords
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
                TargetInformation = { -- This is the required information for the target, if UseTarget
                    Ped = "a_m_y_smartcaspat_01", -- The ped model. More models can be found at : https://docs.fivem.net/docs/game-references/ped-models/
                    Coords = vector4(459.05987, -1017.118, 27.153299, 96.337463), -- The target ped coords
                    Scenario = "WORLD_HUMAN_CLIPBOARD", -- Ped scenario. More can be found at : https://wiki.rage.mp/index.php?title=Scenarios
                },
                MarkerInformation = { -- This is the required information for the markers if not UseTarget and UseMarker
                    MarkerType = 36, -- The marker type, more can be found at : https://docs.fivem.net/docs/game-references/markers/
                    MarkerColor = { R = 255, G = 0, B = 0 }, -- the markers colors, in RGB format. https://g.co/kgs/Mw5Cvr
                    MarkerCoords = {
                        GarageCoords = vector3(445.82296, -1026.48, 28.657045), -- If UseOwanble then those are the coords for the garage system
                        MainCoords = vector3(440.14831, -1022.806, 28.639863), -- Main coords used for the buying systems
                    },
                },
                PolyZoneInformation = { -- Polyzone information used as another way of storing vehicles if UsePolyZone (Optional)
                    MinZ = 27.421812, -- The min z of the polyzone, to simplify this simply take the regular Z and remove 1 digit down so 28.000 becomes 27.000
                    MaxZ = 29.421812, -- The max z of the polyzone, you can use the same guide of min z but instead if removing 1 digit you add 1 digit or more
                    DeBug = false, -- Whether or not you want to see the polyzone area to debug it
                    ShapeCoords = { -- The polyzone shape coords
                        vector2(453.35833, -1027.797),
                        vector2(418.50686, -1032.144),
                        vector2(418.08459, -1013.168),
                        vector2(454.54699, -1012.537),
                        vector2(455.52462, -1015.312),
                        vector2(453.37686, -1015.38),
                    },
                    ParkingCoords = { -- The available parking spots where players can park their vehicles
                        vector4(446.15713, -1026.372, 28.648468, 0.4473383),
                        vector4(442.5509, -1026.742, 28.716072, 7.8221173),
                        vector4(438.61431, -1027.004, 28.788122, 8.4917039),
                        vector4(435.01953, -1027.465, 28.852371, 6.7766904),
                        vector4(431.26406, -1028.318, 28.921388, 11.744531),
                        vector4(427.43572, -1028.458, 28.988609, 12.988303),
                    },
                },
            },  
        },
        ["EMS"] = { -- Used for the station name. This is a partial template, inculdes all the available script features. 
            UseRent = false, 
            UseTarget = true, 
            UseMarker = false, 
            UseBlip = true, 
            UsePolyZone = true,
            UseOwnable = true, 
            UseExtras = false, 
            UseLiveries = false,
            UsePurchasable = true,
            JobRequired = "ambulance", 
            GangRequired = nil, 
            VehiclesInformation = {
                PurchaseVehicles = {
                    ["Ambulance"] = {
                        Vehicle = "ambulance",
                        TotalPrice = 1000,
                        Rank = 0,
                        VehicleSettings = {
                            
                        },
                    }, 
                },
                SpawnCoords = {
                    VehicleSpawn = vector4(329.28829, -558.4303, 28.743787, 70.877746), 
                    PreviewSpawn = vector4(329.28829, -558.4303, 28.743787, 70.877746),
                    CheckRadius = 5.0,
                    CameraInformation = {
                        CinematicCamera = false, -- Set to false to disable the cinematic experimental features
                        CameraCoords = vector4(321.35797, -555.5802, 29.973787, 250.24),
                        CameraRotation = vector2(-10.00, 0.00),
                        CameraFOV = 80.0,
                    },
                },
            },
            GeneralInformation = {
                Blip = {
                    BlipId = 357,
                    BlipColour = 1,
                    BlipScale = 0.4,
                    Title = "EMS - Garage"
                },
                TargetInformation = {
                    Ped = "a_m_y_smartcaspat_01", 
                    Coords = vector4(333.88748, -561.8899, 27.743787, 346.48941), 
                    Scenario = "WORLD_HUMAN_CLIPBOARD", 
                },
                PolyZoneInformation = {
                    MinZ = 27.021812,
                    MaxZ = 30.421812,
                    DeBug = false,
                    ShapeCoords = {
                        vector2(322.56213, -558.0889),
                        vector2(316.97164, -560.9205),
                        vector2(311.26882, -558.9225),
                        vector2(311.0632, -551.6613),
                        vector2(313.00942, -551.3738),
                        vector2(313.32418, -538.32),
                        vector2(351.0184, -538.0444),
                        vector2(351.14306, -549.851),
                        vector2(345.06091, -566.0043),
                        vector2(335.00933, -562.6275),
                        vector2(336.39306, -558.5799),
                        vector2(334.50073, -557.8605),
                        vector2(333.0198, -562.1729),
                        vector2(323.62292, -558.8275),
                    },
                    ParkingCoords = {
                        vector4(315.54867, -556.4597, 28.743772, 268.10595),
                        vector4(315.51174, -553.5211, 28.743772, 275.60592),
                        vector4(315.77557, -550.6575, 28.743772, 270.60595),
                        vector4(315.55709, -547.8922, 28.743772, 265.60592),
                        vector4(315.66152, -545.1126, 28.743772, 270.60595),
                        vector4(320.93991, -541.0415, 28.743772, 183.10598),
                        vector4(323.84295, -541.1699, 28.743772, 178.10595),
                        vector4(326.47048, -541.0938, 28.743772, 175.60594),
                        vector4(329.33407, -541.4165, 28.743772, 178.10595),
                        vector4(332.28247, -541.2338, 28.743772, 173.10598),
                        vector4(335.02102, -540.9603, 28.743772, 183.10598),
                    },
                },
            },  
        },

        -- Pre-configured Gangs garages you can use

        ["Vagos"] = { -- Used for the station name. This is a full template, inculdes all the available script features. 
            UseRent = true, -- Set to false to disable the rent feature for this station (Garage WONT work if both UseRent and UsePurchasable are set to false)
            UseTarget = true, -- Set to false to disable the use of target. If set to false UseMarker must be on
            UseMarker = false, -- Set to true to enable the use of GTA V markers
            UseBlip = true, -- Set to false to disable blips for this garage
            UsePolyZone = true, -- Set to false to not use the polyzone system
            UseOwnable = true, -- Set to false to disable ownable vehicles (If set to true vehicles can be stored inside the script garage system)
            UseExtras = true, -- Set to false to disable the extras feature
            UseLiveries = false, -- Set to false to disable the livery feature
            UsePurchasable = true, -- Set to false to disable purchasable vehicles (Garage WONT WORK if both UseRent and UsePurchasable are set to false)
            JobRequired = nil, -- The job required for this station garage; For 1 job use, for multiple jobs JobRequired = {"job1", "job2"}, for all job use JobRequired = "all" (GangRequired and JobRequired cant be used together, only each)
            GangRequired = "vagos", -- The gang required for accesing the garage, for multiple gangs GangRequired = {"gang1", "gang2"}, for all gangs, GangRequired = "all" (GangRequired and JobRequired cant be used together, only each)
            VehiclesInformation = {
                RentVehicles = { -- Rent vehicles information, if UseRent set to true
                    ["Avarus"] = { -- The vehicle name
                        Vehicle = "avarus", -- The vehicle to spawn
                        PricePerMinute = 75, -- The price to charge for that vehicle every minute
                    }, 
                    ["BF-400"] = { -- The vehicle name
                        Vehicle = "bf400", -- The vehicle to spawn
                        PricePerMinute = 100, -- The price to charge for that vehicle every minute
                    }, 
                },
                PurchaseVehicles = { -- Purchasable vehicles list, this will be shown for the players when buying the vehicles (Gets sorted by rank)
                    ["Hermes"] = { -- The vehicle name
                        Vehicle = "hermes", -- The vehicle model to spawn
                        TotalPrice = 5000, -- The total price it costs to buy this vehicle
                        Rank = 0, -- The rank required to purchase this vehicle. Set to 0 to enable all ranks
                        VehicleSettings = { -- Everthing inside those brackets is totally optional
                            DefaultColors = { -- Default vehicle colors of which the vehicle would get spawned with
                                PrimaryColor = { R = 252, G = 186, B = 3 }, -- Primary color, R = red, G = green, B = blue. https://g.co/kgs/Mw5Cvr
                                SecondaryColor = { R = 252, G = 186, B = 3 }, -- Secondary color, R = red, G = green, B = blue. https://g.co/kgs/Mw5Cvr
                            }
                        },
                    }, 
                    ["Tornado"] = { -- The vehicle name
                        Vehicle = "tornado", -- The vehicle model to spawn
                        TotalPrice = 1000, -- The total price it costs to buy this vehicle
                        Rank = 0, -- The rank required to purchase this vehicle. Set to 0 to enable all ranks
                        VehicleSettings = { -- Everthing inside those brackets is totally optional
                            DefaultColors = { -- Default vehicle colors of which the vehicle would get spawned with
                                PrimaryColor = { R = 252, G = 186, B = 3 }, -- Primary color, R = red, G = green, B = blue. https://g.co/kgs/Mw5Cvr
                                SecondaryColor = { R = 252, G = 186, B = 3 }, -- Secondary color, R = red, G = green, B = blue. https://g.co/kgs/Mw5Cvr
                            }
                        },
                    }, 
                    ["Voodoo"] = { -- The vehicle name
                        Vehicle = "voodoo", -- The vehicle model to spawn
                        TotalPrice = 7500, -- The total price it costs to buy this vehicle
                        Rank = 1, -- The rank required to purchase this vehicle. Set to 0 to enable all ranks
                        VehicleSettings = { -- Everthing inside those brackets is totally optional
                            DefaultColors = { -- Default vehicle colors of which the vehicle would get spawned with
                                PrimaryColor = { R = 252, G = 186, B = 3 }, -- Primary color, R = red, G = green, B = blue. https://g.co/kgs/Mw5Cvr
                                SecondaryColor = { R = 252, G = 186, B = 3 }, -- Secondary color, R = red, G = green, B = blue. https://g.co/kgs/Mw5Cvr
                            }
                        },
                    }, 
                    ["Phoenix"] = { -- The vehicle name
                        Vehicle = "phoenix", -- The vehicle model to spawn
                        TotalPrice = 15000, -- The total price it costs to buy this vehicle
                        Rank = 2, -- The rank required to purchase this vehicle. Set to 0 to enable all ranks
                        VehicleSettings = { -- Everthing inside those brackets is totally optional
                            DefaultColors = { -- Default vehicle colors of which the vehicle would get spawned with
                                PrimaryColor = { R = 252, G = 186, B = 3 }, -- Primary color, R = red, G = green, B = blue. https://g.co/kgs/Mw5Cvr
                                SecondaryColor = { R = 252, G = 186, B = 3 }, -- Secondary color, R = red, G = green, B = blue. https://g.co/kgs/Mw5Cvr
                            }
                        },
                    }, 
                },
                SpawnCoords = {
                    VehicleSpawn = vector4(337.24801, -2036.073, 21.3336, 46.538722), -- Vehicle spawn and vehicle clear check coords
                    PreviewSpawn = vector4(337.24801, -2036.073, 21.3336, 46.538722), -- Preview vehicle spawn coords
                    CheckRadius = 5.0, -- The radius the script checks for vehicle
                    CameraInformation = {
                        CinematicCamera = false, -- Set to false to disable the cinematic experimental features
                        CameraCoords = vector4(334.57257, -2033.613, 21.733171, 231.10733), -- Vehicle preview camera coords
                        CameraRotation = vector2(-10.00, 0.00), -- Vehicle preview camera rotation coords
                        CameraFOV = 90.0, -- The vehicle preview camera fov value
                    },
                },
            },
            GeneralInformation = {
                Blip = { -- Blip information
                    BlipId = 357, -- The blip id. More can be found at : https://docs.fivem.net/docs/game-references/blips/
                    BlipColour = 5, -- The blip colour. More can be found at : https://docs.fivem.net/docs/game-references/blips/
                    BlipScale = 0.4, -- The blip scale
                    Title = "Vagos - Garage" -- The blip title string
                },
                TargetInformation = { -- This is the required information for the target
                    Ped = "g_m_m_mexboss_02", -- The ped model. More models can be found at : https://docs.fivem.net/docs/game-references/ped-models/
                    Coords = vector4(337.21884, -2041.46, 20.115285, 60.793651), -- The target ped coords
                    Scenario = "WORLD_HUMAN_CLIPBOARD", -- Ped scenario. More can be found at : https://wiki.rage.mp/index.php?title=Scenarios
                },
                PolyZoneInformation = {
                    MinZ = 19.009085,
                    MaxZ = 21.909085,
                    DeBug = false,
                    ShapeCoords = {
                        vector2(301.03091, -2016.129),
                        vector2(303.0971, -2019.425),
                        vector2(302.27285, -2024.164),
                        vector2(331.46725, -2048.729),
                        vector2(340.98849, -2037.351),
                        vector2(335.95782, -2032.854),
                        vector2(337.3768, -2030.796),
                        vector2(317.44186, -2014.198),
                        vector2(315.78918, -2015.44),
                        vector2(311.18652, -2011.732),
                        vector2(305.41867, -2010.414),
                    },
                    ParkingCoords = {
                        vector4(306.92645, -2022.374, 20.546876, 320.41744),
                        vector4(309.06008, -2024.676, 20.546876, 325.41741),
                        vector4(311.38275, -2026.536, 20.546876, 315.41741),
                        vector4(313.73745, -2028.329, 20.546876, 320.41744),
                        vector4(316.07073, -2030.463, 20.546876, 317.91744),
                        vector4(318.50579, -2031.895, 20.546876, 317.91744),
                        vector4(320.7276, -2034.006, 20.546876, 322.91741),
                        vector4(323.03598, -2035.997, 20.546876, 315.41741),
                        vector4(325.07128, -2038.163, 20.546876, 320.41744),
                        vector4(327.08718, -2040.121, 20.51547, 317.91741),
                        vector4(331.97851, -2044.142, 20.583049, 317.91738),
                        vector4(329.66009, -2041.906, 20.81007, 322.91705),
                        vector4(332.49438, -2031.589, 21.026878, 135.41743),
                        vector4(329.97329, -2029.81, 21.026878, 140.41746),
                        vector4(327.51333, -2028.026, 21.026878, 132.91743),
                        vector4(325.40069, -2026.141, 21.026878, 130.41746),
                        vector4(323.35363, -2023.917, 21.026878, 137.91744),
                        vector4(321.08935, -2022.08, 21.026878, 145.41743),
                        vector4(318.48934, -2020.279, 21.026878, 135.41743),
                    },
                },
            },  
        },
        ["Marabunta"] = { -- Used for the station name. This is a full template, inculdes all the available script features. 
            UseRent = true, -- Set to false to disable the rent feature for this station (Garage WONT work if both UseRent and UsePurchasable are set to false)
            UseTarget = true, -- Set to false to disable the use of target. If set to false UseMarker must be on
            UseMarker = false, -- Set to true to enable the use of GTA V markers
            UseBlip = true, -- Set to false to disable blips for this garage
            UsePolyZone = false, -- Set to false to not use the polyzone system
            UseOwnable = true, -- Set to false to disable ownable vehicles (If set to true vehicles can be stored inside the script garage system)
            UseExtras = true, -- Set to false to disable the extras feature
            UseLiveries = false, -- Set to false to disable the livery feature
            UsePurchasable = true, -- Set to false to disable purchasable vehicles (Garage WONT WORK if both UseRent and UsePurchasable are set to false)
            JobRequired = nil, -- The job required for this station garage; For 1 job use, for multiple jobs JobRequired = {"job1", "job2"}, for all job use JobRequired = "all" (GangRequired and JobRequired cant be used together, only each)
            GangRequired = "marabunta", -- The gang required for accesing the garage, for multiple gangs GangRequired = {"gang1", "gang2"}, for all gangs, GangRequired = "all" (GangRequired and JobRequired cant be used together, only each)
            VehiclesInformation = {
                RentVehicles = { -- Rent vehicles information, if UseRent set to true
                    ["Avarus"] = { -- The vehicle name
                        Vehicle = "avarus", -- The vehicle to spawn
                        PricePerMinute = 75, -- The price to charge for that vehicle every minute
                    }, 
                    ["BF-400"] = { -- The vehicle name
                        Vehicle = "bf400", -- The vehicle to spawn
                        PricePerMinute = 100, -- The price to charge for that vehicle every minute
                    }, 
                },
                PurchaseVehicles = { -- Purchasable vehicles list, this will be shown for the players when buying the vehicles (Gets sorted by rank)
                    ["Hermes"] = { -- The vehicle name
                        Vehicle = "hermes", -- The vehicle model to spawn
                        TotalPrice = 5000, -- The total price it costs to buy this vehicle
                        Rank = 0, -- The rank required to purchase this vehicle. Set to 0 to enable all ranks
                        VehicleSettings = { -- Everthing inside those brackets is totally optional
                            DefaultColors = { -- Default vehicle colors of which the vehicle would get spawned with
                                PrimaryColor = { R = 87, G = 158, B = 218 }, -- Primary color, R = red, G = green, B = blue. https://g.co/kgs/Mw5Cvr
                                SecondaryColor = { R = 87, G = 158, B = 218 }, -- Secondary color, R = red, G = green, B = blue. https://g.co/kgs/Mw5Cvr
                            }
                        },
                    }, 
                    ["Tornado"] = { -- The vehicle name
                        Vehicle = "tornado", -- The vehicle model to spawn
                        TotalPrice = 1000, -- The total price it costs to buy this vehicle
                        Rank = 0, -- The rank required to purchase this vehicle. Set to 0 to enable all ranks
                        VehicleSettings = { -- Everthing inside those brackets is totally optional
                            DefaultColors = { -- Default vehicle colors of which the vehicle would get spawned with
                                PrimaryColor = { R = 87, G = 158, B = 218 }, -- Primary color, R = red, G = green, B = blue. https://g.co/kgs/Mw5Cvr
                                SecondaryColor = { R = 87, G = 158, B = 218 }, -- Secondary color, R = red, G = green, B = blue. https://g.co/kgs/Mw5Cvr
                            }
                        },
                    }, 
                    ["Voodoo"] = { -- The vehicle name
                        Vehicle = "voodoo", -- The vehicle model to spawn
                        TotalPrice = 7500, -- The total price it costs to buy this vehicle
                        Rank = 1, -- The rank required to purchase this vehicle. Set to 0 to enable all ranks
                        VehicleSettings = { -- Everthing inside those brackets is totally optional
                            DefaultColors = { -- Default vehicle colors of which the vehicle would get spawned with
                                 PrimaryColor = { R = 87, G = 158, B = 218 }, -- Primary color, R = red, G = green, B = blue. https://g.co/kgs/Mw5Cvr
                                SecondaryColor = { R = 87, G = 158, B = 218 }, -- Secondary color, R = red, G = green, B = blue. https://g.co/kgs/Mw5Cvr
                            }
                        },
                    }, 
                    ["Phoenix"] = { -- The vehicle name
                        Vehicle = "phoenix", -- The vehicle model to spawn
                        TotalPrice = 15000, -- The total price it costs to buy this vehicle
                        Rank = 2, -- The rank required to purchase this vehicle. Set to 0 to enable all ranks
                        VehicleSettings = { -- Everthing inside those brackets is totally optional
                            DefaultColors = { -- Default vehicle colors of which the vehicle would get spawned with
                                PrimaryColor = { R = 3, G = 23, B = 252 }, -- Primary color, R = red, G = green, B = blue. https://g.co/kgs/Mw5Cvr
                                SecondaryColor = { R = 3, G = 23, B = 252  }, -- Secondary color, R = red, G = green, B = blue. https://g.co/kgs/Mw5Cvr
                            }
                        },
                    }, 
                },
                SpawnCoords = {
                    VehicleSpawn = vector4(1422.4699, -1504.773, 60.927551, 170.23406), -- Vehicle spawn and vehicle clear check coords
                    PreviewSpawn = vector4(1422.4699, -1504.773, 60.927551, 170.23406), -- Preview vehicle spawn coords
                    CheckRadius = 5.0, -- The radius the script checks for vehicle
                    CameraInformation = {
                        CinematicCamera = false, -- Set to false to disable the cinematic experimental features
                        CameraCoords = vector4(1420.8251, -1510.951, 62.194248, 338.54263), -- Vehicle preview camera coords
                        CameraRotation = vector2(-10.00, 0.00), -- Vehicle preview camera rotation coords
                        CameraFOV = 80.0, -- The vehicle preview camera fov value
                    },
                },
            },
            GeneralInformation = {
                Blip = { -- Blip information
                    BlipId = 357, -- The blip id. More can be found at : https://docs.fivem.net/docs/game-references/blips/
                    BlipColour = 38, -- The blip colour. More can be found at : https://docs.fivem.net/docs/game-references/blips/
                    BlipScale = 0.4, -- The blip scale
                    Title = "Marabunta - Garage" -- The blip title string
                },
                TargetInformation = { -- This is the required information for the target
                    Ped = "g_m_y_salvagoon_01", -- The ped model. More models can be found at : https://docs.fivem.net/docs/game-references/ped-models/
                    Coords = vector4(1423.4393, -1501.589, 59.952785, 170.74295), -- The target ped coords
                    Scenario = "WORLD_HUMAN_CLIPBOARD", -- Ped scenario. More can be found at : https://wiki.rage.mp/index.php?title=Scenarios
                },
            },  
        },
        ["Ballas"] = { -- Used for the station name. This is a full template, inculdes all the available script features. 
            UseRent = true, -- Set to false to disable the rent feature for this station (Garage WONT work if both UseRent and UsePurchasable are set to false)
            UseTarget = true, -- Set to false to disable the use of target. If set to false UseMarker must be on
            UseMarker = false, -- Set to true to enable the use of GTA V markers
            UseBlip = true, -- Set to false to disable blips for this garage
            UsePolyZone = false, -- Set to false to not use the polyzone system
            UseOwnable = true, -- Set to false to disable ownable vehicles (If set to true vehicles can be stored inside the script garage system)
            UseExtras = true, -- Set to false to disable the extras feature
            UseLiveries = false, -- Set to false to disable the livery feature
            UsePurchasable = true, -- Set to false to disable purchasable vehicles (Garage WONT WORK if both UseRent and UsePurchasable are set to false)
            JobRequired = nil, -- The job required for this station garage; For 1 job use, for multiple jobs JobRequired = {"job1", "job2"}, for all job use JobRequired = "all" (GangRequired and JobRequired cant be used together, only each)
            GangRequired = "ballas", -- The gang required for accesing the garage, for multiple gangs GangRequired = {"gang1", "gang2"}, for all gangs, GangRequired = "all" (GangRequired and JobRequired cant be used together, only each)
            VehiclesInformation = {
                RentVehicles = { -- Rent vehicles information, if UseRent set to true
                    ["Avarus"] = { -- The vehicle name
                        Vehicle = "avarus", -- The vehicle to spawn
                        PricePerMinute = 75, -- The price to charge for that vehicle every minute
                    }, 
                    ["BF-400"] = { -- The vehicle name
                        Vehicle = "bf400", -- The vehicle to spawn
                        PricePerMinute = 100, -- The price to charge for that vehicle every minute
                    }, 
                },
                PurchaseVehicles = { -- Purchasable vehicles list, this will be shown for the players when buying the vehicles (Gets sorted by rank)
                    ["Hermes"] = { -- The vehicle name
                        Vehicle = "hermes", -- The vehicle model to spawn
                        TotalPrice = 5000, -- The total price it costs to buy this vehicle
                        Rank = 0, -- The rank required to purchase this vehicle. Set to 0 to enable all ranks
                        VehicleSettings = { -- Everthing inside those brackets is totally optional
                            DefaultColors = { -- Default vehicle colors of which the vehicle would get spawned with
                                PrimaryColor = { R = 112, G = 31, B = 156 }, -- Primary color, R = red, G = green, B = blue. https://g.co/kgs/Mw5Cvr
                                SecondaryColor = { R = 112, G = 31, B = 156 }, -- Secondary color, R = red, G = green, B = blue. https://g.co/kgs/Mw5Cvr
                            }
                        },
                    }, 
                    ["Tornado"] = { -- The vehicle name
                        Vehicle = "tornado", -- The vehicle model to spawn
                        TotalPrice = 1000, -- The total price it costs to buy this vehicle
                        Rank = 0, -- The rank required to purchase this vehicle. Set to 0 to enable all ranks
                        VehicleSettings = { -- Everthing inside those brackets is totally optional
                            DefaultColors = { -- Default vehicle colors of which the vehicle would get spawned with
                                PrimaryColor = { R = 112, G = 31, B = 156 }, -- Primary color, R = red, G = green, B = blue. https://g.co/kgs/Mw5Cvr
                                SecondaryColor = { R = 112, G = 31, B = 156 }, -- Secondary color, R = red, G = green, B = blue. https://g.co/kgs/Mw5Cvr
                            }
                        },
                    }, 
                    ["Voodoo"] = { -- The vehicle name
                        Vehicle = "voodoo", -- The vehicle model to spawn
                        TotalPrice = 7500, -- The total price it costs to buy this vehicle
                        Rank = 1, -- The rank required to purchase this vehicle. Set to 0 to enable all ranks
                        VehicleSettings = { -- Everthing inside those brackets is totally optional
                            DefaultColors = { -- Default vehicle colors of which the vehicle would get spawned with
                                PrimaryColor = { R = 112, G = 31, B = 156 }, -- Primary color, R = red, G = green, B = blue. https://g.co/kgs/Mw5Cvr
                                SecondaryColor = { R = 112, G = 31, B = 156 }, -- Secondary color, R = red, G = green, B = blue. https://g.co/kgs/Mw5Cvr
                            }
                        },
                    }, 
                    ["Phoenix"] = { -- The vehicle name
                        Vehicle = "phoenix", -- The vehicle model to spawn
                        TotalPrice = 15000, -- The total price it costs to buy this vehicle
                        Rank = 2, -- The rank required to purchase this vehicle. Set to 0 to enable all ranks
                        VehicleSettings = { -- Everthing inside those brackets is totally optional
                            DefaultColors = { -- Default vehicle colors of which the vehicle would get spawned with
                                PrimaryColor = { R = 112, G = 31, B = 156 }, -- Primary color, R = red, G = green, B = blue. https://g.co/kgs/Mw5Cvr
                                SecondaryColor = { R = 112, G = 31, B = 156 }, -- Secondary color, R = red, G = green, B = blue. https://g.co/kgs/Mw5Cvr
                            }
                        },
                    }, 
                },
                SpawnCoords = {
                    VehicleSpawn = vector4(93.596099, -1962.241, 20.747535, 332.03335), -- Vehicle spawn and vehicle clear check coords
                    PreviewSpawn = vector4(93.596099, -1962.241, 20.747535, 332.03335), -- Preview vehicle spawn coords
                    CheckRadius = 5.0, -- The radius the script checks for vehicle
                    CameraInformation = {
                        CinematicCamera = true, -- Set to false to disable the cinematic experimental features
                        CameraCoords = vector4(97.426574, -1957.921, 21.194847, 137.70339), -- Vehicle preview camera coords
                        CameraRotation = vector2(-10.00, 0.00), -- Vehicle preview camera rotation coords
                        CameraFOV = 80.0, -- The vehicle preview camera fov value
                    },
                },
            },
            GeneralInformation = {
                Blip = { -- Blip information
                    BlipId = 357, -- The blip id. More can be found at : https://docs.fivem.net/docs/game-references/blips/
                    BlipColour = 27, -- The blip colour. More can be found at : https://docs.fivem.net/docs/game-references/blips/
                    BlipScale = 0.4, -- The blip scale
                    Title = "Ballas - Garage" -- The blip title string
                },
                TargetInformation = { -- This is the required information for the target
                    Ped = "g_m_y_ballaorig_01", -- The ped model. More models can be found at : https://docs.fivem.net/docs/game-references/ped-models/
                    Coords = vector4(102.9036, -1959.798, 19.832029, 358.30307), -- The target ped coords
                    Scenario = "WORLD_HUMAN_CLIPBOARD", -- Ped scenario. More can be found at : https://wiki.rage.mp/index.php?title=Scenarios
                },
            },  
        },
    },
}