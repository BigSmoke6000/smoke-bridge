if Config.Target ~= 'qb' then return end

-- Bridge.Add* always take options in ox_target's shape (a single option table
-- or an array of them, each option's own `distance`/`onSelect`/`canInteract`).
-- qb-target instead wants one shared `distance` for the whole zone/entity and
-- a plain `action(entity)` callback, so this converts one shape to the other.
local function convert(options)
    if options.label or options.icon then options = { options } end

    local distance = 2.5
    for _, opt in pairs(options) do
        if opt.distance and opt.distance > distance then distance = opt.distance end

        local onSelect = opt.onSelect
        if onSelect then
            opt.action = function(entity)
                opt.entity = entity
                opt.coords = entity and GetEntityCoords(entity) or nil
                onSelect(opt)
            end
        end
    end

    return distance, options
end

function Bridge.AddBoxZone(id, coords, size, rotation, options, debug)
    local distance, opts = convert(options)
    exports['qb-target']:AddBoxZone(id, coords, size.y, size.x, {
        name = id,
        heading = rotation or 0.0,
        debugPoly = debug or false,
        minZ = coords.z - (size.z / 2),
        maxZ = coords.z + (size.z / 2),
    }, {
        options = opts,
        distance = distance
    })
end

function Bridge.AddSphereZone(id, coords, radius, options, debug)
    local distance, opts = convert(options)
    exports['qb-target']:AddCircleZone(id, coords, radius, {
        name = id,
        debugPoly = debug or false,
        useZ = true,
    }, {
        options = opts,
        distance = distance
    })
end

---Remove a zone created with Bridge.AddBoxZone/AddSphereZone.
function Bridge.RemoveZone(id)
    exports['qb-target']:RemoveZone(id)
end

function Bridge.AddEntityZone(entity, options)
    local distance, opts = convert(options)
    exports['qb-target']:AddTargetEntity(entity, { options = opts, distance = distance })
end

---@param labels? string|string[]
function Bridge.RemoveEntityZone(entity, labels)
    exports['qb-target']:RemoveTargetEntity(entity, labels)
end

function Bridge.AddModelZone(models, options)
    local distance, opts = convert(options)
    exports['qb-target']:AddTargetModel(models, { options = opts, distance = distance })
end

---@param labels? string|string[]
function Bridge.RemoveModelZone(models, labels)
    exports['qb-target']:RemoveTargetModel(models, labels)
end

function Bridge.AddGlobalPed(options)
    local distance, opts = convert(options)
    exports['qb-target']:AddGlobalPed({ options = opts, distance = distance })
end

---@param labels? string|string[]
function Bridge.RemoveGlobalPed(labels)
    exports['qb-target']:RemoveGlobalPed(labels)
end

function Bridge.AddGlobalVehicle(options)
    local distance, opts = convert(options)
    exports['qb-target']:AddGlobalVehicle({ options = opts, distance = distance })
end

---@param labels? string|string[]
function Bridge.RemoveGlobalVehicle(labels)
    exports['qb-target']:RemoveGlobalVehicle(labels)
end

function Bridge.AddGlobalObject(options)
    local distance, opts = convert(options)
    exports['qb-target']:AddGlobalObject({ options = opts, distance = distance })
end

---@param labels? string|string[]
function Bridge.RemoveGlobalObject(labels)
    exports['qb-target']:RemoveGlobalObject(labels)
end

function Bridge.AddGlobalPlayer(options)
    local distance, opts = convert(options)
    exports['qb-target']:AddGlobalPlayer({ options = opts, distance = distance })
end

---@param labels? string|string[]
function Bridge.RemoveGlobalPlayer(labels)
    exports['qb-target']:RemoveGlobalPlayer(labels)
end

---@param state boolean true to disable all targeting
function Bridge.DisableTargeting(state)
    -- qb-target's polarity is inverted vs ox_target: AllowTargeting(true) enables it.
    exports['qb-target']:AllowTargeting(not state)
end
