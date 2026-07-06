if Config.Inventory ~= 'qs' then return end

local itemList = nil

---@return string display label for an item (falls back to the raw name)
function Bridge.GetItemLabel(name)
    if not itemList then
        local ok, items = pcall(function()
            return exports['qs-inventory']:GetItemList()
        end)
        itemList = ok and items or {}
    end
    local item = itemList[name]
    return item and (item.label or item.name) or name
end

---@return number total amount of item the local player carries
function Bridge.GetItemCount(item)
    local ok, items = pcall(function()
        return exports['qs-inventory']:GetPlayerItems()
    end)
    if not ok or not items then return 0 end

    local count = 0
    for _, v in pairs(items) do
        if v.name == item then
            count = count + (tonumber(v.amount or v.count) or 0)
        end
    end
    return count
end

---@return boolean whether the local player carries at least `amount` of item
function Bridge.HasItem(item, amount)
    return Bridge.GetItemCount(item) >= (amount or 1)
end

---@return table every item the local player carries
function Bridge.GetInventory()
    local ok, items = pcall(function()
        return exports['qs-inventory']:GetPlayerItems()
    end)
    return (ok and items) or {}
end

---@return table matching item slots (empty table if none/unsupported)
function Bridge.Search(item, metadata)
    local ok, res = pcall(function()
        return exports['qs-inventory']:Search('slots', item, metadata)
    end)
    return (ok and res) or {}
end

---Force-close the local player's inventory UI.
function Bridge.CloseInventory()
    local ok = pcall(function()
        exports['qs-inventory']:CloseInventory()
    end)
    if not ok then ExecuteCommand('closeinv') end
end

---Disable inventory interaction (e.g. while a search/loot animation plays).
function Bridge.LockInventory()
    local ok = pcall(function()
        exports['qs-inventory']:SetInventoryActive(false)
    end)
    if not ok then LocalPlayer.state:set('inv_busy', true, true) end
end

function Bridge.UnlockInventory()
    local ok = pcall(function()
        exports['qs-inventory']:SetInventoryActive(true)
    end)
    if not ok then LocalPlayer.state:set('inv_busy', false, true) end
end
