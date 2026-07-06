if Config.Menu ~= 'ox' then return end

---@param context table `{ id, title, menu?, onExit?, onBack?, canClose?, options }` or an array of these -
---each option is `{ title, description?, icon?, onSelect?, arrow?, disabled?, menu?, event?, serverEvent?, args? }`
function Bridge.RegisterMenu(context)
    lib.registerContext(context)
end

---@param id string
function Bridge.ShowMenu(id)
    lib.showContext(id)
end

---@param onExit? boolean
function Bridge.HideMenu(onExit)
    lib.hideContext(onExit)
end

---@return string? id of the currently open menu, if any
function Bridge.GetOpenMenu()
    return lib.getOpenContextMenu()
end
