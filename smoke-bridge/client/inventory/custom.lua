if Config.Inventory ~= 'custom' then return end

--------------------------------------------------------------------------
-- CUSTOM INVENTORY BRIDGE (client)
--
-- Only one function is needed client-side: turning an item name into a
-- pretty display label. If your inventory has no item-list export, just
-- leave this as-is - raw item names will be shown instead (everything
-- still works).
--
-- If your inventory also has no server-side "force open stash/shop" call (like
-- ox_inventory), register 'smoke-bridge:client:openStash'/'openShop' net events
-- here and forward them to your inventory's client-side open call - see
-- client/inventory/ox.lua for a working example.
--------------------------------------------------------------------------

local itemList = nil

---@param name string item name
---@return string display label
function Bridge.GetItemLabel(name)
    -- EXAMPLE (replace with your inventory's item-list export):
    -- if not itemList then
    --     local ok, items = pcall(function()
    --         return exports['my-inventory']:GetItemList()
    --     end)
    --     itemList = ok and items or {}
    -- end
    -- local item = itemList[name]
    -- return item and (item.label or item.name) or name

    return name
end

---@return number total amount of item the local player carries
function Bridge.GetItemCount(item)
    -- EXAMPLE:
    -- local ok, res = pcall(function()
    --     return exports['my-inventory']:GetItemCount(item)
    -- end)
    -- return (ok and tonumber(res)) or 0

    return 0
end

---@return boolean whether the local player carries at least `amount` of item
function Bridge.HasItem(item, amount)
    return Bridge.GetItemCount(item) >= (amount or 1)
end

---@return table every item the local player carries
function Bridge.GetInventory()
    -- EXAMPLE:
    -- local ok, items = pcall(function()
    --     return exports['my-inventory']:GetPlayerItems()
    -- end)
    -- return (ok and items) or {}

    return {}
end

---@return table matching item slots (empty table if none)
function Bridge.Search(item, metadata)
    -- EXAMPLE:
    -- local ok, res = pcall(function()
    --     return exports['my-inventory']:Search('slots', item, metadata)
    -- end)
    -- return (ok and res) or {}

    return {}
end

---Force-close the local player's inventory UI.
function Bridge.CloseInventory()
    -- EXAMPLE:
    -- exports['my-inventory']:closeInventory()
end

---Disable inventory interaction (e.g. while a search/loot animation plays).
function Bridge.LockInventory()
    -- EXAMPLE:
    -- LocalPlayer.state:set('invBusy', true, false)
end

function Bridge.UnlockInventory()
    -- EXAMPLE:
    -- LocalPlayer.state:set('invBusy', false, false)
end
