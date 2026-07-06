fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Smoke'
description 'Shared framework/inventory/target/menu bridge for smoke-* scripts'
version '1.0.0'

-- These run as this resource's own scripts too (not just something other
-- resources pull in) - real client_scripts/server_scripts/shared_scripts
-- declarations, using ordinary local glob patterns, same as any other
-- resource (this is what makes local globs work at all - '@resource/path'
-- cross-resource includes from OTHER resources don't support wildcards, but
-- a resource's own manifest always has). Consumers only ever pull in
-- '@smoke-bridge/config.lua' and '@smoke-bridge/shared.lua' (single named
-- files - see README.md); shared.lua's own module loader then reads the
-- matching framework/inventory/target/menu file straight out of this
-- resource with LoadResourceFile. Declaring everything here as well is what
-- makes those files visible to LoadResourceFile/'@' at all - see README.md
-- "How it works".
shared_scripts {
    'config.lua',
    '@ox_lib/init.lua',
    'shared.lua',
}

client_scripts {
    'client/framework/*.lua',
    'client/inventory/*.lua',
    'client/target/*.lua',
    'client/menu/*.lua',
}

server_scripts {
    'server/framework/*.lua',
    'server/inventory/*.lua',
}

dependencies {
    'ox_lib',
}
