## Installation

1. Put `smoke-bridge` in your resources folder.
2. Add this to `server.cfg` before any script that uses the bridge:
   ```cfg
   ensure smoke-bridge
   ```
Use `Bridge.*` in your client or server files.

Do not add any of `smoke-bridge`'s adapter files to your script's own `client_scripts` or `server_scripts`. The bridge loads the right files by itself.

Keep `@smoke-bridge/config.lua` above `@smoke-bridge/shared.lua`. The config is read first so the bridge knows which framework, inventory, target, and menu adapters to load.

The main bridge settings live in `resources/smoke-bridge/config.lua`:

- `Config.Framework`
- `Config.Inventory`
- `Config.Target`
- `Config.Menu`

Leave them on `auto` unless you need to force something specific. With `auto`, the bridge checks what is running and picks the first match:

- Framework: `qbx_core`, then `qb-core`, then `es_extended`
- Inventory: `qs-inventory`, then `ox_inventory`, then `qb-inventory`
- Target: `ox_target`, then `qb-target`
- Menu: `ox`

If you want no target resource, set `Config.Target = 'drawtext'`. If you want qb-menu, set `Config.Menu = 'qb'`. If you use a custom adapter, set the matching config value to `custom`.

After changing `smoke-bridge/config.lua`, restart `smoke-bridge` so every script using the bridge gets the new setting.

## Bridge API

