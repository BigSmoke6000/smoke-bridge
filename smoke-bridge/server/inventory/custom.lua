if Config.Inventory ~= 'custom' then return end

--------------------------------------------------------------------------
-- CUSTOM INVENTORY BRIDGE (server)
--
-- Set Config.Inventory = 'custom' in your script's config.lua, then fill
-- in the functions below with your inventory's exports. That's the full
-- surface any smoke-* script will ask an inventory for.
--
-- Rules the rest of a script relies on:
--   * CanCarryItem must return TRUE when the player has room and FALSE
--     when they don't. If your inventory has no such check, return true
--     and make sure AddItem returns false on failure instead - loot that
--     can't be given should stay recoverable rather than vanish.
--   * AddItem/RemoveItem must return TRUE only if the change actually
--     landed. Returning true on a silent failure loses items forever.
--------------------------------------------------------------------------

---Does the player have space/weight for this item?
---@param src number player server id
---@param item string item name
---@param amount number stack size to give
---@return boolean
function Bridge.CanCarryItem(src, item, amount)
    -- EXAMPLE (replace 'my-inventory' and the export with your own):
    -- local ok, res = pcall(function()
    --     return exports['my-inventory']:CanCarryItem(src, item, amount)
    -- end)
    -- if not ok then return true end
    -- return res ~= false

    return true
end

---Give the player an item.
---@param src number player server id
---@param item string item name
---@param amount number stack size
---@param metadata table|nil optional item metadata
---@param slot number|nil optional target slot
---@return boolean success
function Bridge.AddItem(src, item, amount, metadata, slot)
    -- EXAMPLE (replace with your own export):
    -- local ok, res = pcall(function()
    --     return exports['my-inventory']:AddItem(src, item, amount, slot, metadata)
    -- end)
    -- return ok and res ~= false

    print(('[smoke-bridge] server/inventory/custom.lua is not implemented - %dx %s for player %s was NOT given'):format(amount or 1, item, src))
    return false
end

---Take an item away from the player.
---@param src number player server id
---@param item string item name
---@param amount number stack size
---@param slot number|nil optional source slot
---@return boolean success
function Bridge.RemoveItem(src, item, amount, slot)
    -- EXAMPLE:
    -- local ok, res = pcall(function()
    --     return exports['my-inventory']:RemoveItem(src, item, amount, slot)
    -- end)
    -- return ok and res ~= false

    print(('[smoke-bridge] server/inventory/custom.lua is not implemented - %dx %s for player %s was NOT removed'):format(amount or 1, item, src))
    return false
end

---Does the player carry at least `amount` of item?
---@return boolean
function Bridge.HasItem(src, item, amount)
    return Bridge.GetItemCount(src, item) >= (amount or 1)
end

---How many of item does the player carry in total?
---@return number
function Bridge.GetItemCount(src, item)
    -- EXAMPLE:
    -- local ok, res = pcall(function()
    --     return exports['my-inventory']:GetItemCount(src, item)
    -- end)
    -- return (ok and tonumber(res)) or 0

    return 0
end

---Get an item's metadata by slot.
---@param src number
---@param slot number
---@return table metadata (empty table if none)
function Bridge.GetItemMetadata(src, slot)
    -- EXAMPLE:
    -- local ok, item = pcall(function()
    --     return exports['my-inventory']:GetItemBySlot(src, slot)
    -- end)
    -- return (ok and item and item.metadata) or {}

    return {}
end

---Set an item's metadata by slot.
---@param src number
---@param slot number
---@param metadata table
---@return boolean success
function Bridge.SetItemMetadata(src, slot, metadata)
    -- EXAMPLE:
    -- local ok, res = pcall(function()
    --     return exports['my-inventory']:SetItemMetadata(src, slot, metadata)
    -- end)
    -- return ok and res ~= false

    return false
end

---Get the full item table in a slot (name/amount/metadata).
---@param src number
---@param slot number
---@return table|nil
function Bridge.GetItemBySlot(src, slot)
    -- EXAMPLE:
    -- local ok, item = pcall(function()
    --     return exports['my-inventory']:GetItemBySlot(src, slot)
    -- end)
    -- return (ok and item) or nil

    return nil
end

