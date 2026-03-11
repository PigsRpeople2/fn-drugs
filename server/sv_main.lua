if not lib then return end

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