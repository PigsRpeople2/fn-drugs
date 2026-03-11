local zones = {}

for k, v in pairs(Config.HarvestingSpots) do
    zones[#zones + 1] = lib.zones.sphere({
        coords = v.position,
        radius = v.renderDist or 10.0, 
        debug = false,
        onEnter = function(self)
            if v.prop then
                if lib.requestModel(v.prop.model, 5000) then
                    self.spawnedObj = CreateObject(v.prop.model, v.prop.pos.x, v.prop.pos.y, v.prop.pos.z, false, false, false)
                    SetEntityHeading(self.spawnedObj, v.prop.heading or 0.0)
                    FreezeEntityPosition(self.spawnedObj, true)
                    SetEntityAsMissionEntity(self.spawnedObj, true, true)
                    SetModelAsNoLongerNeeded(v.prop.model)
                end
            end
        end,
        onExit = function(self)
            if self.spawnedObj and DoesEntityExist(self.spawnedObj) then
                DeleteEntity(self.spawnedObj)
                self.spawnedObj = nil
            end
            lib.hideTextUI()
            self.isPromptShowing = false
        end,
        inside = function(self)
            local playerCoords = GetEntityCoords(cache.ped)
            local dist = #(playerCoords - v.position)

            if dist <= (v.interactDist or 2.0) then
                if not self.isPromptShowing then
                    lib.showTextUI(("[E] - Harvest %s"):format(v.label), { icon = v.icon })
                    self.isPromptShowing = true
                end

                if IsControlJustReleased(0, 38) and not IsPedInAnyVehicle(cache.ped, true) then
                    local success = lib.progressCircle({
                        duration = v.time,
                        label = ("Harvesting %s"):format(v.label),
                        position = 'bottom',
                        useWhileDead = false,
                        canCancel = true,
                        disable = { move = true, car = true, combat = true },
                        anim = {
                            dict = "amb@world_human_gardener_plant@male@idle_a",
                            clip = "idle_b",
                        },
                    })

                    if success then
                        local hasSpace = lib.callback.await("fn-drugs:sv:requestPick", false, k)
                        if not hasSpace then
                            lib.notify({ title = "Inventory Full", description = "You cannot carry any more.", type = "error" })
                        end
                    end
                end
            else
                if self.isPromptShowing then
                    lib.hideTextUI()
                    self.isPromptShowing = false
                end
            end
        end,
    })
end