local ox_inventory = exports.ox_inventory

local Combinations = {
    ['ammo-9'] = {
        needs = 'baggy', 
        result = {
            {name = 'meth', amount = 1},
        }, 
        removeItemA = true,
        removeItemB = true,
    },
}

ox_inventory:registerHook('swapItems', function(payload)
    if payload.fromInventory ~= payload.source then return end
    
    local itemA = payload.fromSlot.name
    local itemB = payload.toSlot.name
    local recipe = Combinations[itemA]

    if recipe and itemB == recipe.needs then
        TriggerClientEvent('ox_inventory:closeInventory', payload.source)

        local success = lib.callback.await('fn-drugs:Combine', payload.source, itemA, itemB)

        if success then
            if recipe.removeItemA then
                ox_inventory:RemoveItem(payload.source, itemA, 1, nil, payload.fromSlot.slot)
            end
            if recipe.removeItemB then
                ox_inventory:RemoveItem(payload.source, itemB, 1, nil, payload.toSlot.slot)
            end

            for _, v in ipairs(recipe.result) do
                ox_inventory:AddItem(payload.source, v.name, v.amount)
            end
            
            TriggerClientEvent('ox_lib:notify', payload.source, {type = 'success', description = 'Items combined!'})
        else
            TriggerClientEvent('ox_lib:notify', payload.source, {type = 'error', description = 'Combination cancelled'})
        end

        return false
    end
end, {})