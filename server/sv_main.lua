if not lib then return end

-- harvesting

lib.callback.register('fn-drugs:sv:requestPick', function(source, spotKey)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false end

    local spot = Config.HarvestingSpots[spotKey]
    if not spot then 
        return false 
    end

    local itemName = spot.itemName
    local itemCount = 1

    if type(spot.count) == "table" then
        itemCount = math.random(spot.count.min, spot.count.max)
    else
        itemCount = spot.count or 1
    end

    if exports.ox_inventory:CanCarryItem(source, itemName, itemCount) then
        exports.ox_inventory:AddItem(source, itemName, itemCount)
        return true
    else
        return false
    end
end)


RegisterNetEvent("fn-drugs:server:startProcess", function(recipeId, amount)
    local recipe = Config.Recipes[recipeId]

    for i, ingredient in pairs(recipe.ingredients) do
        local needed = ingredient.amount * amount
        local items = exports.ox_inventory:Search(source, 'count', ingredient.item)
        if items < needed then return end
    end
    
    local progress = lib.callback.await("fn-drugs:cl:startbar", source, recipe.time * amount, recipe.progressText, recipe.skillCheck, recipe.animation)
    if not progress then
        return
    else
        local playerPed = GetPlayerPed(source)
        local coords = GetEntityCoords(playerPed)
        local dist = #(coords - recipe.location.xyz)

        if dist > 10 then return end
        for i, ingredient in ipairs(recipe.ingredients) do
            local needed = ingredient.amount * amount
            local items = exports.ox_inventory:Search(source, 'count', ingredient.item)
            if items < needed then return end
        end

        local outputWeight = exports.ox_inventory:Items(recipe.output.item).weight
        

        local weight = outputWeight * recipe.output.amount * amount

        for _, ingredient in ipairs(recipe.ingredients) do
            local used = ingredient.amount * amount
            local usedWeight = exports.ox_inventory:Items(ingredient.item).weight * used

            weight = weight - usedWeight
        end

        if not exports.ox_inventory:CanCarryWeight(source, weight) then
            local data = {
                title = "Cannot Carry Item",
                description = "Item is too heavy to carry.",
                type = "error"
            }
            TriggerClientEvent('ox_lib:notify', source, data)
            return
        end

        for i, ingredient in ipairs(recipe.ingredients) do
            local needed = ingredient.amount * amount
            exports.ox_inventory:RemoveItem(source, ingredient.item, needed)
        end
        exports.ox_inventory:AddItem(source, recipe.output.item, recipe.output.amount * amount)
    end
end)
