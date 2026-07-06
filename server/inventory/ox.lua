if Config.Inventory ~= 'ox' then return end

local registeredStashes = {}
local registeredShops = {}

function Bridge.CanCarryItem(src, item, amount)
    local ok, res = pcall(function()
        return exports.ox_inventory:CanCarryItem(src, item, amount)
    end)
    if not ok then return true end
    return res ~= false
end

function Bridge.AddItem(src, item, amount, metadata, slot)
    local ok, res = pcall(function()
        return exports.ox_inventory:AddItem(src, item, amount or 1, metadata, slot)
    end)
    return ok and res ~= false
end

function Bridge.RemoveItem(src, item, amount, slot)
    local ok, res = pcall(function()
        return exports.ox_inventory:RemoveItem(src, item, amount or 1, nil, slot)
    end)
    return ok and res ~= false
end

function Bridge.HasItem(src, item, amount)
    return Bridge.GetItemCount(src, item) >= (amount or 1)
end

function Bridge.GetItemCount(src, item)
    local ok, res = pcall(function()
        return exports.ox_inventory:GetItemCount(src, item)
    end)
    return (ok and tonumber(res)) or 0
end

---@return table|nil the full item table in this slot (name/count/metadata), nil if empty
function Bridge.GetItemBySlot(src, slot)
    local ok, item = pcall(function()
        return exports.ox_inventory:GetSlot(src, slot)
    end)
    return (ok and item) or nil
end

---@return number|nil the first slot number containing item, nil if none
function Bridge.GetFirstSlotByItem(src, item)
    local ok, slotData = pcall(function()
        return exports.ox_inventory:GetSlotWithItem(src, item)
    end)
    if not ok or not slotData then return nil end
    return type(slotData) == 'table' and slotData.slot or slotData
end

---@return table metadata for the item in this slot (empty table if none)
function Bridge.GetItemMetadata(src, slot)
    local item = Bridge.GetItemBySlot(src, slot)
    return (item and item.metadata) or {}
end

---@return boolean success
function Bridge.SetItemMetadata(src, slot, metadata)
    local ok = pcall(function()
        exports.ox_inventory:SetMetadata(src, slot, metadata)
    end)
    return ok
end

---@return table every item the player carries
function Bridge.GetInventory(src)
    local ok, items = pcall(function()
        return exports.ox_inventory:GetInventoryItems(src)
    end)
    return (ok and items) or {}
end

---@param keep string|string[]|nil item name(s) to leave untouched
function Bridge.ClearInventory(src, keep)
    pcall(function()
        exports.ox_inventory:ClearInventory(src, keep)
    end)
end

---Register a stash without opening it (use Bridge.OpenStash to also open one).
function Bridge.RegisterStash(id, slots, weight, owner, groups)
    if registeredStashes[id] then return end
    registeredStashes[id] = true
    pcall(function()
        exports.ox_inventory:RegisterStash(id, id, slots, weight, owner, groups)
    end)
end

---Register (once) and open a stash for a player. ox_inventory has no
---server-side "force open" call, so the actual open happens client-side -
---see client/inventory/ox.lua for the 'smoke-bridge:client:openStash' handler.
function Bridge.OpenStash(src, id, slots, weight, label)
    Bridge.RegisterStash(id, slots, weight)
    TriggerClientEvent('smoke-bridge:client:openStash', src, id)
end

---Register a shop. items is an array of { name, price, count, metadata }.
function Bridge.RegisterShop(name, items, groups)
    if registeredShops[name] then return end
    registeredShops[name] = true
    pcall(function()
        exports.ox_inventory:RegisterShop(name, { name = name, inventory = items, groups = groups })
    end)
end

---ox_inventory has no server-side "force open" call, so this fires the same
---client event as OpenStash - see client/inventory/ox.lua.
function Bridge.OpenShop(src, name)
    TriggerClientEvent('smoke-bridge:client:openShop', src, name)
end

---Take everything away from the player (jail/impound use case).
function Bridge.ConfiscateInventory(src)
    pcall(function()
        exports.ox_inventory:ConfiscateInventory(src)
    end)
end

---Give back whatever was taken by ConfiscateInventory.
function Bridge.ReturnInventory(src)
    pcall(function()
        exports.ox_inventory:ReturnInventory(src)
    end)
end

---@return table|nil currently-held weapon slot data, or nil if unarmed
function Bridge.GetCurrentWeapon(src)
    local ok, weapon = pcall(function()
        return exports.ox_inventory:GetCurrentWeapon(src)
    end)
    return (ok and weapon) or nil
end

---@return boolean success
function Bridge.SetDurability(src, slot, durability)
    local ok = pcall(function()
        exports.ox_inventory:SetDurability(src, slot, durability)
    end)
    return ok
end

---@return number an approximate free-weight figure; a large permissive default if unsupported
---@note ox_inventory tracks weight on the inventory object rather than exposing a single
---"free weight" export - this is a best-effort approximation, verify for your build.
function Bridge.GetFreeWeight(src)
    local ok, inv = pcall(function()
        return exports.ox_inventory:GetInventory(src)
    end)
    if not ok or not inv or not inv.maxWeight then return math.huge end
    return inv.maxWeight - (inv.weight or 0)
end
