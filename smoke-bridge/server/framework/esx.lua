if Config.Framework ~= 'esx' then return end

local ESX = exports['es_extended']:getSharedObject()

-- ESX account names differ: 'cash' -> 'money'
local function account(name)
    return name == 'cash' and 'money' or name
end

local function getPlayer(src)
    return ESX.GetPlayerFromId(src)
end

local function clamp(value, min, max)
    value = tonumber(value) or 0
    if value < min then return min end
    if value > max then return max end
    return value
end

function Bridge.GetPlayer(src)
    return getPlayer(src)
end

function Bridge.GetCitizenId(src)
    local xPlayer = getPlayer(src)
    return xPlayer and tostring(xPlayer.identifier) or nil
end

function Bridge.GetCharName(src)
    local xPlayer = getPlayer(src)
    if xPlayer and xPlayer.getName then
        return xPlayer.getName()
    end
    return GetPlayerName(src) or 'Unknown'
end

---@return table|nil { name, label, grade, gradeLabel, onDuty } - ESX has no duty concept, onDuty is always true
function Bridge.GetJob(src)
    local xPlayer = getPlayer(src)
    local job = xPlayer and xPlayer.job
    if not job then return nil end
    return {
        name = job.name,
        label = job.label,
        grade = job.grade,
        gradeLabel = job.grade_label or job.grade_name or '',
        onDuty = true,
    }
end

---@return nil ESX has no built-in gang system
function Bridge.GetGang(_)
    return nil
end

---@return boolean success
function Bridge.SetJob(src, job, grade)
    local xPlayer = getPlayer(src)
    if not xPlayer then return false end
    xPlayer.setJob(job, grade)
    return true
end

---@return boolean ESX has no built-in gang system, always false
function Bridge.SetGang(_, _, _)
    return false
end

function Bridge.GetMoney(src, accountName)
    local xPlayer = getPlayer(src)
    if not xPlayer then return 0 end
    local acc = xPlayer.getAccount(account(accountName))
    return acc and tonumber(acc.money) or 0
end

function Bridge.RemoveMoney(src, accountName, amount, reason)
    local xPlayer = getPlayer(src)
    if not xPlayer then return false end
    if Bridge.GetMoney(src, accountName) < amount then return false end
    xPlayer.removeAccountMoney(account(accountName), amount, reason)
    return true
end

function Bridge.AddMoney(src, accountName, amount, reason)
    local xPlayer = getPlayer(src)
    if not xPlayer then return false end
    xPlayer.addAccountMoney(account(accountName), amount, reason)
    return true
end

function Bridge.GetSourceByCitizenId(citizenid)
    local xPlayer = ESX.GetPlayerFromIdentifier(citizenid)
    return xPlayer and xPlayer.source or nil
end

-- ESX has no persistent metadata table like qb/qbx. getMeta/setMeta exist on
-- newer esx_legacy builds; older builds only have the in-session get/set.
function Bridge.GetMetadata(src, key)
    local xPlayer = getPlayer(src)
    if not xPlayer then return nil end
    if xPlayer.getMeta then
        local ok, val = pcall(xPlayer.getMeta, key)
        if ok then return val end
    end
    return xPlayer.get(key)
end

function Bridge.SetMetadata(src, key, value)
    local xPlayer = getPlayer(src)
    if not xPlayer then return false end
    if xPlayer.setMeta then
        local ok = pcall(xPlayer.setMeta, key, value)
        if ok then return true end
    end
    xPlayer.set(key, value)
    return true
end

function Bridge.AddMetadata(src, key, amount, min, max)
    if not amount or amount == 0 then return false end
    local current = tonumber(Bridge.GetMetadata(src, key)) or 0
    return Bridge.SetMetadata(src, key, clamp(current + amount, min or 0, max or 100))
end

function Bridge.Notify(src, message, notifyType, duration)
    TriggerClientEvent('esx:showNotification', src, message, notifyType, duration)
end

local usableItems = {}

function Bridge.CreateUseableItem(item, cb)
    usableItems[item] = true
    ESX.RegisterUsableItem(item, cb)
end

---@param cb fun(source: number, player: table) called once a character finishes loading in
function Bridge.OnPlayerLoaded(cb)
    AddEventHandler('esx:playerLoaded', function(source, xPlayer)
        cb(source, xPlayer)
    end)
end

---@return table|nil offline player data, or nil if no such identifier
---@note ESX has no built-in offline-player lookup - verify/adjust for your build.
function Bridge.GetOfflinePlayer(citizenid)
    local ok, player = pcall(function()
        return ESX.GetOfflinePlayer(citizenid)
    end)
    return (ok and player) or nil
end

---@return number|nil ESX has no built-in phone-number identity - always nil.
function Bridge.GetPlayerByPhone(_)
    return nil
end

---@return boolean whether this item was registered via Bridge.CreateUseableItem
function Bridge.CanUseItem(item)
    return usableItems[item] == true
end

---@return table every job definition, keyed by job name
function Bridge.GetJobs()
    local ok, jobs = pcall(function() return ESX.Jobs end)
    return (ok and jobs) or {}
end

---@return table ESX has no built-in gang system - always empty.
function Bridge.GetGangs()
    return {}
end

---Force-save a player's data to the database.
function Bridge.Save(src)
    local xPlayer = getPlayer(src)
    if xPlayer and xPlayer.save then xPlayer.save() end
end

---@param permission string ESX has no runtime permission-grant system - this checks server.cfg ACE permissions.
---@return boolean
function Bridge.HasPermission(src, permission)
    return IsPlayerAceAllowed(src, permission)
end

---@note ESX manages permissions via ACE in server.cfg, not runtime grants - this is a no-op.
function Bridge.AddPermission(_, _) end

---@note ESX manages permissions via ACE in server.cfg, not runtime grants - this is a no-op.
function Bridge.RemovePermission(_, _) end

---@return boolean
---@note ESX has no built-in whitelist system - always true (permissive).
function Bridge.IsWhitelisted(_)
    return true
end

---@return boolean
---@note ESX has no built-in ban system - always false (permissive).
function Bridge.IsPlayerBanned(_)
    return false
end
