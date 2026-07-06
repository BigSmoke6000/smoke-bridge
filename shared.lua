-- Bridge table shared by both sides. The framework/inventory/target/menu
-- files in server/ and client/ attach their implementations to this based on
-- Config.Framework / Config.Inventory / Config.Target / Config.Menu - set
-- once in config.lua for every script that includes this bridge, not
-- per-script. Consuming scripts only ever call Bridge.* - swapping any of
-- them means flipping the config values in this resource's config.lua (or
-- dropping in a new bridge file).
Bridge = {}

--------------------------------------------------------------------------
-- AUTO DETECTION
-- When Config.Framework / Config.Inventory / Config.Target is 'auto', we
-- look at which resources are actually running and resolve the value before
-- the adapter files load (they guard on the resolved value). 'custom' (and
-- Config.Target's 'drawtext') are never auto-picked - set them explicitly.
--------------------------------------------------------------------------

local frameworkCandidates = {
    { id = 'qbx', resource = 'qbx_core' },
    { id = 'qb',  resource = 'qb-core' },
    { id = 'esx', resource = 'es_extended' }
}

local inventoryCandidates = {
    { id = 'qs', resource = 'qs-inventory' },
    { id = 'ox', resource = 'ox_inventory' },
    { id = 'qb', resource = 'qb-inventory' }
}

local targetCandidates = {
    { id = 'ox', resource = 'ox_target' },
    { id = 'qb', resource = 'qb-target' }
}

local function detect(candidates)
    for _, candidate in ipairs(candidates) do
        local state = GetResourceState(candidate.resource)
        if state == 'started' or state == 'starting' then
            return candidate.id, candidate.resource
        end
    end
    return nil, nil
end

local isServer = IsDuplicityVersion()
-- Included via '@smoke-bridge/shared.lua', so this resolves to whichever
-- script pulled the bridge in - makes the log lines below identify the
-- actual consumer instead of always saying 'smoke-bridge'.
local resourceName = GetCurrentResourceName()

if (Config.Framework or 'auto') == 'auto' then
    local id, resource = detect(frameworkCandidates)
    if id then
        Config.Framework = id
        if isServer then
            print(('[%s] bridge auto-detected framework: %s (%s)'):format(resourceName, id, resource))
        end
    else
        Config.Framework = 'qbx' -- last resort so the guards still resolve to something
        if isServer then
            print(('[%s] ^1bridge could not auto-detect a framework (qbx_core / qb-core / es_extended not running) - defaulting to qbx. Set Config.Framework explicitly.^0'):format(resourceName))
        end
    end
end

if (Config.Inventory or 'auto') == 'auto' then
    local id, resource = detect(inventoryCandidates)
    if id then
        Config.Inventory = id
        if isServer then
            print(('[%s] bridge auto-detected inventory: %s (%s)'):format(resourceName, id, resource))
        end
    else
        Config.Inventory = 'ox' -- last resort - ox_inventory is free and far more commonly installed than paid qs-inventory
        if isServer then
            print(('[%s] ^1bridge could not auto-detect an inventory (qs-inventory / ox_inventory / qb-inventory not running) - defaulting to ox. Set Config.Inventory explicitly.^0'):format(resourceName))
        end
    end
end

-- 'drawtext' is never auto-picked (same as 'custom') - it's an explicit opt-out
-- of target resources entirely, not something to fall into by accident.
if (Config.Target or 'auto') == 'auto' then
    local id, resource = detect(targetCandidates)
    if id then
        Config.Target = id
        if isServer then
            print(('[%s] bridge auto-detected target: %s (%s)'):format(resourceName, id, resource))
        end
    else
        Config.Target = 'ox' -- last resort so the guards still resolve to something
        if isServer then
            print(('[%s] ^1bridge could not auto-detect a target resource (ox_target / qb-target not running) - defaulting to ox. Set Config.Target explicitly (or to \'drawtext\' if you don\'t want a target resource at all).^0'):format(resourceName))
        end
    end
end

-- ox_lib is already a hard dependency of this bridge ('@ox_lib/init.lua' in
-- every consumer's fxmanifest), so unlike Framework/Inventory/Target there's
-- nothing to detect here - 'auto' always just resolves to 'ox'.
if (Config.Menu or 'auto') == 'auto' then
    Config.Menu = 'ox'
end

--------------------------------------------------------------------------
-- MODULE LOADER
-- '@smoke-bridge/some/file.lua' cross-resource includes only ever pull in
-- ONE named file each - there's no cross-resource equivalent of the
-- '*.lua' globs local client_scripts/server_scripts support, so listing
-- every framework/inventory/target/menu file in every consumer's own
-- fxmanifest doesn't work (FXServer just fails to load each glob entry
-- silently). Instead, this file is the ONLY thing a consumer needs to
-- include - once Config.Framework/Inventory/Target/Menu are resolved above,
-- it reads the matching adapter file's raw source directly out of this
-- resource with LoadResourceFile (which, unlike '@' includes, works by
-- resource name + path and doesn't care what that resource's own manifest
-- declares) and runs it with load() in this same script's environment, so
-- the Bridge.* functions it defines land on the exact same global `Bridge`
-- table every other bridge file already uses.
--------------------------------------------------------------------------

local BRIDGE_RESOURCE = 'smoke-bridge'

local function loadModule(path)
    local source = LoadResourceFile(BRIDGE_RESOURCE, path)
    if not source then
        if isServer then
            print(('[%s] ^1smoke-bridge module missing: %s (expected at resources/%s/%s)^0'):format(resourceName, path, BRIDGE_RESOURCE, path))
        end
        return
    end

    local chunk, err = load(source, ('@@%s/%s'):format(BRIDGE_RESOURCE, path))
    if not chunk then
        error(('[smoke-bridge] failed to compile %s: %s'):format(path, err))
    end

    chunk()
end

if isServer then
    loadModule(('server/framework/%s.lua'):format(Config.Framework))
    loadModule(('server/inventory/%s.lua'):format(Config.Inventory))
else
    loadModule(('client/framework/%s.lua'):format(Config.Framework))
    loadModule(('client/inventory/%s.lua'):format(Config.Inventory))
    loadModule(('client/target/%s.lua'):format(Config.Target))
    loadModule(('client/menu/%s.lua'):format(Config.Menu))
end

--------------------------------------------------------------------------
-- SOCIETY / BUSINESS MONEY (server only)
-- Job and gang bank accounts live in a banking/management resource, not the
-- framework itself, so this is one implementation shared by qbx/qb/esx
-- rather than a per-framework adapter file. Each entry in `societyBanks` is
-- tried in order (skipped if not running) until one succeeds - Renewed-Banking
-- first (this server's banking resource), qb-management as a fallback.
--
-- To support another banking/management script (see README.md "Adapting a
-- different society/business banking script" for a worked example), just
-- add another entry to this list - nothing else needs to change.
--------------------------------------------------------------------------

if isServer then
    local societyBanks = {
        {
            resource = 'Renewed-Banking',
            get = function(account) return exports['Renewed-Banking']:getAccountMoney(account) end,
            add = function(account, amount) return exports['Renewed-Banking']:addAccountMoney(account, amount) end,
            remove = function(account, amount) return exports['Renewed-Banking']:removeAccountMoney(account, amount) end,
        },
        {
            resource = 'qb-management',
            get = function(account) return exports['qb-management']:GetAccount(account) end,
            add = function(account, amount) return exports['qb-management']:AddMoney(account, amount) end,
            remove = function(account, amount) return exports['qb-management']:RemoveMoney(account, amount) end,
        },
    }

    local function tryBanks(fn)
        for _, bank in ipairs(societyBanks) do
            if GetResourceState(bank.resource) == 'started' then
                local ok, result = pcall(fn, bank)
                if ok then return true, result end
            end
        end
        return false, nil
    end

    ---@param account string job/gang name used as the account name
    ---@return number balance
    function Bridge.GetSocietyMoney(account)
        local ok, result = tryBanks(function(bank) return bank.get(account) end)
        return (ok and tonumber(result)) or 0
    end

    ---@return boolean success
    function Bridge.AddSocietyMoney(account, amount)
        local ok, result = tryBanks(function(bank) return bank.add(account, amount) end)
        return ok and result ~= false
    end

    ---@return boolean success
    function Bridge.RemoveSocietyMoney(account, amount)
        local ok, result = tryBanks(function(bank) return bank.remove(account, amount) end)
        return ok and result ~= false
    end
end

--------------------------------------------------------------------------
-- LICENSES (server only)
-- Built entirely on top of Bridge.GetMetadata/SetMetadata (defined by the
-- framework adapter files that load after this one - fine, since these are
-- only ever called at runtime, long after every adapter has loaded), so
-- this is one implementation shared by qbx/qb/esx rather than a
-- per-framework adapter file. Stored under the 'licences' metadata key.
--------------------------------------------------------------------------

if isServer then
    ---@return boolean whether the player holds this license
    function Bridge.HasLicense(src, name)
        local licences = Bridge.GetMetadata(src, 'licences') or {}
        return licences[name] == true
    end

    ---@return table<string, boolean> all licenses the player holds
    function Bridge.GetLicenses(src)
        return Bridge.GetMetadata(src, 'licences') or {}
    end

    ---@return boolean success
    function Bridge.AddLicense(src, name)
        local licences = Bridge.GetMetadata(src, 'licences') or {}
        licences[name] = true
        return Bridge.SetMetadata(src, 'licences', licences)
    end

    ---@return boolean success
    function Bridge.RemoveLicense(src, name)
        local licences = Bridge.GetMetadata(src, 'licences') or {}
        licences[name] = nil
        return Bridge.SetMetadata(src, 'licences', licences)
    end
end

--------------------------------------------------------------------------
-- DERIVED HELPERS (server only)
-- Built on top of Bridge.GetMoney/Add/RemoveMoney and Bridge.GetJobs/GetGangs
-- (defined by the framework adapter files that load after this one - fine,
-- since these are only ever called at runtime), so these are one
-- implementation shared by qbx/qb/esx rather than a per-framework file.
--------------------------------------------------------------------------

if isServer then
    ---Set a player's balance to an exact amount (no native "set" call on every
    ---framework, so this derives it from the existing get/add/remove).
    ---@return boolean success
    function Bridge.SetMoney(src, account, amount)
        local current = Bridge.GetMoney(src, account)
        local diff = amount - current
        if diff == 0 then return true end
        if diff > 0 then return Bridge.AddMoney(src, account, diff, 'smoke-bridge-setmoney') end
        return Bridge.RemoveMoney(src, account, -diff, 'smoke-bridge-setmoney')
    end

    ---@return boolean whether job (and, if given, grade) exists
    function Bridge.DoesJobExist(job, grade)
        local jobs = Bridge.GetJobs() or {}
        local jobData = jobs[job]
        if not jobData then return false end
        if grade == nil then return true end
        return jobData.grades ~= nil and jobData.grades[tonumber(grade)] ~= nil
    end

    ---@return boolean whether gang (and, if given, grade) exists
    function Bridge.DoesGangExist(gang, grade)
        local gangs = Bridge.GetGangs() or {}
        local gangData = gangs[gang]
        if not gangData then return false end
        if grade == nil then return true end
        return gangData.grades ~= nil and gangData.grades[tonumber(grade)] ~= nil
    end
end
