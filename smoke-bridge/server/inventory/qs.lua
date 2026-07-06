if Config.Inventory ~= 'qs' then return end

local registeredStashes = {}
local registeredShops = {}
local STASH_REGISTER_WAIT_MS = 250
local STASH_REGISTER_TIMEOUT_MS = 1500

---@return boolean whether the player has space/weight for the item
function Bridge.CanCarryItem(src, item, amount)
    local ok, res = pcall(function()
        return exports['qs-inventory']:CanCarryItem(src, item, amount)
    end)
    if not ok then return true end -- export missing on older qs builds; let AddItem decide
    return res ~= false
end

---@return boolean success
function Bridge.AddItem(src, item, amount, metadata, slot)
    local ok, res = pcall(function()
        return exports['qs-inventory']:AddItem(src, item, amount or 1, slot, metadata)
    end)
    return ok and res ~= false
end

---@return boolean success
function Bridge.RemoveItem(src, item, amount, slot)
    local ok, res = pcall(function()
        return exports['qs-inventory']:RemoveItem(src, item, amount or 1, slot)
    end)
    return ok and res ~= false
end

---@return boolean whether the player carries at least `amount` of item
function Bridge.HasItem(src, item, amount)
    return Bridge.GetItemCount(src, item) >= (amount or 1)
end

---@return number total amount of item the player carries
function Bridge.GetItemCount(src, item)
    local ok, res = pcall(function()
        return exports['qs-inventory']:GetItemTotalAmount(src, item)
    end)
    return (ok and tonumber(res)) or 0
end

---@return table|nil the full item table in this slot (name/amount/metadata), nil if empty
function Bridge.GetItemBySlot(src, slot)
    local ok, item = pcall(function()
        return exports['qs-inventory']:GetItemBySlot(src, slot)
    end)
    return (ok and item) or nil
end

---@return number|nil the first slot number containing item, nil if none
function Bridge.GetFirstSlotByItem(src, item)
    for slot, data in pairs(Bridge.GetInventory(src)) do
        if data and data.name == item then return tonumber(slot) or slot end
    end
    return nil
end

---@return table metadata for the item in this slot (empty table if none)
function Bridge.GetItemMetadata(src, slot)
    local item = Bridge.GetItemBySlot(src, slot)
    if not item then return {} end
    return item.info or item.metadata or {}
end

---@return boolean success
---@note adjust the export name if your qs-inventory fork names it differently
function Bridge.SetItemMetadata(src, slot, metadata)
    local ok, res = pcall(function()
        return exports['qs-inventory']:SetItemMetadata(src, slot, metadata)
    end)
    return ok and res ~= false
end

---@return table every item the player carries, keyed by slot
function Bridge.GetInventory(src)
    local ok, items = pcall(function()
        return exports['qs-inventory']:GetInventory(src)
    end)
    return (ok and items) or {}
end

---@param keep string|string[]|nil item name(s) to leave untouched
function Bridge.ClearInventory(src, keep)
    pcall(function()
        exports['qs-inventory']:ClearInventory(src, keep)
    end)
end

---Register a stash without opening it (use Bridge.OpenStash to also open one).
function Bridge.RegisterStash(id, slots, weight, owner, groups)
    if registeredStashes[id] then return end
    registeredStashes[id] = true
    pcall(function()
        exports['qs-inventory']:RegisterStash(id, id, slots, weight, owner, groups)
    end)
end

---Register (once) and open a stash for a player.
function Bridge.OpenStash(src, id, slots, weight, label)
    local waited = 0
    while registeredStashes[id] == 'pending' and waited < STASH_REGISTER_TIMEOUT_MS do
        Wait(50)
        waited = waited + 50
    end

    if registeredStashes[id] == 'pending' then
        registeredStashes[id] = nil
    end

    if not registeredStashes[id] then
        registeredStashes[id] = 'pending'
        exports['qs-inventory']:RegisterStash(src, id, slots, weight, label or id)
        Wait(STASH_REGISTER_WAIT_MS)
        registeredStashes[id] = true
    end

    exports['qs-inventory']:OpenInventory('stash', id, {
        maxweight = weight,
        slots = slots,
        label = label or id
    }, src)
end

---@note qs-inventory has no confirmed native shop registration export - verify/adjust for your build.
function Bridge.RegisterShop(name, items, groups)
    if registeredShops[name] then return end
    registeredShops[name] = true
    pcall(function()
        exports['qs-inventory']:CreateShop({ name = name, items = items, groups = groups })
    end)
end

---@note qs-inventory has no confirmed native shop-open export - verify/adjust for your build.
function Bridge.OpenShop(src, name)
    pcall(function()
        exports['qs-inventory']:OpenShop(src, name)
    end)
end

---Take everything away from the player (jail/impound use case) and remember it for ReturnInventory.
function Bridge.ConfiscateInventory(src)
    local ok, res = pcall(function()
        return exports['qs-inventory']:ConfiscateInventory(src)
    end)
    if ok then return end

    -- Fallback: no confirmed native confiscate export - snapshot and clear manually.
    Bridge.SetMetadata(src, 'smokeBridgeConfiscated', Bridge.GetInventory(src))
    Bridge.ClearInventory(src)
end

---Give back whatever was taken by ConfiscateInventory.
function Bridge.ReturnInventory(src)
    local ok = pcall(function()
        exports['qs-inventory']:ReturnInventory(src)
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
---@note qs-inventory has no confirmed export for this - verify/adjust for your build.
function Bridge.GetCurrentWeapon(src)
    local ok, weapon = pcall(function()
        return exports['qs-inventory']:GetCurrentWeapon(src)
    end)
    return (ok and weapon) or nil
end

---@note qs-inventory has no confirmed durability export - verify/adjust for your build.
function Bridge.SetDurability(src, slot, durability)
    local ok, res = pcall(function()
        return exports['qs-inventory']:SetDurability(src, slot, durability)
    end)
    return ok and res ~= false
end

---@return number an approximate free-weight figure; a large permissive default if unsupported
function Bridge.GetFreeWeight(src)
    local ok, weight = pcall(function()
        return exports['qs-inventory']:GetFreeWeight(src)
    end)
    return (ok and tonumber(weight)) or math.huge
end
