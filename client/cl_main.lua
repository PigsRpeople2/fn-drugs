local harvestingZones = {}
local recipeZones = {}
local tableZones = {}
local spawnedTableObjects = {}
local plantCooldowns = {}

local function CleanupDrugSystem()
    for _, zone in pairs(harvestingZones) do
        if zone.spawnedObjects then
            for _, obj in pairs(zone.spawnedObjects) do
                if DoesEntityExist(obj) then DeleteEntity(obj) end
            end
        end
        zone:remove()
    end
    for _, tableObj in pairs(spawnedTableObjects) do
        if DoesEntityExist(tableObj) then DeleteEntity(tableObj) end
    end
    for _, zone in ipairs(recipeZones) do zone:remove() end
    for _, zone in ipairs(tableZones) do zone:remove() end
    lib.hideTextUI()
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    CleanupDrugSystem()
end)



function HarvestPlant(zoneKey, index, entity, data)
    if IsPedInAnyVehicle(cache.ped, true) then return end

    local success = lib.progressCircle({
        duration = data.time,
        label = ("Harvesting %s"):format(data.label),
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = { dict = "amb@world_human_gardener_plant@male@idle_a", clip = "idle_b" },
    })

    if success then
        local hasSpace = lib.callback.await("fn-drugs:sv:requestPick", false, zoneKey, index)
        if not hasSpace then
            lib.notify({ title = "Inventory Full", description = "You cannot carry the harvested items",  type = "error" })
        end
    end
end

RegisterNetEvent('fn-drugs:cl:harvested', function (spotKey, plantIndex)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local data = Config.HarvestingSpots[spotKey]

    local zone = harvestingZones[spotKey]

    if zone and zone:contains(coords) then
        plantCooldowns[spotKey][plantIndex] = GetGameTimer() + ((data.respawnTime or 300) * 1000)
        local entity = zone.spawnedObjects[plantIndex]
        
        if DoesEntityExist(entity) then
            zone.spawnedObjects[plantIndex] = nil
            exports.ox_target:removeLocalEntity(entity)
            DeleteEntity(entity)
        end
    end
end)

-- Spawn Plants

lib.callback.register('fn-drugs:cl:getClosest', function (args)
    return GetClosestObjectOfType(
		args.x --[[ number ]], 
		args.y --[[ number ]], 
		args.z --[[ number ]], 
		args.radius --[[ number ]], 
		args.modelHash --[[ Hash ]], 
		false --[[ boolean ]], 
		false --[[ boolean ]], 
		false --[[ boolean ]]
	)
end)

for zoneKey, data in pairs(Config.HarvestingSpots) do
    plantCooldowns[zoneKey] = {}

    harvestingZones[zoneKey] = lib.zones.sphere({
        coords = data.position,
        debug = false,
        radius = data.renderDist or 15.0,
        onEnter = function(self)
            self.spawnedObjects = {}
            if data.prop then lib.requestModel(data.prop.model, 5000) end
        end,
        onExit = function(self)
            if self.spawnedObjects then
                for _, obj in pairs(self.spawnedObjects) do
                    if DoesEntityExist(obj) then DeleteEntity(obj) end
                end
                self.spawnedObjects = nil
            end
        end,
        inside = function(self)
            local currentTime = GetGameTimer()
            local spawnCount = data.spawnCount or 1

            for i = 1, spawnCount do
                if not self.spawnedObjects[i] then
                    local respawnAt = plantCooldowns[zoneKey][i] or 0
                    
                    if currentTime >= respawnAt then

                        local spawnPos = lib.callback.await('fn-drugs:sv:requestSpawnPos', false, data, i, zoneKey)

                        local obj = CreateObject(data.prop.model, spawnPos.x, spawnPos.y, spawnPos.z, false, true, false)
                        SetEntityHeading(obj, math.random(0, 360) + 0.0)
                        FreezeEntityPosition(obj, true)
                        PlaceObjectOnGroundProperly(obj)
                        
                        local iconStr = data.icon or "leaf"
                        if not string.find(iconStr, "fa-") then iconStr = "fa-solid fa-" .. iconStr end

                        exports.ox_target:addLocalEntity(obj, {
                            {
                                label = "Harvest " .. data.label,
                                icon = iconStr,
                                distance = data.interactDist or 2.0,
                                onSelect = function()
                                    HarvestPlant(zoneKey, i, obj, data, zoneKey)
                                end
                            }
                        })

                        self.spawnedObjects[i] = obj 
                    end
                end
            end
            Wait(1000)
        end,
    })
end




-- Recipes
local tableRecipes = {}
for recipeId, recipe in pairs(Config.Recipes) do
    if recipe.table then
        if not tableRecipes[recipe.table] then tableRecipes[recipe.table] = {} end
        table.insert(tableRecipes[recipe.table], recipeId)
    else
        recipeZones[#recipeZones + 1] = lib.zones.sphere({
            coords = recipe.location,
            radius = 5.0,
            onEnter = function()
                exports.ox_target:addSphereZone({
                    name = recipe.id,
                    coords = recipe.location,
                    radius = 1.0,
                    options = {
                        {
                            label = recipe.targetText,
                            onSelect = function() TriggerEvent("fn-drugs:openLabMenu", recipeId) end
                        }
                    }
                })
            end,
            onExit = function() exports.ox_target:removeZone(recipe.id) end
        })
    end
end


-- Tables
for tableName, tableData in pairs(Config.Tables) do
    tableZones[#tableZones + 1] = lib.zones.sphere({
        coords = tableData.coords.xyz,
        radius = 60.0,
        onEnter = function()
            local hash = GetHashKey(tableData.prop)
            if lib.requestModel(hash, 5000) then
                local obj = CreateObject(hash, tableData.coords.x, tableData.coords.y, tableData.coords.z, false, false, false)
                if not tableData.letFloat then PlaceObjectOnGroundProperly(obj) end
                FreezeEntityPosition(obj, true)
                spawnedTableObjects[tableName] = obj

                local options = {}
                for _, recipeId in ipairs(tableRecipes[tableName] or {}) do
                    local recipe = Config.Recipes[recipeId]
                    table.insert(options, {
                        name = recipe.id,
                        label = recipe.targetText,
                        icon = "fa-solid fa-flask",
                        onSelect = function() TriggerEvent("fn-drugs:openLabMenu", recipeId) end
                    })
                end
                exports.ox_target:addLocalEntity(obj, options)
            end
        end,
        onExit = function()
            if spawnedTableObjects[tableName] then
                DeleteObject(spawnedTableObjects[tableName])
                spawnedTableObjects[tableName] = nil
            end
        end
    })
end

lib.callback.register("fn-drugs:cl:startbar", function(time, label, skillCheck, anim)
    if skillCheck and not lib.skillCheck(skillCheck, {'1','2','3','4'}) then return false end
    return lib.progressBar({duration = time, label = label, anim = anim, canCancel = true})
end)