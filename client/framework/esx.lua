if Config.Framework ~= 'esx' then return end

local ESX = exports['es_extended']:getSharedObject()

function Bridge.GetCitizenId()
    local data = ESX.GetPlayerData()
    return data and data.identifier or nil
end

---@return table|nil { name, label, grade, gradeLabel, onDuty } - ESX has no duty concept, onDuty is always true
function Bridge.GetJob()
    local data = ESX.GetPlayerData()
    local job = data and data.job
    if not job then return nil end
    return {
        name = job.name,
        label = job.label,
        grade = job.grade,
        gradeLabel = job.grade_label or job.grade_name or '',
        onDuty = true,
    }
end

function Bridge.Notify(message, notifyType, duration)
    ESX.ShowNotification(message, notifyType, duration)
end

function Bridge.OnPlayerLoaded(cb)
    RegisterNetEvent('esx:playerLoaded', cb)
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
