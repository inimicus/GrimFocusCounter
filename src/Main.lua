-- -----------------------------------------------------------------------------
-- Grim Focus Counter
-- Author:  g4rr3t
-- Created: Dec 20, 2017
--
-- Track stacks of Grim Focus and its morphs and display
-- the stacks in a very visual and obvious way.
--
-- Main.lua
-- -----------------------------------------------------------------------------
GFC             = {}
GFC.name        = "GrimFocusCounter"
GFC.version     = "0.2.0"
GFC.dbVersion   = 1
GFC.slash       = "/gfc"
GFC.prefix      = "[GFC] "
GFC.HUDHidden   = false
GFC.ForceShow   = false

-- -----------------------------------------------------------------------------
-- Level of debug output
-- 1: Low    - Basic debug info, show core functionality
-- 2: Medium - More information about skills and addon details
-- 3: High   - Everything
GFC.debugMode = 0
-- -----------------------------------------------------------------------------

function GFC:Trace(debugLevel, ...)
    if debugLevel <= GFC.debugMode then
        d(GFC.prefix .. ...)
    end
end

-- -----------------------------------------------------------------------------
-- Startup
-- -----------------------------------------------------------------------------

function GFC.Initialize(event, addonName)
    if addonName ~= GFC.name then return end

    GFC:Trace(1, "GFC Loaded")
    EVENT_MANAGER:UnregisterForEvent(GFC.name, EVENT_ADD_ON_LOADED)

    GFC.preferences = ZO_SavedVars:NewAccountWide("GrimFocusCounterVariables", GFC.dbVersion, nil, GFC:GetDefaults())

    SLASH_COMMANDS[GFC.slash] = GFC.SlashCommand

    GFC:InitSettings()
    GFC.DrawUI()
    GFC.ToggleHUD()

    -- Events for each skill morph
    -- Separate namespaces for each are required as
    -- duplicate filters against the same namespace
    -- overwrite the previously set filter.
    --
    -- These filter the EVENT_EFFECT_CHANGED event to
    -- hit the callback *only* when the three specific
    -- ability IDs change and avoid the need to conditionally
    -- exclude all skills we are not interested in.

    EVENT_MANAGER:RegisterForEvent(GFC.ABILITIES.MERCILESS_RESOLVE.STACK.NAME, EVENT_EFFECT_CHANGED, function(...) GFC.OnStackChanged(...) end)
    EVENT_MANAGER:AddFilterForEvent(GFC.ABILITIES.MERCILESS_RESOLVE.STACK.NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, GFC.ABILITIES.MERCILESS_RESOLVE.STACK.ID)
    EVENT_MANAGER:AddFilterForEvent(GFC.ABILITIES.MERCILESS_RESOLVE.STACK.NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    EVENT_MANAGER:RegisterForEvent(GFC.ABILITIES.RELENTLESS_FOCUS.STACK.NAME, EVENT_EFFECT_CHANGED, function(...) GFC.OnStackChanged(...) end)
    EVENT_MANAGER:AddFilterForEvent(GFC.ABILITIES.RELENTLESS_FOCUS.STACK.NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, GFC.ABILITIES.RELENTLESS_FOCUS.STACK.ID)
    EVENT_MANAGER:AddFilterForEvent(GFC.ABILITIES.RELENTLESS_FOCUS.STACK.NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    EVENT_MANAGER:RegisterForEvent(GFC.ABILITIES.GRIM_FOCUS.STACK.NAME, EVENT_EFFECT_CHANGED, function(...) GFC.OnStackChanged(...) end)
    EVENT_MANAGER:AddFilterForEvent(GFC.ABILITIES.GRIM_FOCUS.STACK.NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, GFC.ABILITIES.GRIM_FOCUS.STACK.ID)
    EVENT_MANAGER:AddFilterForEvent(GFC.ABILITIES.GRIM_FOCUS.STACK.NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    if GFC.preferences.showEmptyStacks then
        EVENT_MANAGER:RegisterForEvent(GFC.ABILITIES.MERCILESS_RESOLVE.SKILL.NAME, EVENT_EFFECT_CHANGED, function(...) GFC.OnEffectChanged(...) end)
        EVENT_MANAGER:AddFilterForEvent(GFC.ABILITIES.MERCILESS_RESOLVE.SKILL.NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, GFC.ABILITIES.MERCILESS_RESOLVE.SKILL.ID)
        EVENT_MANAGER:AddFilterForEvent(GFC.ABILITIES.MERCILESS_RESOLVE.SKILL.NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

        EVENT_MANAGER:RegisterForEvent(GFC.ABILITIES.RELENTLESS_FOCUS.SKILL.NAME, EVENT_EFFECT_CHANGED, function(...) GFC.OnEffectChanged(...) end)
        EVENT_MANAGER:AddFilterForEvent(GFC.ABILITIES.RELENTLESS_FOCUS.SKILL.NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, GFC.ABILITIES.RELENTLESS_FOCUS.SKILL.ID)
        EVENT_MANAGER:AddFilterForEvent(GFC.ABILITIES.RELENTLESS_FOCUS.SKILL.NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

        EVENT_MANAGER:RegisterForEvent(GFC.ABILITIES.GRIM_FOCUS.SKILL.NAME, EVENT_EFFECT_CHANGED, function(...) GFC.OnEffectChanged(...) end)
        EVENT_MANAGER:AddFilterForEvent(GFC.ABILITIES.GRIM_FOCUS.SKILL.NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, GFC.ABILITIES.GRIM_FOCUS.SKILL.ID)
        EVENT_MANAGER:AddFilterForEvent(GFC.ABILITIES.GRIM_FOCUS.SKILL.NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    end

end

-- -----------------------------------------------------------------------------
-- Event Hooks
-- -----------------------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent(GFC.name, EVENT_ADD_ON_LOADED, function(...) GFC.Initialize(...) end)

