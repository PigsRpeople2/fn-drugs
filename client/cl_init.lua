CreateThread(function()
    local interactHashes = {}
    for _, model in ipairs(Config.InteractableModels) do
        table.insert(interactHashes, GetHashKey(model))
    end

    exports.ox_target:addModel(interactHashes, {
        {
            label = "Scrap Vehicle",
            icon = "fa-solid fa-wrench",
            canInteract = function() return canChopVehicle() end,
            event = "asd-chopping:tryChopVehicle"
        }
    })

    local function spawnNPC(model, coords, heading, scenario, targetOptions)
        local hash = GetHashKey(model)
        RequestModel(hash)
        while not HasModelLoaded(hash) do Wait(1) end

        local ped = CreatePed(4, hash, coords.x, coords.y, coords.z - 1.0, heading, false, false)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        if scenario then TaskStartScenarioInPlace(ped, scenario, 0, true) end
        exports.ox_target:addLocalEntity(ped, targetOptions)
        return ped
    end

    spawnNPC(Config.MissionGiverPed, Config.NPCLocs.MissionStart.xyz, Config.NPCLocs.MissionStart.w, Config.MissionGiverAnimation, {
        {
            label = "Get Scrapping Job",
            icon = "fa-solid fa-car-burst",
            canInteract = function() return not hasScrappingJob end,
            event = "asd-chopping:getJob"
        },
        {
            label = "Stop Scrapping Job",
            icon = "fa-solid fa-xmark",
            canInteract = function() return hasScrappingJob end,
            event = "asd-chopping:CancelJob"
        }
    })

    spawnNPC(Config.SellerPed, Config.NPCLocs.Seller.xyz, Config.NPCLocs.Seller.w, Config.SellerAnimation, {
        {
            label = "Sell Vehicle Parts",
            icon = "fa-solid fa-hand-holding-dollar",
            event = "asd-chopping:tryOpenSellMenu"
        }
    })

    spawnNPC(Config.ExchangerPed, Config.NPCLocs.Exchanger.xyz, Config.NPCLocs.Exchanger.w, Config.ExchangerAnimation, {
        {
            label = "Exchange",
            icon = "fa-solid fa-recycle",
            event = "asd-chopping:tryOpenExchangeMenu"
        }
    })
end)