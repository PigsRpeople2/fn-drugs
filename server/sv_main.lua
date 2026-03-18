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
    local source = source
    local recipe = Config.Recipes[recipeId]
    if not recipe or amount <= 0 then return end

    for _, ingredient in ipairs(recipe.ingredients) do
        local count = exports.ox_inventory:Search(source, 'count', ingredient.item)
        if count < (ingredient.amount * amount) then 
            return TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = 'Missing ingredients'})
        end
    end

    local success = lib.callback.await("fn-drugs:cl:startbar", source, recipe.time * amount, recipe.progressText, recipe.skillCheck, recipe.animation)
    if not success then return end

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)
    local location = recipe.table and Config.Tables[recipe.table]?.coords.xyz or recipe.location?.xyz or vec3(0,0,0)

    if #(coords - location) > 10.0 then 
        return print(string.format("Player %s attempted to process drugs too far away!", source))
    end

    local itemsToGive = {}
    for _, output in ipairs(recipe.outputs) do
        local roll = math.random(1, 100)
        if roll <= output.chance then
            local totalAmount = output.amount * amount
            table.insert(itemsToGive, {item = output.item, amount = totalAmount})
        end
    end

    for _, reward in ipairs(itemsToGive) do
        if not exports.ox_inventory:CanCarryItem(source, reward.item, reward.amount) then
            return TriggerClientEvent('ox_lib:notify', source, {
                title = "Inventory Full",
                description = "You cannot carry the finished product.",
                type = "error"
            })
        end
    end

    for _, ingredient in ipairs(recipe.ingredients) do
        exports.ox_inventory:RemoveItem(source, ingredient.item, ingredient.amount * amount)
    end

    for _, reward in ipairs(itemsToGive) do
        exports.ox_inventory:AddItem(source, reward.item, reward.amount)
    end
end)