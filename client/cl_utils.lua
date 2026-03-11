hasScrappingJob = false
currentScrappingJobLocations = {}
jobBlips = {}
lastJobGetTime = 0
isPlayerScrapping = false

function WaypointHelper()
    local pCoords = GetEntityCoords(cache.ped or PlayerPedId())
    table.sort(currentScrappingJobLocations, function(a, b)
        local distA = #(pCoords - a)
        local distB = #(pCoords - b)
        return distA < distB
    end)
end

function clearScrappingJobs()
    ClearAllBlipRoutes()
    for _, v in pairs(jobBlips) do
        RemoveBlip(v)
    end
    jobBlips = {}
    hasScrappingJob = false
    currentScrappingJobLocations = {}
    isPlayerScrapping = false
end

function clearSpecificJob(coords)
    local _jobIndex = nil
    for k, v in pairs(currentScrappingJobLocations) do
        if #(v - coords) < 3.0 then
            _jobIndex = k
            break
        end
    end

    if _jobIndex then
        table.remove(currentScrappingJobLocations, _jobIndex)
        if jobBlips[_jobIndex] then
            RemoveBlip(jobBlips[_jobIndex])
            table.remove(jobBlips, _jobIndex)
        end
    end

    if #currentScrappingJobLocations == 0 then
        hasScrappingJob = false
    else
        WaypointHelper()
        ClearAllBlipRoutes()
        if jobBlips[1] then 
            SetBlipRoute(jobBlips[1], true) 
        end
    end
    isPlayerScrapping = false
end

function canChopVehicle()
    if not hasScrappingJob or isPlayerScrapping then return false end
    local pCoords = GetEntityCoords(cache.ped or PlayerPedId())
    for _, v in pairs(currentScrappingJobLocations) do
        if #(pCoords - v) <= 5.0 then return true end
    end
    return false
end