---Find the first slot containing item.
---@param src number
---@param item string
---@return number|nil
function Bridge.GetFirstSlotByItem(src, item)
    -- EXAMPLE:
    -- local ok, slot = pcall(function()
    --     return exports['my-inventory']:GetFirstSlotByItem(src, item)
    -- end)
    -- return (ok and slot) or nil

    return nil
end

---Get every item the player carries.
---@param src number
---@return table
function Bridge.GetInventory(src)
    -- EXAMPLE:
    -- local ok, items = pcall(function()
    --     return exports['my-inventory']:GetInventory(src)
    -- end)
    -- return (ok and items) or {}

    return {}
end

---Remove every item from the player (except any names in `keep`).
---@param src number
---@param keep string|string[]|nil
function Bridge.ClearInventory(src, keep)
    -- EXAMPLE:
    -- exports['my-inventory']:ClearInventory(src, keep)
end

---Register a stash without opening it (use Bridge.OpenStash to also open one).
---@param id string
---@param slots number
---@param weight number
---@param owner string|boolean|nil
---@param groups table|nil
function Bridge.RegisterStash(id, slots, weight, owner, groups)
    -- EXAMPLE:
    -- exports['my-inventory']:RegisterStash(id, id, slots, weight, owner, groups)
end

---Open a stash/shared inventory for a player.
---@param src number
---@param id string unique stash identifier
---@param slots number
---@param weight number max weight
---@param label string|nil
function Bridge.OpenStash(src, id, slots, weight, label)
    -- EXAMPLE:
    -- Bridge.RegisterStash(id, slots, weight)
    -- exports['my-inventory']:OpenInventory(src, id)

    print(('[smoke-bridge] server/inventory/custom.lua is not implemented - stash %s was NOT opened for player %s'):format(id, src))
end

---Register a shop. items is an array of { name, price, amount, metadata }.
---@param name string
---@param items table
---@param groups table|nil
function Bridge.RegisterShop(name, items, groups)
    -- EXAMPLE:
    -- exports['my-inventory']:RegisterShop(name, { name = name, inventory = items, groups = groups })
end

---Open a registered shop for a player.
---@param src number
---@param name string
function Bridge.OpenShop(src, name)
    -- EXAMPLE:
    -- exports['my-inventory']:OpenShop(src, name)

    print(('[smoke-bridge] server/inventory/custom.lua is not implemented - shop %s was NOT opened for player %s'):format(name, src))
end

---Take everything away from the player (jail/impound use case).
---@param src number
function Bridge.ConfiscateInventory(src)
    -- EXAMPLE:
    -- Bridge.SetMetadata(src, 'smokeBridgeConfiscated', Bridge.GetInventory(src))
    -- Bridge.ClearInventory(src)
end

---Give back whatever was taken by ConfiscateInventory.
---@param src number
function Bridge.ReturnInventory(src)
    -- EXAMPLE:
    -- local confiscated = Bridge.GetMetadata(src, 'smokeBridgeConfiscated')
    -- if not confiscated then return end
    -- for _, item in pairs(confiscated) do
    --     Bridge.AddItem(src, item.name, item.amount, item.metadata, item.slot)
    -- end
    -- Bridge.SetMetadata(src, 'smokeBridgeConfiscated', nil)
end

---Get the item currently held/equipped as a weapon, if any.
---@param src number
---@return table|nil
function Bridge.GetCurrentWeapon(src)
    -- EXAMPLE:
    -- local ok, weapon = pcall(function()
    --     return exports['my-inventory']:GetCurrentWeapon(src)
    -- end)
    -- return (ok and weapon) or nil

    return nil
end

---Set a weapon/tool's durability.
---@param src number
---@param slot number
---@param durability number
---@return boolean success
function Bridge.SetDurability(src, slot, durability)
    -- EXAMPLE:
    -- local ok = pcall(function()
    --     exports['my-inventory']:SetDurability(src, slot, durability)
    -- end)
    -- return ok

    return false
end

---How much more weight can the player carry?
---@param src number
---@return number
function Bridge.GetFreeWeight(src)
    -- EXAMPLE:
    -- local ok, weight = pcall(function()
    --     return exports['my-inventory']:GetFreeWeight(src)
    -- end)
    -- return (ok and tonumber(weight)) or math.huge

    return math.huge
end
