if Config.Inventory ~= 'ox' then return end

local itemList = nil

function Bridge.GetItemLabel(name)
    if not itemList then
        local ok, items = pcall(function()
            return exports.ox_inventory:Items()
        end)
        itemList = ok and items or {}
    end
    local item = itemList[name]
    return item and item.label or name
end

---@return number total amount of item the local player carries
function Bridge.GetItemCount(item)
    local ok, res = pcall(function()
        return exports.ox_inventory:GetItemCount(item)
    end)
    return (ok and tonumber(res)) or 0
end

---@return boolean whether the local player carries at least `amount` of item
function Bridge.HasItem(item, amount)
    return Bridge.GetItemCount(item) >= (amount or 1)
end

---@return table every item the local player carries
function Bridge.GetInventory()
    local ok, items = pcall(function()
        return exports.ox_inventory:GetPlayerItems()
    end)
    return (ok and items) or {}
end

---@return table matching item slots (empty table if none)
function Bridge.Search(item, metadata)
    local ok, res = pcall(function()
        return exports.ox_inventory:Search('slots', item, metadata)
    end)
    return (ok and res) or {}
end

---Force-close the local player's inventory UI.
function Bridge.CloseInventory()
    pcall(function()
        exports.ox_inventory:closeInventory()
    end)
end

---Disable inventory interaction (e.g. while a search/loot animation plays).
function Bridge.LockInventory()
    LocalPlayer.state:set('invBusy', true, false)
end

function Bridge.UnlockInventory()
    LocalPlayer.state:set('invBusy', false, false)
end

-- Server-side Bridge.OpenStash/OpenShop (server/inventory/ox.lua) have no direct
-- way to force-open from the server, so they fire these events and we forward
-- them to the client-side export instead.
RegisterNetEvent('smoke-bridge:client:openStash', function(id)
    exports.ox_inventory:openInventory('stash', id)
end)

RegisterNetEvent('smoke-bridge:client:openShop', function(name)
    exports.ox_inventory:openInventory('shop', name)
end)
