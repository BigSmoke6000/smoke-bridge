if Config.Target ~= 'drawtext' then return end

--------------------------------------------------------------------------
-- DRAWTEXT FALLBACK
-- For servers that don't want to install ox_target or qb-target at all.
-- Distance-based only (no raycasting - it can't tell exactly what you're
-- looking at, just what's nearest) - shows a floating 3D prompt when you're
-- near a registered zone/entity/model and fires onSelect when you press
-- Config.TargetKey (default E). Same Bridge.Add*/Remove* surface as the
-- ox_target/qb-target adapters, so scripts don't need to care which one
-- is active.
--
-- Global ped/vehicle/object/player watchers scan the *entire* relevant
-- entity pool every check - much more expensive than ox_target/qb-target's
-- engine-level implementation. Fine for a couple of watchers on a server
-- with no target resource; avoid leaning on them heavily.
--------------------------------------------------------------------------

local watchers = {}
local disabled = false

local function normalizeOptions(options)
    if options.label or options.icon then return { options } end
    return options
end

local function resolveOption(options, entity)
    for _, opt in ipairs(options) do
        if not opt.canInteract or opt.canInteract(entity, 0, opt) then
            return opt
        end
    end
    return nil
end

local function drawText3D(coords, text)
    local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)
    if not onScreen then return end
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    SetTextCentre(true)
    AddTextComponentString(text)
    DrawText(x, y)
end

local function addWatcher(id, distance, check)
    watchers[id] = { distance = distance, check = check }
end

CreateThread(function()
    while true do
        local waitTime = 500

        if not disabled then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local closestCoords, closestDist, closestEntity, closestOpt

            for _, watcher in pairs(watchers) do
                local coords, entity, options = watcher.check(playerCoords)
                if coords then
                    local dist = #(playerCoords - coords)
                    if dist <= watcher.distance and (not closestDist or dist < closestDist) then
                        local opt = resolveOption(options, entity)
                        if opt then
                            closestCoords, closestDist, closestEntity, closestOpt = coords, dist, entity, opt
                        end
                    end
                end
            end

            if closestOpt then
                waitTime = 0
                drawText3D(closestCoords, ('[%s] %s'):format(Config.TargetKeyLabel or 'E', closestOpt.label or ''))

                if IsControlJustReleased(0, Config.TargetKey or 38) then
                    closestOpt.entity = closestEntity
                    closestOpt.coords = closestCoords
                    closestOpt.distance = closestDist
                    closestOpt.onSelect(closestOpt)
                end
            end
        end

        Wait(waitTime)
    end
end)

function Bridge.AddBoxZone(id, coords, size, rotation, options, debug)
    -- Approximated as a sphere (no rotation-aware box check) - good enough for a proximity prompt.
    local radius = math.max(size.x, size.y) / 2
    options = normalizeOptions(options)
    addWatcher(id, radius, function() return coords, nil, options end)
end

function Bridge.AddSphereZone(id, coords, radius, options, debug)
    options = normalizeOptions(options)
    addWatcher(id, radius, function() return coords, nil, options end)
end

---Remove a zone created with Bridge.AddBoxZone/AddSphereZone.
function Bridge.RemoveZone(id)
    watchers[id] = nil
end

function Bridge.AddEntityZone(entity, options)
    options = normalizeOptions(options)
    local id = ('entity:%s'):format(entity)
    addWatcher(id, options.distance or 2.5, function()
        if not DoesEntityExist(entity) then return nil end
        return GetEntityCoords(entity), entity, options
    end)
end

function Bridge.RemoveEntityZone(entity)
    watchers[('entity:%s'):format(entity)] = nil
end

local function toHashes(models)
    if type(models) ~= 'table' then models = { models } end
    local hashes = {}
    for i, model in ipairs(models) do
        hashes[i] = type(model) == 'string' and joaat(model) or model
    end
    return hashes
end

function Bridge.AddModelZone(models, options)
    options = normalizeOptions(options)
    local hashes = toHashes(models)
    local id = ('model:%s'):format(table.concat(hashes, ','))

    addWatcher(id, options.distance or 2.5, function(playerCoords)
        for _, pool in ipairs({ 'CObject', 'CPed', 'CVehicle' }) do
            local entities = GetGamePool(pool)
            for i = 1, #entities do
                local entity = entities[i]
                local model = GetEntityModel(entity)
                for _, hash in ipairs(hashes) do
                    if model == hash then return GetEntityCoords(entity), entity, options end
                end
            end
        end
        return nil
    end)
end

function Bridge.RemoveModelZone(models)
    local hashes = toHashes(models)
    watchers[('model:%s'):format(table.concat(hashes, ','))] = nil
end

local function addGlobalWatcher(id, pool, options)
    options = normalizeOptions(options)
    addWatcher(id, options.distance or 2.5, function(playerCoords)
        local playerPed = PlayerPedId()
        local entities = pool == 'player' and GetActivePlayers() or GetGamePool(pool)
        local nearest, nearestDist

        for i = 1, #entities do
            local entity = pool == 'player' and GetPlayerPed(entities[i]) or entities[i]
            if entity ~= playerPed and DoesEntityExist(entity) then
                local dist = #(playerCoords - GetEntityCoords(entity))
                if not nearestDist or dist < nearestDist then
                    nearest, nearestDist = entity, dist
                end
            end
        end

        if not nearest then return nil end
        return GetEntityCoords(nearest), nearest, options
    end)
end

function Bridge.AddGlobalPed(options)
    addGlobalWatcher('global:ped', 'CPed', options)
end

function Bridge.RemoveGlobalPed()
    watchers['global:ped'] = nil
end

function Bridge.AddGlobalVehicle(options)
    addGlobalWatcher('global:vehicle', 'CVehicle', options)
end

function Bridge.RemoveGlobalVehicle()
    watchers['global:vehicle'] = nil
end

function Bridge.AddGlobalObject(options)
    addGlobalWatcher('global:object', 'CObject', options)
end

function Bridge.RemoveGlobalObject()
    watchers['global:object'] = nil
end

function Bridge.AddGlobalPlayer(options)
    addGlobalWatcher('global:player', 'player', options)
end

function Bridge.RemoveGlobalPlayer()
    watchers['global:player'] = nil
end

---@param state boolean true to disable all targeting
function Bridge.DisableTargeting(state)
    disabled = state
end
