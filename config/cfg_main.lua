Config = {}

Config.HarvestingSpots = {
    ["weed_farm"] = {
        position = vec3(449.0, 5575.3, 780.15),
        renderDist = 5.0,     
        interactDist = 2.0,   
        label = "Weed",
        itemName = "money",
        count = math.random(2, 5),
        time = 5000,
        icon = "leaf",
        prop = {
            model = `prop_weed_01`,
            pos = vec3(449.0, 5575.3, 780.15),
            heading = 0.0
        }
    },
    ["wild_plants"] = { -- TODO: Make an option for a radius, which'll be it'll spawn randomly in this radius.
        position = vec3(2200.0, 4800.0, 40.0),
        renderDist = 5.0,     
        interactDist = 1.2,  
        label = "Wild Plants",
        itemName = "herbs",
        count = 1,
        time = 3000,
        icon = "seedling",
    }
}