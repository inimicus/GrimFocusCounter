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
GFC.version     = "1.4.4"
GFC.dbVersion   = 1
GFC.slash       = "/gfc"
GFC.prefix      = "[GFC] "
GFC.HUDHidden   = false
GFC.ForceShow   = false
GFC.isInCombat  = false

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

    -- First trace uses above debugMode value until preferences are loaded.
    -- The only way these two messages will appear is by changing the above
    -- value to greater than 0.
    -- Since these are only used during dev and QA, it should not impact
    -- any user functionality or features.
    if GetUnitClassId("player") ~= 3 then
        GFC:Trace(1, "Non-nightblade class detected, aborting addon initialization.")
        EVENT_MANAGER:UnregisterForEvent(GFC.name, EVENT_ADD_ON_LOADED)
        return
    end

    GFC:Trace(1, "GFC Loaded")
    EVENT_MANAGER:UnregisterForEvent(GFC.name, EVENT_ADD_ON_LOADED)

    GFC.preferences = ZO_SavedVars:NewAccountWide("GrimFocusCounterVariables", GFC.dbVersion, nil, GFC:GetDefaults())
    GFC:UpgradeSettings()

    -- Use saved debugMode value if the above value has not been changed
    if GFC.debugMode == 0 then
        GFC.debugMode = GFC.preferences.debugMode
        GFC:Trace(1, "Setting debug value to saved: " .. GFC.preferences.debugMode)
    end

    SLASH_COMMANDS[GFC.slash] = GFC.SlashCommand

    GFC:InitSettings()
    GFC.DrawUI()
    GFC.ToggleHUD()
    GFC.RegisterEvents()

    GFC:Trace(2, "Finished Initialize()")
end

-- -----------------------------------------------------------------------------
-- Event Hooks
-- -----------------------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent(GFC.name, EVENT_ADD_ON_LOADED, function(...) GFC.Initialize(...) end)

