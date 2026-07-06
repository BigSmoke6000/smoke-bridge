if Config.Framework ~= 'qbx' then return end

---@return string|nil local player's citizen/character identifier
function Bridge.GetCitizenId()
    local data = exports.qbx_core:GetPlayerData()
    return data and data.citizenid or nil
end

---@return table|nil { name, label, grade, gradeLabel, onDuty }
function Bridge.GetJob()
    local data = exports.qbx_core:GetPlayerData()
    local job = data and data.job
    if not job then return nil end
    return {
        name = job.name,
        label = job.label,
        grade = job.grade and job.grade.level or 0,
        gradeLabel = job.grade and job.grade.name or '',
        onDuty = job.onduty or false,
    }
end

---@param message string
---@param notifyType string 'success' | 'error' | 'inform' etc.
function Bridge.Notify(message, notifyType, duration)
    exports.qbx_core:Notify(message, notifyType or 'inform', duration)
end

---@param cb fun() called when the local character finishes loading
function Bridge.OnPlayerLoaded(cb)
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', cb)
end

---@return table every job definition, keyed by job name
function Bridge.GetJobs()
    return exports.qbx_core:GetJobs()
end

---@return table every gang definition, keyed by gang name
function Bridge.GetGangs()
    return exports.qbx_core:GetGangs()
end