| Side | Function | Purpose |
| --- | --- | --- |
| server | `Bridge.GetPlayer(src)` | raw framework player object (escape hatch for anything not covered below) |
| server | `Bridge.GetCitizenId(src)` | stable character identifier |
| server | `Bridge.GetCharName(src)` | display name |
| server | `Bridge.GetJob(src)` | `{ name, label, grade, gradeLabel, onDuty }` or `nil` |
| server | `Bridge.GetGang(src)` | `{ name, label, grade, gradeLabel} ` or `nil` (always `nil` on ESX - no gang system) |
| server | `Bridge.SetJob(src, job, grade)` / `Bridge.SetGang(src, gang, grade)` | change a player's job/gang (`SetGang` always returns `false` on ESX) |
| server | `Bridge.GetMoney(src, account)` / `Bridge.AddMoney(...)` / `Bridge.RemoveMoney(...)` | cash/bank balances |
| server | `Bridge.GetSocietyMoney(account)` / `Bridge.AddSocietyMoney(...)` / `Bridge.RemoveSocietyMoney(...)` | job/gang business bank accounts (Renewed-Banking, falls back to qb-management) - same on all 3 frameworks, defined once in shared.lua |
| server | `Bridge.GetSourceByCitizenId(cid)` | re-resolve an offline/relogged player |
| server | `Bridge.GetMetadata(src, key)` / `Bridge.SetMetadata(...)` / `Bridge.AddMetadata(src, key, amount, min, max)` | hunger/thirst/stress/armor/custom metadata (clamped 0-100 by default) |
| server | `Bridge.HasLicense(src, name)` / `Bridge.GetLicenses(src)` / `Bridge.AddLicense(...)` / `Bridge.RemoveLicense(...)` | weapon/driving/etc. licenses, stored under the `licences` metadata key - same on all 3 frameworks, defined once in shared.lua |
| server | `Bridge.SetMoney(src, account, amount)` | set an exact balance - derived from Get/Add/RemoveMoney, defined once in shared.lua |
| server | `Bridge.Notify(src, message, type, duration)` | server-triggered notification |
| server | `Bridge.CreateUseableItem(item, cb)` | register a useable item |
| server | `Bridge.CanUseItem(item)` | is this item registered as useable? |
| server | `Bridge.OnPlayerLoaded(cb)` | fires once a character finishes loading - `cb(source, player)`, normalized the same way on all 3 frameworks even though qbx/qb's own event only natively passes `player` and ESX's only natively passes `source` |
| server | `Bridge.GetOfflinePlayer(citizenid)` | offline player data, or `nil` (best-effort on ESX - no built-in equivalent) |
| server | `Bridge.GetPlayerByPhone(phone)` | re-resolve a player by phone number (always `nil` on ESX - no phone identity) |
| server | `Bridge.GetJobs()` / `Bridge.GetGangs()` | every job/gang definition, keyed by name (gangs always `{}` on ESX) |
| server | `Bridge.DoesJobExist(job, grade)` / `Bridge.DoesGangExist(gang, grade)` | validate before `SetJob`/`SetGang` - derived from `GetJobs`/`GetGangs`, defined once in shared.lua |
| server | `Bridge.Save(src)` | force-save a player's data to the database |
| server | `Bridge.HasPermission(src, permission)` / `Bridge.AddPermission(...)` / `Bridge.RemovePermission(...)` | permission checks (ESX has no runtime grant system - `HasPermission` checks ACE, add/remove are no-ops) |
| server | `Bridge.IsWhitelisted(src)` / `Bridge.IsPlayerBanned(src)` | always permissive (`true`/`false`) on ESX - no built-in equivalent |
| server | `Bridge.CanCarryItem(src, item, amount)` | can the player hold this? |
| server | `Bridge.AddItem(src, item, amount, metadata, slot)` / `Bridge.RemoveItem(src, item, amount, slot)` | give/take items |
| server | `Bridge.HasItem(src, item, amount)` / `Bridge.GetItemCount(src, item)` | inventory checks |
| server | `Bridge.GetItemBySlot(src, slot)` / `Bridge.GetFirstSlotByItem(src, item)` | slot-level lookups |
| server | `Bridge.GetItemMetadata(src, slot)` / `Bridge.SetItemMetadata(src, slot, metadata)` | per-slot item metadata |
| server | `Bridge.GetInventory(src)` / `Bridge.ClearInventory(src, keep)` | full inventory contents / wipe it |
| server | `Bridge.RegisterStash(id, slots, weight, owner, groups)` / `Bridge.OpenStash(src, id, slots, weight, label)` | register a stash, or register-once-and-open for a player |
| server | `Bridge.RegisterShop(name, items, groups)` / `Bridge.OpenShop(src, name)` | native inventory-registered shop |
| server | `Bridge.ConfiscateInventory(src)` / `Bridge.ReturnInventory(src)` | jail/impound - falls back to a metadata snapshot if the inventory has no native confiscate/return |
| server | `Bridge.GetCurrentWeapon(src)` | currently-held weapon slot data, or `nil` |
| server | `Bridge.SetDurability(src, slot, durability)` | set a weapon/tool's durability |
| server | `Bridge.GetFreeWeight(src)` | remaining carry weight (best-effort on ox/qs, `math.huge` if unsupported) |
| client | `Bridge.GetCitizenId()` | local character identifier |
| client | `Bridge.GetJob()` | `{ name, label, grade, gradeLabel, onDuty }` or `nil` |
| client | `Bridge.GetJobs()` / `Bridge.GetGangs()` | every job/gang definition, keyed by name (gangs always `{}` on ESX) |
| client | `Bridge.Notify(message, type, duration)` | client-triggered notification |
| client | `Bridge.OnPlayerLoaded(cb)` | fires when the local character finishes loading |
| client | `Bridge.GetItemLabel(name)` | display label for an item (falls back to the raw name) |
| client | `Bridge.HasItem(item, amount)` / `Bridge.GetItemCount(item)` | local player inventory checks (no server round trip) |
| client | `Bridge.GetInventory()` | every item the local player carries |
| client | `Bridge.Search(item, metadata)` | matching item slots (qb falls back to filtering the local item list) |
| client | `Bridge.CloseInventory()` | force-close the local player's inventory UI |
| client | `Bridge.LockInventory()` / `Bridge.UnlockInventory()` | disable/enable inventory interaction (e.g. during a search/loot animation) |
| client | `Bridge.AddBoxZone(id, coords, size, rotation, options, debug)` / `Bridge.AddSphereZone(id, coords, radius, options, debug)` | zone-based targeting; `options` is a single `{ icon, label, onSelect, canInteract, distance, ... }` table or an array of them |
| client | `Bridge.RemoveZone(id)` | remove a zone created with `AddBoxZone`/`AddSphereZone` |
| client | `Bridge.AddEntityZone(entity, options)` / `Bridge.RemoveEntityZone(entity, labels)` | target a specific local entity handle (or array of them) |
| client | `Bridge.AddModelZone(models, options)` / `Bridge.RemoveModelZone(models, labels)` | target every entity matching a model name/hash (or array of them) |
| client | `Bridge.AddGlobalPed(options)` / `Bridge.AddGlobalVehicle(options)` / `Bridge.AddGlobalObject(options)` / `Bridge.AddGlobalPlayer(options)` (+ matching `Remove*(labels)`) | target every ped/vehicle/object/player in the world |
| client | `Bridge.DisableTargeting(state)` | `true` disables all targeting (handles ox_target/qb-target's inverted polarity internally) |
| client | `Bridge.RegisterMenu(context)` | register a menu (or array of menus) by id - `{ id, title, menu?, onExit?, onBack?, options }`, options are `{ title, description?, icon?, onSelect?, arrow?, disabled?, menu?, event?, serverEvent?, args? }` |
| client | `Bridge.ShowMenu(id)` / `Bridge.HideMenu(onExit)` | open/close a registered menu by id |
| client | `Bridge.GetOpenMenu()` | id of the currently open menu, or `nil` |

### Inventory export confidence

Every server inventory function was cross-checked against real `exports['qs-inventory']:*` / `exports.ox_inventory:*` / `exports['qb-inventory']:*` calls actually used elsewhere in this codebase (dozens of independent third-party resources), not just guessed from documentation. Functions with no confirmed real export for a given inventory (`RegisterShop`/`OpenShop` and `ConfiscateInventory`/`ReturnInventory` on qs and qb, `GetCurrentWeapon`/`SetDurability` on qs and qb, `GetFreeWeight` on qs) are still implemented - `pcall`-wrapped with a documented best-effort guess or a manual fallback (e.g. confiscate/return falls back to snapshotting the inventory into a metadata key) - so they degrade gracefully instead of erroring if the guessed export name doesn't exist on your build. Check the `@note` comments in each `server/inventory/*.lua` file before relying on those specific calls in production.

### Framework export confidence

The qbx adapter is backed by `qbx_core`'s actual source (installed in this project and fully open-source, not escrowed), including its own bundled qb-core compatibility shim (`qbx_core/bridge/qb/`) - which doubles as a confirmed reference for real `QBCore.Functions.*` names and signatures, since it's qbx_core's own developers reimplementing the real qb-core API for backwards compatibility. That's how this bridge caught real naming differences instead of guessing: qb-core's offline-lookup is `GetOfflinePlayerByCitizenId`, not qbx's `GetOfflinePlayer`; qb-core has no native `SetMoney`, so `Bridge.SetMoney` is instead derived once in `shared.lua` from `GetMoney`/`AddMoney`/`RemoveMoney` for all three frameworks; job/gang grade keys are **numbers** (`grades[0]`, `grades[1]`), which is why `DoesJobExist`/`DoesGangExist` use `tonumber(grade)` rather than `tostring(grade)`. ESX has no equivalent for several of these (gangs, phone-number identity, runtime permission grants, whitelist/ban systems) - those are documented as permissive/no-op fallbacks rather than errors, consistent with how `GetGang`/`SetGang` already behave.

Every export-based call is `pcall`-wrapped so a missing/renamed export degrades gracefully (`CanCarryItem`/`HasItem` default to permissive/`0`, `AddItem`/`RemoveItem` default to `false`) instead of throwing and killing your script's whole call chain.

### Target export confidence

`ox_target` is installed in this project and fully open-source, so `client/target/ox.lua` is backed by reading its actual client API (`client/api.lua`) directly rather than guessing - `addBoxZone`/`addSphereZone`/`addLocalEntity`/`addModel`/`addGlobalPed`+`Vehicle`+`Object`+`Player`/`removeZone`/`disableTargeting` are all confirmed real exports with confirmed signatures. `qb-target` isn't installed here, so `client/target/qb.lua` is instead backed by `DHS-Bridge`'s (a third-party bridge already in this project) own `target/qb-target/client.lua` adapter - real working code translating the same option shape to qb-target's calls, which is how this bridge learned qb-target wants one shared `distance` per zone/entity instead of a per-option `distance`, and a plain `action(entity)` callback instead of `onSelect(data)` - see the `convert()` helper at the top of `client/target/qb.lua`. `Bridge.DisableTargeting` also normalizes a real behavioral difference: `ox_target:disableTargeting(true)` disables, but `qb-target:AllowTargeting(true)` *enables* - the qb adapter negates the argument so `Bridge.DisableTargeting(true)` means "disable" on both.

### No target resource at all (`drawtext` fallback)

If your server doesn't run ox_target or qb-target (and doesn't want to), set `Config.Target = 'drawtext'` in `smoke-bridge/config.lua`. `client/target/drawtext.lua` implements the full `Bridge.Add*`/`Remove*` surface itself with a simple proximity check: a floating 3D prompt appears when you're near a registered zone/entity/model/global-watcher, and pressing `Config.TargetKey` (default `38`/E, labeled via `Config.TargetKeyLabel`) fires `onSelect`. It's distance-only - there's no raycasting, so with several overlapping watchers it picks whichever is nearest, not whichever you're actually looking at.

