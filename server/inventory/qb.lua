if Config.Inventory ~= 'qb' then return end

local registeredStashes = {}
local registeredShops = {}

function Bridge.CanCarryItem(src, item, amount)
    local ok, res = pcall(function()
        return exports['qb-inventory']:CanAddItem(src, item, amount)
    end)
    if not ok then return true end
    return res ~= false
end

function Bridge.AddItem(src, item, amount)
    local ok, res = pcall(function()
        return exports['qb-inventory']:AddItem(src, item, amount or 1, false, false, 'smoke-bridge')
    end)
    return ok and res ~= false
end

function Bridge.RemoveItem(src, item, amount, slot)
    local ok, res = pcall(function()
        return exports['qb-inventory']:RemoveItem(src, item, amount or 1, slot, 'smoke-bridge')
    end)
    return ok and res ~= false
end

function Bridge.HasItem(src, item, amount)
    local ok, res = pcall(function()
        return exports['qb-inventory']:HasItem(src, item, amount or 1)
    end)
    if ok then return res ~= false end
    return Bridge.GetItemCount(src, item) >= (amount or 1)
end

function Bridge.GetItemCount(src, item)
    local ok, res = pcall(function()
        local found = exports['qb-inventory']:GetItemByName(src, item)
        return found and found.amount or 0
    end)
    return (ok and tonumber(res)) or 0
end

---@return table|nil the full item table in this slot (name/amount/info), nil if empty
---@note adjust the export name if your qb-inventory fork names it differently
function Bridge.GetItemBySlot(src, slot)
    local ok, item = pcall(function()
        return exports['qb-inventory']:GetItemBySlot(src, slot)
    end)
    return (ok and item) or nil
end

---@return number|nil the first slot number containing item, nil if none
function Bridge.GetFirstSlotByItem(src, item)
    local ok, slot = pcall(function()
        return exports['qb-inventory']:GetFirstSlotByItem(src, item)
    end)
    return (ok and slot) or nil
end

---@return table metadata for the item in this slot (empty table if none)
function Bridge.GetItemMetadata(src, slot)
    local item = Bridge.GetItemBySlot(src, slot)
    if not item then return {} end
    return item.info or item.metadata or {}
end

---@return boolean success
---@note real qb-inventory export is SetItemData, not SetItemMetadata - adjust if your fork differs
function Bridge.SetItemMetadata(src, slot, metadata)
    local ok, res = pcall(function()
        return exports['qb-inventory']:SetItemData(src, slot, 'info', metadata)
    end)
    return ok and res ~= false
end

---@return table every item the player carries
function Bridge.GetInventory(src)
    local ok, items = pcall(function()
        return exports['qb-inventory']:GetInventory(src)
    end)
    return (ok and items) or {}
end

---@param keep string|string[]|nil item name(s) to leave untouched
function Bridge.ClearInventory(src, keep)
    pcall(function()
        exports['qb-inventory']:ClearInventory(src, keep)
    end)
end

---Register a stash without opening it (use Bridge.OpenStash to also open one).
---@note qb-inventory forks differ on the exact stash-register export - adjust if yours doesn't match.
function Bridge.RegisterStash(id, slots, weight, owner, groups)
    registeredStashes[id] = true
end

---Register (once) and open a stash for a player.
---@note qb-inventory forks differ on the exact stash export - adjust if yours doesn't match.
function Bridge.OpenStash(src, id, slots, weight, label)
    Bridge.RegisterStash(id, slots, weight)

    pcall(function()
        exports['qb-inventory']:OpenInventory(src, id, {
            maxweight = weight,
            slots = slots,
            label = label or id
        })
    end)
end

---Register a shop. items is an array of { name, price, amount, info }.
function Bridge.RegisterShop(name, items, groups)
    if registeredShops[name] then return end
    registeredShops[name] = true
    pcall(function()
        exports['qb-inventory']:CreateShop({ name = name, label = name, slots = #items, items = items })
    end)
end

function Bridge.OpenShop(src, name)
    pcall(function()
        exports['qb-inventory']:OpenShop(src, name)
    end)
end

---Take everything away from the player (jail/impound use case) and remember it for ReturnInventory.
---@note qb-inventory has no confirmed native confiscate export - verify/adjust for your build.
function Bridge.ConfiscateInventory(src)
    local ok = pcall(function()
        return exports['qb-inventory']:ConfiscateInventory(src)
    end)
    if ok then return end

    Bridge.SetMetadata(src, 'smokeBridgeConfiscated', Bridge.GetInventory(src))
    Bridge.ClearInventory(src)
end

---Give back whatever was taken by ConfiscateInventory.
---@note qb-inventory has no confirmed native return export - verify/adjust for your build.
function Bridge.ReturnInventory(src)
    local ok = pcall(function()
        return exports['qb-inventory']:ReturnInventory(src)
    end)
    if ok then return end

    local confiscated = Bridge.GetMetadata(src, 'smokeBridgeConfiscated')
    if not confiscated then return end
    for _, item in pairs(confiscated) do
        if item and item.name then
            Bridge.AddItem(src, item.name, item.amount or item.count or 1, item.info or item.metadata, item.slot)
        end
    end
    Bridge.SetMetadata(src, 'smokeBridgeConfiscated', nil)
end

---@return table|nil currently-held weapon item, or nil if unarmed/unsupported
---@note qb-inventory has no confirmed export for this - verify/adjust for your build.
function Bridge.GetCurrentWeapon(src)
    local ok, weapon = pcall(function()
        return exports['qb-inventory']:GetCurrentWeapon(src)
    end)
    return (ok and weapon) or nil
end

---@note qb-inventory has no confirmed durability export - verify/adjust for your build.
function Bridge.SetDurability(src, slot, durability)
    local ok, res = pcall(function()
        return exports['qb-inventory']:SetDurability(src, slot, durability)
    end)
    return ok and res ~= false
end

---@return number free weight the player has left
function Bridge.GetFreeWeight(src)
    local ok, weight = pcall(function()
        return exports['qb-inventory']:GetFreeWeight(src)
    end)
    return (ok and tonumber(weight)) or math.huge
end
