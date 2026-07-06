if Config.Framework ~= 'qb' then return end

local QBCore = exports['qb-core']:GetCoreObject()

function Bridge.GetCitizenId()
    local data = QBCore.Functions.GetPlayerData()
    return data and data.citizenid or nil
end

function Bridge.GetJob()
    local data = QBCore.Functions.GetPlayerData()
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

function Bridge.Notify(message, notifyType, duration)
    QBCore.Functions.Notify(message, notifyType or 'primary', duration)
end

function Bridge.OnPlayerLoaded(cb)
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', cb)
end

---@return table every job definition, keyed by job name
function Bridge.GetJobs()
    return QBCore.Shared.Jobs
end

---@return table every gang definition, keyed by gang name
function Bridge.GetGangs()
    return QBCore.Shared.Gangs
end
