local storeZones = {}
local spawnedStorePeds = {}
local storeLockouts = {}

local function GetPlayerGender()
    local ped = cache.ped
    local model = GetEntityModel(ped)
    local femaleHash = -1667301416
    local gender = "male"
    if model == femaleHash then 
        gender = "female"
    end
    return gender
end

local function ResetToIdle(entity, storeKey)
    local data = Config.Stores[storeKey]
    if not data then return end
    
    if data.idleDict and data.idleAnim then
        lib.playAnim(entity, data.idleDict, data.idleAnim, 8.0, -8.0, -1, 1)
    elseif data.idleScenario then
        TaskStartScenarioInPlace(entity, data.idleScenario, 0, true)
    end
end

local function PlayEmote(entity, storeKey, emoteName, dict, anim)
    if entity == cache.ped then
        if emoteName and GetResourceState('rpemotes-reborn') == 'started' then
            exports["rpemotes-reborn"]:EmoteCommandStart(emoteName)
        end
    else
        if dict and anim then
            lib.playAnim(entity, dict, anim, 8.0, -8.0, 3000, 0) 
            SetTimeout(3000, function()
                if DoesEntityExist(entity) then
                    ResetToIdle(entity, storeKey)
                end
            end)
        elseif emoteName then
            TaskStartScenarioInPlace(entity, emoteName, 0, true)
        end
    end
end

local function CancelEmote(entity, storeKey)
    if entity == cache.ped then
        if GetResourceState('rpemotes-reborn') == 'started' then
            exports["rpemotes-reborn"]:EmoteCancel(true)
        end
    else
        ClearPedTasks(entity)
        if storeKey then ResetToIdle(entity, storeKey) end
    end
end

local function CleanupStoreSystem()
    for _, zone in pairs(storeZones) do zone:remove() end
    for _, ped in pairs(spawnedStorePeds) do
        if DoesEntityExist(ped) then DeleteEntity(ped) end
    end
    storeZones = {}
    spawnedStorePeds = {}
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    CleanupStoreSystem()
end)

function OpenStoreDialogue(storeKey)
    local data = Config.Stores[storeKey]
    local currentTime = GetGameTimer()
    local gender = GetPlayerGender()

    if storeLockouts[storeKey] and currentTime < storeLockouts[storeKey] then
        local remaining = math.ceil((storeLockouts[storeKey] - currentTime) / 60000)
        lib.notify({ title = data.name, description = "This vendor refuses to speak with you. Try again in "..remaining.." mins.", type = "error" })
        return
    end

    lib.registerContext({
        id = 'store_welcome_' .. storeKey,
        title = data.name,
        options = {
            {
                title = "Talk to " .. data.name,
                description = data.welcome,
                icon = 'comments',
                readOnly = true
            },
            {
                title = "Choose an approach...",
                icon = 'user-ninja',
                onSelect = function()
                    local options = {}
                    for choiceId, choiceData in pairs(data.choices) do
                        local isAllowed = false
                        for _, allowedGender in ipairs(choiceData.gender) do
                            if allowedGender == gender then isAllowed = true break end
                        end

                        if isAllowed then
                            table.insert(options, {
                                title = choiceData.label,
                                description = choiceData.dialogue[gender],
                                icon = 'chevron-right',
                                onSelect = function()
                                    ProcessNegotiation(storeKey, choiceId)
                                end
                            })
                        end
                    end
                    lib.registerContext({
                        id = 'store_choices_' .. storeKey,
                        title = "Your Approach",
                        menu = 'store_welcome_' .. storeKey,
                        options = options
                    })
                    lib.showContext('store_choices_' .. storeKey)
                end
            }
        }
    })
    lib.showContext('store_welcome_' .. storeKey)
end

function ProcessNegotiation(storeKey, choiceId)
    local store = Config.Stores[storeKey]
    local choice = store.choices[choiceId]
    local npc = spawnedStorePeds[storeKey]
    local gender = GetPlayerGender()
    
    PlayEmote(cache.ped, storeKey, choice.emote)

    if lib.progressBar({ duration = 3000, label = "Negotiating...", canCancel = true, disable = { move = true, car = true, combat = true } }) then
        local result = lib.callback.await("fn-stores:sv:processChoice", false, storeKey, choiceId)
        CancelEmote(cache.ped)

        if result.success then
            if npc then PlayEmote(npc, storeKey, nil, choice.npcSuccessDict, choice.npcSuccessAnim) end
            lib.alertDialog({
                header = store.name,
                content = choice.success[gender],
                centered = true,
                cancel = false
            })
            OpenShopMenu(storeKey, result.priceMultiplier)
        else
            if npc then PlayEmote(npc, storeKey, nil, choice.npcFailDict, choice.npcFailAnim) end
            
            local failText = (result.reason == "no_money") and choice.noMoney[gender] or choice.failReply[gender]

            lib.alertDialog({
                header = store.name,
                content = failText,
                centered = true,
                cancel = false
            })

            if result.lockout then
                storeLockouts[storeKey] = GetGameTimer() + (10 * 60 * 1000)
            else
                OpenShopMenu(storeKey, 1.0)
            end
            
            if npc then ResetToIdle(npc, storeKey) end
        end
    else
        CancelEmote(cache.ped)
        if npc then ResetToIdle(npc, storeKey) end
    end
end

function OpenShopMenu(storeKey, multiplier)
    local store = Config.Stores[storeKey]
    local options = {}

    for i, item in ipairs(store.items) do
        local finalPrice = math.max(item.minPrice, math.floor(item.basePrice * multiplier))
        table.insert(options, {
            title = item.label,
            description = ("Price: $%s | Limit: %s"):format(finalPrice, item.stock),
            icon = 'tag',
            onSelect = function()
                local amount = lib.inputDialog('Purchase ' .. item.label, {
                    {type = 'number', label = 'Amount', description = 'Max ' .. item.stock, default = 1, min = 1, max = item.stock},
                })
                if amount and amount[1] then
                    TriggerServerEvent("fn-stores:sv:buyItem", storeKey, i, finalPrice, amount[1])
                end
            end
        })
    end

    lib.registerContext({
        id = 'store_shop_' .. storeKey,
        title = store.name .. " - Catalog",
        onExit = function()
            local npc = spawnedStorePeds[storeKey]
            if npc then ResetToIdle(npc, storeKey) end
        end,
        options = options
    })
    lib.showContext('store_shop_' .. storeKey)
end

for storeKey, data in pairs(Config.Stores) do
    storeZones[storeKey] = lib.zones.sphere({
        coords = data.coords.xyz,
        radius = 150.0,
        onEnter = function()
            lib.requestModel(data.pedModel, 5000)
            local ped = CreatePed(4, data.pedModel, data.coords.x, data.coords.y, data.coords.z - 1.0, data.coords.w, false, false)
            SetEntityInvincible(ped, true)
            FreezeEntityPosition(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            spawnedStorePeds[storeKey] = ped

            ResetToIdle(ped, storeKey)

            exports.ox_target:addLocalEntity(ped, {
                {
                    label = "Talk to " .. data.name,
                    icon = "fa-solid fa-" .. (data.icon or "shop"),
                    onSelect = function()
                        OpenStoreDialogue(storeKey)
                    end
                }
            })
        end,
        onExit = function()
            if DoesEntityExist(spawnedStorePeds[storeKey]) then
                DeleteEntity(spawnedStorePeds[storeKey])
                spawnedStorePeds[storeKey] = nil
            end
        end
    })
end