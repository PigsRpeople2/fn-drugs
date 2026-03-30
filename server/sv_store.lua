local function GetNegotiatedPrice(basePrice, minPrice, multiplier)
    local discounted = math.floor(basePrice * multiplier)
    return math.max(discounted, minPrice)
end

lib.callback.register("fn-stores:sv:processChoice", function(source, storeKey, choiceId)
    local src = source
    local store = Config.Stores[storeKey]
    local choice = store.choices[choiceId]
    
    if not store or not choice then return { success = false, reason = "invalid" } end

    local roll = math.random(1, 100)
    local success = roll <= choice.chance
    
    if success then
        return { 
            success = true, 
            priceMultiplier = choice.multiplier 
        }
    else
        local extremelyOffended = roll >= 98
        
        return { 
            success = false, 
            reason = "failed_roll", 
            lockout = extremelyOffended or choice.lockoutOnFail or false 
        }
    end
end)

RegisterNetEvent("fn-stores:sv:buyItem", function(storeKey, itemIndex, finalPrice, amount)
    local src = source
    local store = Config.Stores[storeKey]
    local itemData = store.items[itemIndex]
    
    amount = tonumber(amount)
    if not itemData or not amount or amount <= 0 then return end
    
    if amount > itemData.stock then amount = itemData.stock end

    local totalCost = finalPrice * amount
    local playerMoney = exports.ox_inventory:GetItemCount(src, 'black_money')
    
    if playerMoney >= totalCost then
        local canCarry = exports.ox_inventory:CanCarryItem(src, itemData.itemName, amount)
        
        if canCarry then
            exports.ox_inventory:RemoveItem(src, 'black_money', totalCost)
            exports.ox_inventory:AddItem(src, itemData.itemName, amount)
            
            TriggerClientEvent('ox_lib:notify', src, {
                title = store.name,
                description = ("You bought x%s %s for $%s"):format(amount, itemData.label, totalCost),
                type = "success"
            })
        else
            TriggerClientEvent('ox_lib:notify', src, {
                title = store.name,
                description = "Your pockets aren't big enough for that many!",
                type = "error"
            })
        end
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = store.name,
            description = ("You're short on cash. You need $%s for that amount."):format(totalCost),
            type = "error"
        })
    end
end)