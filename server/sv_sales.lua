local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("asd-chopping:openSellMenu", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local pCoords = GetEntityCoords(GetPlayerPed(src))
    if #(pCoords - Config.NPCLocs.Seller.xyz) > 10.0 then return end

    local sellableItems = {}
    for _, data in ipairs(Config.ChopJobItems) do
        local item = exports.ox_inventory:GetItem(src, data.item, nil, false)
        local count = item and item.count or 0

        if count > 0 then
            table.insert(sellableItems, {
                label = data.item:gsub("^%l", string.upper),
                name = data.item,
                count = count,
                price = data.price 
            })
        end
    end
    TriggerClientEvent("asd-chopping:openSellMenu", src, sellableItems)
end)

RegisterNetEvent("asd-chopping:sellVehiclePart", function(args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not args then return end

    local pCoords = GetEntityCoords(GetPlayerPed(src))
    if #(pCoords - Config.NPCLocs.Seller.xyz) > 10.0 then return end

    local hardsetPrice = 0
    for _, v in ipairs(Config.ChopJobItems) do
        if v.item == args.name then 
            hardsetPrice = v.price 
            break 
        end
    end

    if hardsetPrice > 0 then
        local countToSell = tonumber(args.trySellCount) or 0
        
        if countToSell > 0 and exports.ox_inventory:RemoveItem(src, args.name, countToSell) then
            local payout = math.floor(hardsetPrice * countToSell)
            exports.ox_inventory:AddItem(source, 'black_money', payout)
            
            TriggerEvent("asd-chopping:openSellMenu", src) 
        else
            TriggerClientEvent('ox_lib:notify', src, { 
                title = 'Error', 
                description = 'You don\'t have enough of that item!', 
                type = 'error' 
            })
        end
    end
end)

RegisterNetEvent("asd-chopping:sellAllParts", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local totalPayout = 0
    local itemsRemoved = false

    for _, data in ipairs(Config.ChopJobItems) do
        local count = exports.ox_inventory:GetItemCount(src, data.item)
        
        if count > 0 then
            if exports.ox_inventory:RemoveItem(src, data.item, count) then
                totalPayout = totalPayout + (data.price * count)
                itemsRemoved = true
            end
        end
    end

    if itemsRemoved and totalPayout > 0 then
        exports.ox_inventory:AddItem(src, 'black_money', totalPayout)
        TriggerClientEvent('ox_lib:notify', src, { title = 'Shady Bob', description = 'Pleasure doin\' business.', type = 'success' })
        TriggerEvent("asd-chopping:openSellMenu", src) 
    end
end)

RegisterNetEvent("asd-chopping:openExchangeMenu", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local pCoords = GetEntityCoords(GetPlayerPed(src))
    if #(pCoords - Config.NPCLocs.Exchanger.xyz) > 10.0 then return end

    local exchangeableItems = {}
    for _, data in ipairs(Config.ChopJobItems) do
        local count = exports.ox_inventory:GetItemCount(src, data.item)

        if count > 0 then
            table.insert(exchangeableItems, {
                label = data.item:gsub("^%l", string.upper),
                name = data.item,
                count = count
            })
        end
    end
    TriggerClientEvent("asd-chopping:openExchangeMenu", src, exchangeableItems)
end)

RegisterNetEvent("asd-chopping:exchangePart", function(args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not args then return end

    local pCoords = GetEntityCoords(GetPlayerPed(src))
    if #(pCoords - Config.NPCLocs.Exchanger.xyz) > 10.0 then return end

    local rewardData = Config.ExchangeRewards[args.name]
    local countToExchange = tonumber(args.amount) or 0

    if rewardData and countToExchange > 0 then
        if exports.ox_inventory:RemoveItem(src, args.name, countToExchange) then
            
            for i = 1, countToExchange do
                for _, reward in ipairs(rewardData.returnItems) do
                    if math.random(1, 100) <= reward.chance then
                        local amount = math.random(reward.min, reward.max)
                        exports.ox_inventory:AddItem(src, reward.item, amount)
                    end
                end

                if rewardData.rareItemsExchange then
                    if math.random(1, 100) <= rewardData.rareItemsExchange.chance then
                        exports.ox_inventory:AddItem(src, rewardData.rareItemsExchange.item, rewardData.rareItemsExchange.amount)
                    end
                end
            end

            TriggerClientEvent('ox_lib:notify', src, { title = 'Scrap Yard', description = 'Parts scrapped into materials.', type = 'success' })
            TriggerEvent("asd-chopping:openExchangeMenu", src) 
        else
            TriggerClientEvent('ox_lib:notify', src, { title = 'Error', description = 'Item mismatch.', type = 'error' })
        end
    end
end)

RegisterNetEvent("asd-chopping:exchangeAllParts", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local itemsExchanged = false

    for _, data in ipairs(Config.ChopJobItems) do
        local count = exports.ox_inventory:GetItemCount(src, data.item)
        local rewardData = Config.ExchangeRewards[data.item]
        
        if count > 0 and rewardData then
            if exports.ox_inventory:RemoveItem(src, data.item, count) then
                itemsExchanged = true
                for i = 1, count do
                    for _, reward in ipairs(rewardData.returnItems) do
                        if math.random(1, 100) <= reward.chance then
                            exports.ox_inventory:AddItem(src, reward.item, math.random(reward.min, reward.max))
                        end
                    end
                    if rewardData.rareItemsExchange and math.random(1, 100) <= rewardData.rareItemsExchange.chance then
                        exports.ox_inventory:AddItem(src, rewardData.rareItemsExchange.item, rewardData.rareItemsExchange.amount)
                    end
                end
            end
        end
    end

    if itemsExchanged then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Scrap Yard', description = 'All parts processed.', type = 'success' })
        TriggerEvent("asd-chopping:openExchangeMenu", src) 
    end
end)

RegisterNetEvent("asd-chopping:activateAlarm", function(coords, street)
    if exports['ps-dispatch'] then
        exports['ps-dispatch']:SuspiciousActivity(coords, "Vehicle Scrapping")
    else
        local alertData = {
            code = '10-31',
            name = 'Illegal Vehicle Scrapping',
            coords = coords,
            street = street
        }
        TriggerClientEvent('qb-policealerts:client:AddPoliceAlert', -1, alertData)
    end
end)