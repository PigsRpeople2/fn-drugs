AddEventHandler("asd-chopping:tryOpenSellMenu", function()
    TriggerServerEvent("asd-chopping:openSellMenu")
end)

AddEventHandler("asd-chopping:tryOpenExchangeMenu", function()
    TriggerServerEvent("asd-chopping:openExchangeMenu")
end)







RegisterNetEvent("fn-drugs:openLabMenu", function(recipeId)
    print(recipeId)
    local recipe = Config.Recipes[recipeId]
    if not recipe then return end
    local options = {}
    for _, item in ipairs(recipe.ingredients) do
        local itemCount = exports.ox_inventory:GetItemCount(item.item)
        print(item.item, itemCount)
        if itemCount <= 0 then
            lib.notify({ title = "Missing Ingredients", description = "You don't have the required ingredients.", type = "error" })
            return
        end
    end



    
    local description = ""

    for _, v in pairs(recipe.ingredients) do
        local itemCount = exports.ox_inventory:GetItemCount(v.item)
        description = description .. ("%s x %s\n"):format(v.amount, v.item)
    end

    local label = "Processing..."


    local max = math.huge

    for k, v in pairs(recipe.ingredients) do
        local itemCount = exports.ox_inventory:GetItemCount(v.item)
        local possibleCrafts = math.floor(itemCount / v.amount)
        if possibleCrafts < max then 
            max = possibleCrafts
        end
    end

    local values = {}

    local descrEnd = ""
    if recipe.revealOutput then 
        descrEnd = recipe.output.label
        label = recipe.output.label .. " " .. label
    end

    for i = 1, max do table.insert(values, "Process " .. i .. " " .. descrEnd) end

    

    table.insert(options, {
        label = "Process All",
        icon = "fa-solid fa-flask",
        args = { type = "all", data = recipeId, max = max }
    })

    table.insert(options, {
        label = label,
        description = description, 
        args = { type = "single", data = recipeId },
        values = values
    })

    lib.registerMenu({
        id = recipe.id.."_menu",
        title = recipe.targetText,
        position = 'bottom-right',
        options = options,
    }, function(selected, scrollIndex, args)
        if args.type == "all" then
            TriggerServerEvent("fn-drugs:server:startProcess", args.data, args.max)
        else
            TriggerServerEvent("fn-drugs:server:startProcess", args.data, scrollIndex)
        end
    end)
    lib.showMenu(recipe.id.."_menu")
end)







RegisterNetEvent("asd-chopping:openSellMenu", function(items)
    local options = {}
    local grandTotal = 0

    for _, v in pairs(items) do
        grandTotal = grandTotal + (v.price * v.count)
    end

    if #items > 1 then
        table.insert(options, {
            label = "Sell All",
            icon = "fa-solid fa-hand-holding-dollar",
            description = ("Total Earnings: $%s"):format(grandTotal),
            args = { type = "all", items = items }
        })
    end

    for _, v in pairs(items) do
        local values = {}
        for i = 1, v.count do table.insert(values, "Sell " .. i) end
        
        local stackValue = v.price * v.count

        table.insert(options, {
            label = v.label,
            description = ("$%s each | Stack Value: $%s"):format(v.price, stackValue), 
            args = { type = "single", data = v },
            values = values
        })
    end

    if #options == 0 then
        return lib.notify({ title = 'No Items', description = 'You have no vehicle parts to sell!', type = 'warning' })
    end

    lib.registerMenu({
        id = 'sell',
        title = 'Shady Bob',
        position = 'bottom-right',
        options = options,
    }, function(selected, scrollIndex, args)
        if args.type == "all" then
            TriggerServerEvent("asd-chopping:sellAllParts")
        else
            args.data.trySellCount = scrollIndex
            TriggerServerEvent("asd-chopping:sellVehiclePart", args.data)
        end
    end)
    lib.showMenu('sell')
end)

RegisterNetEvent("asd-chopping:openExchangeMenu", function(items)
    local options = {}

    if #items > 1 then
        table.insert(options, {
            label = "Exchange All",
            icon = "fa-solid fa-recycle",
            description = "Scrap everything in your pockets for materials",
            args = { type = "all", items = items }
        })
    end

    for _, v in pairs(items) do
        local values = {}
        for i = 1, v.count do table.insert(values, "Scrap " .. i) end
        
        table.insert(options, {
            label = v.label,
            icon = "fa-solid fa-gears",
            description = ("Scrap for materials"), 
            args = { type = "single", data = v },
            values = values
        })
    end

    if #options == 0 then
        return lib.notify({ title = 'Nothing to Scrap', description = 'You have no vehicle parts to exchange!', type = 'warning' })
    end

    lib.registerMenu({
        id = 'exchange_menu',
        title = 'Scrap Yard Exchange',
        position = 'bottom-right',
        options = options,
    }, function(selected, scrollIndex, args)
        if args.type == "all" then
            TriggerServerEvent("asd-chopping:exchangeAllParts")
        else
            args.data.amount = scrollIndex
            TriggerServerEvent("asd-chopping:exchangePart", args.data)
        end
    end)
    lib.showMenu('exchange_menu')
end)