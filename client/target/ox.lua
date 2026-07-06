if Config.Target ~= 'ox' then return end

-- ox_target's addBoxZone/addSphereZone return a numeric zone id used to remove
-- it later - this maps our own chosen `id` to that returned id.
local zoneIds = {}

---@param options table single option `{ icon, label, onSelect, canInteract, distance, ... }` or an array of them
function Bridge.AddBoxZone(id, coords, size, rotation, options, debug)
    zoneIds[id] = exports.ox_target:addBoxZone({
        coords = coords,
        size = size,
        rotation = rotation or 0.0,
        debug = debug or false,
        options = options
    })
end

function Bridge.AddSphereZone(id, coords, radius, options, debug)
    zoneIds[id] = exports.ox_target:addSphereZone({
        coords = coords,
        radius = radius,
        debug = debug or false,
        options = options
    })
end

---Remove a zone created with Bridge.AddBoxZone/AddSphereZone.
function Bridge.RemoveZone(id)
    local zoneId = zoneIds[id]
    exports.ox_target:removeZone(zoneId or id, true)
    zoneIds[id] = nil
end

---@param entity number|number[] local entity handle(s)
function Bridge.AddEntityZone(entity, options)
    exports.ox_target:addLocalEntity(entity, options)
end

---@param entity number|number[]
---@param labels? string|string[] option name(s) to remove; omit to remove all
function Bridge.RemoveEntityZone(entity, labels)
    exports.ox_target:removeLocalEntity(entity, labels)
end

---@param models number|string|(number|string)[]
function Bridge.AddModelZone(models, options)
    exports.ox_target:addModel(models, options)
end

---@param models number|string|(number|string)[]
---@param labels? string|string[]
function Bridge.RemoveModelZone(models, labels)
    exports.ox_target:removeModel(models, labels)
end

function Bridge.AddGlobalPed(options)
    exports.ox_target:addGlobalPed(options)
end

---@param labels? string|string[]
function Bridge.RemoveGlobalPed(labels)
    exports.ox_target:removeGlobalPed(labels)
end

function Bridge.AddGlobalVehicle(options)
    exports.ox_target:addGlobalVehicle(options)
end

---@param labels? string|string[]
function Bridge.RemoveGlobalVehicle(labels)
    exports.ox_target:removeGlobalVehicle(labels)
end

function Bridge.AddGlobalObject(options)
    exports.ox_target:addGlobalObject(options)
end

---@param labels? string|string[]
function Bridge.RemoveGlobalObject(labels)
    exports.ox_target:removeGlobalObject(labels)
end

function Bridge.AddGlobalPlayer(options)
    exports.ox_target:addGlobalPlayer(options)
end

---@param labels? string|string[]
function Bridge.RemoveGlobalPlayer(labels)
    exports.ox_target:removeGlobalPlayer(labels)
end

---@param state boolean true to disable all targeting
function Bridge.DisableTargeting(state)
    exports.ox_target:disableTargeting(state)
end