`Bridge.AddGlobalPed`/`AddGlobalVehicle`/`AddGlobalObject`/`AddGlobalPlayer` scan the *entire* matching entity pool every check in this mode (there's no target resource's engine-level spatial index to lean on) - noticeably more expensive than the ox_target/qb-target adapters. Fine for a couple of watchers on a server that's deliberately not running a target resource; don't reach for the global variants heavily here. `Bridge.AddBoxZone` is also approximated as a sphere (`max(length, width) / 2`) since there's no rotation-aware box check.

### Menu export confidence

Both `ox_lib` and `qb-menu` are installed in this project and fully open-source, so `client/menu/ox.lua` and `client/menu/qb.lua` are backed by reading their actual sources directly (`ox_lib/resource/interface/client/context.lua` and `qb-menu/client/main.lua`) rather than guessing - `lib.registerContext`/`lib.showContext`/`lib.hideContext`/`lib.getOpenContextMenu` and `exports['qb-menu']:openMenu`/`closeMenu` are all confirmed real. `Bridge.RegisterMenu`/`ShowMenu` always take ox_lib's shape (register once by id, show/hide separately), since qb-menu has no register-by-id step of its own - `client/menu/qb.lua` converts and opens on every `Bridge.ShowMenu` call instead, following the same conversion this project's own `community_bridge/modules/menu/qb-menu/client.lua` uses (title→header, description→txt, and an `onSelect` closure wired to qb-menu's real `action` field, which its own source confirms accepts a plain function). qb-menu has no automatic back-button/`onBack` the way ox_lib's context menu does - add your own option with `menu` pointing at the parent id if you want one.

### Using a custom framework, inventory, target, or menu system

Copy any file pair from `server/framework/` + `client/framework/` (or `server/inventory/` + `client/inventory/`, or just `client/target/`/`client/menu/` - targeting and menus have no server side), change its guard (`if Config.Framework ~= 'yourname' then return end`), implement the functions from the table above, and set `Config.Framework = 'yourname'` in **`smoke-bridge/config.lua`** (or `Config.Inventory`/`Config.Target`/`Config.Menu = 'custom'` there - all four templates already ship as `custom.lua`, fill in the exports and go). Since the config lives in this resource, that one edit applies to every script using the bridge.

Until a custom inventory is implemented, it's intentionally safe: `AddItem`/`RemoveItem` return `false` and print a `[<your-resource>] server/inventory/custom.lua is not implemented` warning instead of silently eating items. The custom target/menu templates' functions are mostly empty stubs (targeting and menus have no natural "safe no-op" the way inventory does) - fill them in before setting `Config.Target`/`Config.Menu = 'custom'` in production.

### Adapting a different society/business banking script

`Bridge.GetSocietyMoney`/`AddSocietyMoney`/`RemoveSocietyMoney` (in `shared.lua`) try a list of banking/management resources in order and skip any that aren't running - Renewed-Banking, then qb-management. If your server uses something else (okokBanking, fd_banking, esx_society, a custom in-house one, etc.), add an entry to the `societyBanks` table in `shared.lua` - nothing else needs to change, the three `Bridge.*` functions already loop over the whole list.

Each entry just needs a `resource` name and three functions that take `(account)` / `(account, amount)` and return the balance / a truthy-on-success value:

```lua
{
    resource = 'okokBanking', -- exact resource name as it appears in server.cfg/txAdmin
    get = function(account) return exports['okokBanking']:GetAccount(account) end,
    add = function(account, amount) return exports['okokBanking']:AddMoney(account, amount) end,
    remove = function(account, amount) return exports['okokBanking']:RemoveMoney(account, amount) end,
},
```

Not every banking script exposes plain exports - some (classic ESX's `esx_society`, for example) use an event + callback to hand back a shared account object instead. That still fits the same shape, since `get`/`add`/`remove` can contain whatever logic they need, as long as they return a value synchronously:

```lua
{
    resource = 'esx_society',
    get = function(account)
        local balance = 0
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. account, function(acc)
            balance = acc and acc.money or 0
        end)
        return balance
    end,
    add = function(account, amount)
        local success = false
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. account, function(acc)
            if acc then acc.addMoney(amount) success = true end
        end)
        return success
    end,
    remove = function(account, amount)
        local success = false
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. account, function(acc)
            if acc then acc.removeMoney(amount) success = true end
        end)
        return success
    end,
},
```

Add your entry **above** Renewed-Banking/qb-management in the list if you want it tried first, or below if it should only be a last-resort fallback - order is priority order, and each entry is skipped entirely (not even called) if `GetResourceState(resource)` isn't `'started'`, so it's safe to leave every entry in the list on servers that only run one of them.

For an obscure/in-house script with no docs, check its own `fxmanifest.lua`/source for `exports(...)` calls to find the real function names - don't guess, since a wrong name just silently falls through to the next entry (or to `0`/`false` if it was the last one) rather than erroring, which is easy to mistake for "it's just not installed."

### ox_inventory stash caveat

`ox_inventory` has no server-side "force open" call, so `Bridge.OpenStash` fires a `smoke-bridge:client:openStash` client event that `client/inventory/ox.lua` forwards to `exports.ox_inventory:openInventory('stash', id)`. If you write a custom inventory bridge and need the same pattern, copy that handler into your own `client/inventory/custom.lua`.
