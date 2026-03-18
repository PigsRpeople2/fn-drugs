lib.callback.register('fn-drugs:Combine', function(itemA, itemB)
    local success = lib.progressCircle({
        duration = 2000,
        label = ('Combining %s and %s..'):format(itemA, itemB),
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true,
        },
        anim = {
            dict = 'amb@prop_human_parking_meter@male@base',
            clip = 'base',
            flag = 49
        },
    })

    return success 
end)