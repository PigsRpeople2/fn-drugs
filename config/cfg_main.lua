Config = {}

-- I commented out ALL of cl_init.lua because its old shit
-- can you kill it if its not needed anymore

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



Config.Recipes = {
    ["Meth"] = {
        steps = {
            {
                id = "mix_chemicals",
                targetText = "Mix Chemicals",
                time = 5000,
                progressText = "Mxing Chemicals...",
                animation = {
                    dict = "",
                    name = ""
                },
                ingredients = {
                    { item = "ammo-9", amount = 1 },
                },
                output = { item = "meth", label = "Meth", amount = 1 },
                revealOutput = true,
                --table = "meth_table",
                location = vec3(105.5553, -1089.2196, 29.1198)              -- Unneeded if a table is assigned
            }
        }
    }
}

Config.Tables = {
    {
        name = "meth_table",
        coords = vec4(0.0, 0.0, 0.0, 0.0),
        prop = "tr_prop_meth_table01a"
    }
}