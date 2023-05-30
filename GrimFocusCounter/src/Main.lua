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
GFC           = {}
GFC.name      = "GrimFocusCounter"
GFC.version   = "1.5.0"
GFC.dbVersion = 1
GFC.slash     = "/gfc"
GFC.prefix    = "[GFC] "
GFC.HUDHidden = false
GFC.ForceShow = false

-- -----------------------------------------------------------------------------
-- Locals
-- -----------------------------------------------------------------------------
local EM      = EVENT_MANAGER
local SC      = SLASH_COMMANDS

-- -----------------------------------------------------------------------------
-- Level of debug output
-- 1: Low    - Basic debug info, show core functionality
-- 2: Medium - More information about skills and addon details
-- 3: High   - Everything
GFC.debugMode = 0
-- -----------------------------------------------------------------------------

function GFC:Trace(debugLevel, message, ...)
    if debugLevel <= self.debugMode then
        d(zo_strformat(self.prefix .. message, ...))
    end
end

-- -----------------------------------------------------------------------------
-- Startup
-- -----------------------------------------------------------------------------

function GFC:Initialize(_, addonName)
    if GetUnitClassId("player") ~= 3 then
        self:Trace(1, "Non-nightblade class detected, aborting addon initialization.")
        EM:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
        return
    end

    if addonName ~= self.name then return end

    self:Trace(1, "GFC Loaded")
    EM:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)

    -- First two traces use above debugMode value until preferences are loaded.
    -- The only way these messages will appear is by changing the above
    -- value to greater than 0.
    --
    -- Since these are only used during dev and QA, it should not impact
    -- any user functionality or features.

    self.preferences = ZO_SavedVars:NewAccountWide("GrimFocusCounterVariables", self.dbVersion, nil, self:GetDefaults())
    self:UpgradeSettings()

    -- Use saved debugMode value if the above value has not been changed
    if self.debugMode == 0 then
        self.debugMode = self.preferences.debugMode
        self:Trace(1, "Setting debug value to saved: " .. self.preferences.debugMode)
    end

    SC[self.slash] = self.SlashCommand

    self:InitSettings()
    self:DrawUI()
    self:RegisterEvents()

    self:Trace(2, "Finished Initialize()")
end

-- -----------------------------------------------------------------------------
-- Event Hooks
-- -----------------------------------------------------------------------------

EM:RegisterForEvent(GFC.name .. "_Init", EVENT_ADD_ON_LOADED, function(...) GFC:Initialize(...) end)
