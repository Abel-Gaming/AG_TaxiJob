Config = {}

Config.JobsCommand = 'taxijob'
Config.EnableBlips = true

Config.TaxiJob = {
    {
        name = 'Passenger 1', -- This is not really used, but could be implemented in some way
        pickupCoord = vector3(935.19720458984, 46.289459228516, 81.095764160156), -- This is where you will pick the passenger up
        dropoffCoord = vector3(1370.4211425781, 1147.6168212891, 113.3659286499) -- This is where you will drop the passenger off
    },
    {
        name = 'Passenger 2',
        pickupCoord = vector3(-1616.1058349609, 173.64408874512, 60.192127227783),
        dropoffCoord = vector3(-1652.5690917969, -1003.8096313477, 12.410656929016)
    }
}