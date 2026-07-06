if Config.Framework ~= 'qbx' then return end

local function getPlayer(src)
    return exports.qbx_core:GetPlayer(src)
end

local function clamp(value, min, max)
    value = tonumber(value) or 0
    if value < min then return min end
    if value > max then return max end
    return value
end

---@return table|nil the framework-native player object (escape hatch for advanced use)
function Bridge.GetPlayer(src)
    return getPlayer(src)
end

---@return string|nil citizen/character identifier
function Bridge.GetCitizenId(src)
    local player = getPlayer(src)
    if player and player.PlayerData and player.PlayerData.citizenid then
        return tostring(player.PlayerData.citizenid)
    end
    return nil
end

---@return string character display name
function Bridge.GetCharName(src)
    local player = getPlayer(src)
    if player and player.PlayerData and player.PlayerData.charinfo then
        local info = player.PlayerData.charinfo
        return ('%s %s'):format(info.firstname or 'Unknown', info.lastname or '')
    end
    return GetPlayerName(src) or 'Unknown'
end

---@return table|nil { name, label, grade, gradeLabel, onDuty }
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

---@return table|nil { name, label, grade, gradeLabel }
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

---@return boolean success
function Bridge.SetJob(src, job, grade)
    local player = getPlayer(src)
    if not player then return false end
    return player.Functions.SetJob(job, grade) ~= false
end

---@return boolean success
function Bridge.SetGang(src, gang, grade)
    local player = getPlayer(src)
    if not player then return false end
    return player.Functions.SetGang(gang, grade) ~= false
end

---@param account string 'cash' | 'bank'
---@return number balance
function Bridge.GetMoney(src, account)
    local player = getPlayer(src)
    if not player then return 0 end
    return tonumber(player.PlayerData.money and player.PlayerData.money[account]) or 0
end

---@return boolean success
function Bridge.RemoveMoney(src, account, amount, reason)
    local player = getPlayer(src)
    if not player then return false end

    if player.Functions and player.Functions.RemoveMoney then
        return player.Functions.RemoveMoney(account, amount, reason) ~= false
    end

    -- Fallback for qbx_core export-based installs.
    local ok, res = pcall(function()
        return exports.qbx_core:RemoveMoney(src, account, amount, reason)
    end)
    return ok and res ~= false
end

---@return boolean success
function Bridge.AddMoney(src, account, amount, reason)
    local player = getPlayer(src)
    if not player then return false end

    if player.Functions and player.Functions.AddMoney then
        player.Functions.AddMoney(account, amount, reason)
        return true
    end

    local ok = pcall(function()
        exports.qbx_core:AddMoney(src, account, amount, reason)
    end)
    return ok
end

---@return number|nil src of the online player with this citizen id
function Bridge.GetSourceByCitizenId(citizenid)
    local player = exports.qbx_core:GetPlayerByCitizenId(citizenid)
    return player and player.PlayerData and player.PlayerData.source or nil
end

---@return any current value of a metadata key (nil if unset)
function Bridge.GetMetadata(src, key)
    local player = getPlayer(src)
    if not player then return nil end
    local state = Player(src) and Player(src).state
    if state and state[key] ~= nil then return state[key] end
    return player.PlayerData.metadata and player.PlayerData.metadata[key] or nil
end

---@return boolean success
function Bridge.SetMetadata(src, key, value)
    local player = getPlayer(src)
    if not player then return false end
    player.Functions.SetMetaData(key, value)
    return true
end

---Increment a numeric metadata key, clamped between min/max (defaults 0-100).
---@return boolean success
function Bridge.AddMetadata(src, key, amount, min, max)
    if not amount or amount == 0 then return false end
    local current = tonumber(Bridge.GetMetadata(src, key)) or 0
    return Bridge.SetMetadata(src, key, clamp(current + amount, min or 0, max or 100))
end

---@param notifyType string 'success' | 'error' | 'inform' etc.
function Bridge.Notify(src, message, notifyType, duration)
    exports.qbx_core:Notify(src, message, notifyType or 'inform', duration)
end

---@param cb fun(source: number, item: table) called when a player uses this item
function Bridge.CreateUseableItem(item, cb)
    exports.qbx_core:CreateUseableItem(item, cb)
end

---@param cb fun(source: number, player: table) called once a character finishes loading in
function Bridge.OnPlayerLoaded(cb)
    AddEventHandler('QBCore:Server:PlayerLoaded', function(player)
        cb(player.PlayerData.source, player)
    end)
end

---@return table|nil offline player data, or nil if no such citizen id
function Bridge.GetOfflinePlayer(citizenid)
    return exports.qbx_core:GetOfflinePlayer(citizenid)
end

---@return number|nil src of the online player with this phone number
function Bridge.GetPlayerByPhone(phone)
    local player = exports.qbx_core:GetPlayerByPhone(phone)
    return player and player.PlayerData and player.PlayerData.source or nil
end

---@return boolean whether this item is registered as useable
function Bridge.CanUseItem(item)
    return exports.qbx_core:CanUseItem(item) and true or false
end

---@return table every job definition, keyed by job name
function Bridge.GetJobs()
    return exports.qbx_core:GetJobs()
end

---@return table every gang definition, keyed by gang name
function Bridge.GetGangs()
    return exports.qbx_core:GetGangs()
end

---Force-save a player's data to the database.
function Bridge.Save(src)
    exports.qbx_core:Save(src)
end

---@param permission string|string[]
---@return boolean
function Bridge.HasPermission(src, permission)
    return exports.qbx_core:HasPermission(src, permission)
end

function Bridge.AddPermission(src, permission)
    exports.qbx_core:AddPermission(src, permission)
end

function Bridge.RemovePermission(src, permission)
    exports.qbx_core:RemovePermission(src, permission)
end

---@return boolean
function Bridge.IsWhitelisted(src)
    return exports.qbx_core:IsWhitelisted(src)
end

---@return boolean
function Bridge.IsPlayerBanned(src)
    local banned = exports.qbx_core:IsPlayerBanned(src)
    return banned and true or false
end
