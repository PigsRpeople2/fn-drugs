RegisterNetEvent("fn-drugs:openLabMenu", function(recipeId)
    local recipe = Config.Recipes[recipeId]
    if not recipe then return end

    local options = {}
    local maxCrafts = math.huge

    local ingredientDescription = "Requires:\n"
    for _, ingredient in ipairs(recipe.ingredients) do
        local itemCount = exports.ox_inventory:GetItemCount(ingredient.item)
        local possible = math.floor(itemCount / ingredient.amount)
        
        if possible < maxCrafts then maxCrafts = possible end
        
        ingredientDescription = ingredientDescription .. ("- %s x%d (Have: %d)\n"):format(ingredient.item, ingredient.amount, itemCount)
    end

    if maxCrafts <= 0 then
        return lib.notify({ title = "Missing Ingredients", description = "You don't have enough materials.", type = "error" })
    end

    local primaryOutput = recipe.outputs[1] 
    local displayLabel = "Processing..."
    local menuTitle = recipe.targetText

    if recipe.revealOutput and primaryOutput then
        displayLabel = primaryOutput.label or primaryOutput.item
        menuTitle = ("Craft %s"):format(displayLabel)
    end

    local amountValues = {}
    for i = 1, maxCrafts do 
        table.insert(amountValues, ("Process x%d"):format(i)) 
    end

    table.insert(options, {
        label = "Start Processing",
        description = ingredientDescription,
        icon = "fa-solid fa-flask-vial",
        values = amountValues,
        args = { recipeId = recipeId }
    })

    table.insert(options, {
        label = "Process All",
        icon = "fa-solid fa-forward",
        description = ("Craft the maximum amount: %d"):format(maxCrafts),
        args = { recipeId = recipeId, isMax = true, amount = maxCrafts }
    })

    lib.registerMenu({
        id = 'drug_lab_menu',
        title = menuTitle,
        position = 'bottom-right',
        options = options,
        onClose = function() end,
    }, function(selected, scrollIndex, args)
        local amount = args.isMax and args.amount or scrollIndex
        if amount > 0 then
            TriggerServerEvent("fn-drugs:server:startProcess", args.recipeId, amount)
        end
    end)

    lib.showMenu('drug_lab_menu')
end)