if Config.Menu ~= 'custom' then return end

--------------------------------------------------------------------------
-- CUSTOM MENU BRIDGE (client)
--
-- Set Config.Menu = 'custom' in smoke-bridge/config.lua, then fill in the
-- functions below with your menu script's exports. Menus are always passed
-- in ox_lib's context-menu shape - register once by id, show/hide it
-- separately by id - since that's what every smoke-* script writes against:
--
--   Bridge.RegisterMenu({
--       id = 'my_menu', title = 'Menu Title',
--       options = {
--           { title = 'Option', description = '...', icon = 'fa-solid fa-...',
--             onSelect = function(args) ... end },
--       },
--   })
--   Bridge.ShowMenu('my_menu')
--
-- If your menu script instead wants one flat array built and opened in a
-- single call (like qb-menu), register into a local table here and only
-- build/open it when Bridge.ShowMenu is called - see client/menu/qb.lua for
-- a worked example of that conversion.
--------------------------------------------------------------------------

local registeredMenus = {}

---@param context table `{ id, title, options }` or an array of these
function Bridge.RegisterMenu(context)
    -- EXAMPLE (store it yourself, or forward straight to your menu script if it supports register-by-id):
    -- if context[1] then
    --     for _, c in ipairs(context) do registeredMenus[c.id] = c end
    -- else
    --     registeredMenus[context.id] = context
    -- end

    if context[1] then
        for _, c in ipairs(context) do registeredMenus[c.id] = c end
    else
        registeredMenus[context.id] = context
    end
end

---@param id string
function Bridge.ShowMenu(id)
    -- EXAMPLE:
    -- local context = registeredMenus[id]
    -- if not context then return end
    -- exports['my-menu']:Open(context)

    print(('[smoke-bridge] client/menu/custom.lua is not implemented - menu %s was NOT opened'):format(id))
end

---@param onExit? boolean
function Bridge.HideMenu(onExit)
    -- EXAMPLE:
    -- exports['my-menu']:Close()
end

---@return string? id of the currently open menu, if any
function Bridge.GetOpenMenu()
    return nil
end
