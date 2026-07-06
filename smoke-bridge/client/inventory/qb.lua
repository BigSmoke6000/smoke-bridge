if Config.Inventory ~= 'qb' then return end

local QBCore = exports['qb-core']:GetCoreObject()
local itemList = nil

function Bridge.GetItemLabel(name)
    if not itemList then
        local ok, items = pcall(function()
            return QBCore.Shared.Items
        end)
        itemList = ok and items or {}
    end
    local item = itemList[name]
    return item and item.label or name
end

---@return number total amount of item the local player carries
function Bridge.GetItemCount(item)
    local playerData = QBCore.Functions.GetPlayerData()
    local count = 0
    for _, v in pairs(playerData.items or {}) do
        if v.name == item then
            count = count + (tonumber(v.amount) or 0)
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
    return QBCore.Functions.GetPlayerData().items or {}
end

---@return table matching item slots (empty table if none)
---@note qb-inventory has no confirmed native client Search export - filters the local item list instead.
function Bridge.Search(item, metadata)
    local results = {}
    for _, v in pairs(Bridge.GetInventory()) do
        if v.name == item then
            results[#results + 1] = v
        end
    end
    return results
end

---Force-close the local player's inventory UI.
---@note qb-inventory forks differ on the exact close command - adjust if yours doesn't match.
function Bridge.CloseInventory()
    ExecuteCommand('closeinv')
end

---Disable inventory interaction (e.g. while a search/loot animation plays).
function Bridge.LockInventory()
    LocalPlayer.state:set('inv_busy', true, true)
end

function Bridge.UnlockInventory()
    LocalPlayer.state:set('inv_busy', false, true)
end
