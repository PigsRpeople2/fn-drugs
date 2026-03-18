if not lib then return end


local spawnPositions = {}

for zoneKey, data in pairs(Config.HarvestingSpots) do
    spawnPositions[zoneKey] = {}
    for i = 1, data.spawnCount or 1 do
        spawnPositions[zoneKey][i] = nil
    end
end





-- harvesting

lib.callback.register('fn-drugs:sv:requestPick', function(source, spotKey, plantIndex)
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
        spawnPositions[spotKey][plantIndex] = nil
        TriggerClientEvent('fn-drugs:cl:harvested', -1, spotKey, plantIndex)
        return true
    else
        return false
    end
end)




-- Position Plants

lib.callback.register('fn-drugs:sv:requestSpawnPos', function (source, data, plantIndex, zoneKey)
    if spawnPositions[zoneKey][plantIndex] then
        return spawnPositions[zoneKey][plantIndex]
    end

    local spawnPos = data.position

    if data.spawnRadius then
        spawnPos = spawnPos + vec3(math.random(-data.spawnRadius or 0, data.spawnRadius or 0), math.random(-data.spawnRadius or 0, data.spawnRadius or 0), 0.0)
    end

    if data.minGap then
        while lib.callback.await("fn-drugs:cl:getClosest", lib.getClosestPlayer(spawnPos, data.renderDist), { x = spawnPos.x, y = spawnPos.y, z = spawnPos.z, radius = data.minGap, modelHash = data.prop.model }) ~= 0 do
            spawnPos = spawnPos + vec3(math.random(-data.spawnRadius or 0, data.spawnRadius or 0), math.random(-data.spawnRadius or 0, data.spawnRadius or 0), 0.0)
        end
    end

    spawnPositions[zoneKey][plantIndex] = spawnPos
    return spawnPos
end)













-- processing
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