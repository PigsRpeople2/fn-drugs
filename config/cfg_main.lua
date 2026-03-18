Config = {}

Config.HarvestingSpots = {
    ["weed_farm"] = { -- Singular Prop
        position = vec3(449.0, 5575.3, 780.15), -- WHERE THE THING IS
        renderDist = 5.0, -- How far can see
        interactDist = 2.0,  -- How far can interact
        label = "Weed", -- Fancy label uwu
        itemName = "money", -- Reward item to give 
        count = math.random(2, 5), -- Amount of items to give
        time = 5000, -- Progressbar time
        icon = "cannabis", -- Icon
        prop = {
            model = `prop_weed_01`,
            pos = vec3(449.0, 5575.3, 780.15),
            heading = 0.0
        }
    },
    ["wild_plants"] = { -- Area
        position = vec3(2418.66, 4783.27, 33.62),
        spawnRadius = 15.0, -- The radius of spawn
        spawnCount = 5, -- How many props spawn at a time
        respawnTime = 10, -- How long props take to respawn (ms)
        renderDist = 40.0, 
        interactDist = 1.5,  
        label = "Wild Plants",
        itemName = "money",
        count = 1,
        time = 3000,
        icon = "cannabis",
        prop = { model = `prop_weed_01`, heading = 0.0 } 
    }
}

Config.Recipes = {
    ["meth"] = {
        id = "mix_chemicals",
        targetText = "Mix Chemicals",
        time = 250,
        progressText = "Mixing Chemicals...",
        animation = {dict = "mini@repair", clip = "fixing_a_ped"},
        ingredients = {
            { item = "ammo-9", amount = 1 },
        },
        outputs = {
        { item = "meth", label = "Meth", amount = 1, chance = 100 },
        },
        table = "meth_table",
        --location = vec3(105.5553, -1089.2196, 29.1198),              -- Unneeded if a table is assigned
        skillCheck = {"easy"} -- easy, medium, hard, false or cutsom table
    },

}

Config.Tables = {
    ["meth_table"] = {
        name = "meth_table",
        coords = vec4(113.3866, -1079.2788, 28.1924, 350.1730),
        prop = "tr_prop_meth_table01a",
        --letFloat = true
    }
}