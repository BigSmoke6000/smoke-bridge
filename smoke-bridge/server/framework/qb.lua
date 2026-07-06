if Config.Framework ~= 'qb' then return end

local QBCore = exports['qb-core']:GetCoreObject()

local function getPlayer(src)
    return QBCore.Functions.GetPlayer(src)
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
    local player = getPlayer(src)
    if player and player.PlayerData and player.PlayerData.citizenid then
        return tostring(player.PlayerData.citizenid)
    end
    return nil
end

function Bridge.GetCharName(src)
    local player = getPlayer(src)
    if player and player.PlayerData and player.PlayerData.charinfo then
        local info = player.PlayerData.charinfo
        return ('%s %s'):format(info.firstname or 'Unknown', info.lastname or '')
    end
    return GetPlayerName(src) or 'Unknown'
end

function Bridge.GetJob(src)
    local player = getPlayer(src)
    local job = player and player.PlayerData and player.PlayerData.job
    if not job then return nil end
    return {
        name = job.name,
        label = job.label,
        grade = job.grade and job.grade.level or 0,
        gradeLabel = job.grade and job.grade.name or '',
        onDuty = job.onduty or false,
    }
end

function Bridge.GetGang(src)
    local player = getPlayer(src)
    local gang = player and player.PlayerData and player.PlayerData.gang
    if not gang then return nil end
    return {
        name = gang.name,
        label = gang.label,
        grade = gang.grade and gang.grade.level or 0,
        gradeLabel = gang.grade and gang.grade.name or '',
    }
end

function Bridge.SetJob(src, job, grade)
    local player = getPlayer(src)
    if not player then return false end
    return player.Functions.SetJob(job, grade) ~= false
end

function Bridge.SetGang(src, gang, grade)
    local player = getPlayer(src)
    if not player then return false end
    return player.Functions.SetGang(gang, grade) ~= false
end

function Bridge.GetMoney(src, account)
    local player = getPlayer(src)
    if not player then return 0 end
    return tonumber(player.PlayerData.money and player.PlayerData.money[account]) or 0
end

function Bridge.RemoveMoney(src, account, amount, reason)
    local player = getPlayer(src)
    if not player then return false end
    return player.Functions.RemoveMoney(account, amount, reason) ~= false
end

function Bridge.AddMoney(src, account, amount, reason)
    local player = getPlayer(src)
    if not player then return false end
    player.Functions.AddMoney(account, amount, reason)
    return true
end

function Bridge.GetSourceByCitizenId(citizenid)
    local player = QBCore.Functions.GetPlayerByCitizenId(citizenid)
    return player and player.PlayerData and player.PlayerData.source or nil
end

function Bridge.GetMetadata(src, key)
    local player = getPlayer(src)
    if not player then return nil end
    local state = Player(src) and Player(src).state
    if state and state[key] ~= nil then return state[key] end
    return player.PlayerData.metadata and player.PlayerData.metadata[key] or nil
end

function Bridge.SetMetadata(src, key, value)
    local player = getPlayer(src)
    if not player then return false end
    player.Functions.SetMetaData(key, value)
    return true
end

function Bridge.AddMetadata(src, key, amount, min, max)
    if not amount or amount == 0 then return false end
    local current = tonumber(Bridge.GetMetadata(src, key)) or 0
    return Bridge.SetMetadata(src, key, clamp(current + amount, min or 0, max or 100))
end

function Bridge.Notify(src, message, notifyType, duration)
    QBCore.Functions.Notify(src, message, notifyType or 'primary', duration)
end

function Bridge.CreateUseableItem(item, cb)
    QBCore.Functions.CreateUseableItem(item, cb)
end

---@param cb fun(source: number, player: table) called once a character finishes loading in
function Bridge.OnPlayerLoaded(cb)
    AddEventHandler('QBCore:Server:PlayerLoaded', function(player)
        cb(player.PlayerData.source, player)
    end)
end

---@return table|nil offline player data, or nil if no such citizen id
function Bridge.GetOfflinePlayer(citizenid)
    return QBCore.Functions.GetOfflinePlayerByCitizenId(citizenid)
end

---@return number|nil src of the online player with this phone number
function Bridge.GetPlayerByPhone(phone)
    local player = QBCore.Functions.GetPlayerByPhone(phone)
    return player and player.PlayerData and player.PlayerData.source or nil
end

---@return boolean whether this item is registered as useable
function Bridge.CanUseItem(item)
    return QBCore.Functions.CanUseItem(item) and true or false
end

---@return table every job definition, keyed by job name
function Bridge.GetJobs()
    return QBCore.Shared.Jobs
end

---@return table every gang definition, keyed by gang name
function Bridge.GetGangs()
    return QBCore.Shared.Gangs
end

---Force-save a player's data to the database.
function Bridge.Save(src)
    local player = getPlayer(src)
    if player and player.Functions and player.Functions.Save then
        player.Functions.Save()
    end
end

---@param permission string|string[]
---@return boolean
function Bridge.HasPermission(src, permission)
    return QBCore.Functions.HasPermission(src, permission)
end

function Bridge.AddPermission(src, permission)
    QBCore.Functions.AddPermission(src, permission)
end

function Bridge.RemovePermission(src, permission)
    QBCore.Functions.RemovePermission(src, permission)
end

---@return boolean
function Bridge.IsWhitelisted(src)
    return QBCore.Functions.IsWhitelisted(src)
end

---@return boolean
---@note not a confirmed real qb-core export - verify/adjust for your build.
function Bridge.IsPlayerBanned(src)
    local ok, banned = pcall(function()
        return QBCore.Functions.IsPlayerBanned(src)
    end)
    return ok and banned and true or false
end
