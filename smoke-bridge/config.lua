Config = Config or {}

-- Set once here for every script that includes '@smoke-bridge/...' - there is
-- no per-script override, so changing these values re-targets every
-- smoke-bridge consumer on the server at the same time.
Config.Framework = 'auto'   -- 'auto' | 'qb' | 'qbx' | 'esx'
Config.Inventory = 'auto'   -- 'auto' | 'ox' | 'qb' | 'qs' | 'custom'

-- Set to drawtext if your server doesn't have a target system, or if you want to use the built-in drawtext prompt system.
Config.Target = 'auto'      -- 'auto' | 'ox' | 'qb' | 'drawtext' | 'custom'

-- Only used when Config.Target = 'drawtext' - the control to press to
-- interact when a prompt is showing, and the label shown for it in the
-- floating prompt (e.g. '[E] Open Shop'). Defaults to E (INPUT_CONTEXT).
Config.TargetKey = 38
Config.TargetKeyLabel = 'E'

-- ox_lib is already a hard dependency of this bridge (@ox_lib/init.lua), so
-- 'auto' always resolves to 'ox' - there's nothing to detect the way there is
-- for Framework/Inventory/Target. Set 'qb' if you'd rather use qb-menu, or
-- 'custom' to adapt your own menu script.
Config.Menu = 'auto'   -- 'auto' | 'ox' | 'qb' | 'custom'
