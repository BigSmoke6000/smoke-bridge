if Config.Target ~= 'custom' then return end

--------------------------------------------------------------------------
-- CUSTOM TARGET BRIDGE (client)
--
-- Set Config.Target = 'custom' in smoke-bridge/config.lua, then fill in the
-- functions below with your target resource's exports. Options are always
-- passed in ox_target's shape - a single `{ icon, label, onSelect,
-- canInteract, distance, ... }` table or an array of them - since that's
-- what every smoke-* script writes against. If your target resource wants a
-- different shape (a shared zone-level distance instead of per-option, a
-- plain `action(entity)` instead of `onSelect(data)`, etc.), see
-- client/target/qb.lua's `convert()` helper for a worked example of
-- translating between the two.
--------------------------------------------------------------------------

---@param options table single option table or an array of them
function Bridge.AddBoxZone(id, coords, size, rotation, options, debug)
    -- EXAMPLE:
    -- exports['my-target']:AddBoxZone(id, coords, size, rotation, options)
end

function Bridge.AddSphereZone(id, coords, radius, options, debug)
    -- EXAMPLE:
    -- exports['my-target']:AddSphereZone(id, coords, radius, options)
end

---Remove a zone created with Bridge.AddBoxZone/AddSphereZone.
function Bridge.RemoveZone(id)
    -- EXAMPLE:
    -- exports['my-target']:RemoveZone(id)
end

---@param entity number|number[]
function Bridge.AddEntityZone(entity, options)
    -- EXAMPLE:
    -- exports['my-target']:AddEntity(entity, options)
end

---@param entity number|number[]
---@param labels? string|string[]
function Bridge.RemoveEntityZone(entity, labels)
    -- EXAMPLE:
    -- exports['my-target']:RemoveEntity(entity, labels)
end

---@param models number|string|(number|string)[]
function Bridge.AddModelZone(models, options)
    -- EXAMPLE:
    -- exports['my-target']:AddModel(models, options)
end

---@param models number|string|(number|string)[]
---@param labels? string|string[]
function Bridge.RemoveModelZone(models, labels)
    -- EXAMPLE:
    -- exports['my-target']:RemoveModel(models, labels)
end

function Bridge.AddGlobalPed(options)
    -- EXAMPLE:
    -- exports['my-target']:AddGlobalPed(options)
end

---@param labels? string|string[]
function Bridge.RemoveGlobalPed(labels) end

function Bridge.AddGlobalVehicle(options)
    -- EXAMPLE:
    -- exports['my-target']:AddGlobalVehicle(options)
end

---@param labels? string|string[]
function Bridge.RemoveGlobalVehicle(labels) end

function Bridge.AddGlobalObject(options)
    -- EXAMPLE:
    -- exports['my-target']:AddGlobalObject(options)
end

---@param labels? string|string[]
function Bridge.RemoveGlobalObject(labels) end

function Bridge.AddGlobalPlayer(options)
    -- EXAMPLE:
    -- exports['my-target']:AddGlobalPlayer(options)
end

---@param labels? string|string[]
function Bridge.RemoveGlobalPlayer(labels) end

---@param state boolean true to disable all targeting
function Bridge.DisableTargeting(state)
    -- EXAMPLE:
    -- exports['my-target']:DisableTargeting(state)
end
