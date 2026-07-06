if Config.Menu ~= 'qb' then return end

--------------------------------------------------------------------------
-- Bridge.RegisterMenu/ShowMenu always take menus in ox_lib's context-menu
-- shape (register once by id, show/hide separately, submenus referenced by
-- id) since that's what smoke-* scripts write against. qb-menu instead wants
-- one flat array built and opened in a single call, so menus are registered
-- into a local table here and only converted+opened when Bridge.ShowMenu is
-- called.
--
-- qb-menu has no automatic "back" button/onBack the way ox_lib's context
-- menu does - if you want one, add your own option with `menu` pointing at
-- the parent id (Bridge.ShowMenu re-opens it, same as any other submenu
-- link) rather than relying on `context.onBack`, which is never called here.
--------------------------------------------------------------------------

local registeredMenus = {}
local openId = nil

local function convert(context)
    local qbMenu = {}

    if context.title then
        qbMenu[#qbMenu + 1] = { header = context.title, isMenuHeader = true }
    end

    for _, opt in ipairs(context.options) do
        local button = {
            header = opt.title,
            txt = opt.description,
            icon = type(opt.icon) == 'string' and opt.icon or nil,
            disabled = opt.disabled,
        }

        if opt.menu then
            button.action = function() Bridge.ShowMenu(opt.menu) end
        elseif opt.onSelect then
            button.action = function() opt.onSelect(opt.args) end
        elseif opt.serverEvent then
            button.params = { event = opt.serverEvent, args = opt.args, isServer = true }
        elseif opt.event then
            button.params = { event = opt.event, args = opt.args }
        end

        qbMenu[#qbMenu + 1] = button
    end

    return qbMenu
end

function Bridge.RegisterMenu(context)
    if context[1] then
        for _, c in ipairs(context) do registeredMenus[c.id] = c end
    else
        registeredMenus[context.id] = context
    end
end

function Bridge.ShowMenu(id)
    local context = registeredMenus[id]
    if not context then return end
    openId = id
    exports['qb-menu']:openMenu(convert(context))
end

function Bridge.HideMenu(onExit)
    local context = openId and registeredMenus[openId]
    exports['qb-menu']:closeMenu()
    if onExit and context and context.onExit then context.onExit() end
    openId = nil
end

function Bridge.GetOpenMenu()
    return openId
end
