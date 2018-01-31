-- -----------------------------------------------------------------------------
-- Grim Focus Counter
-- Author:  g4rr3t
-- Created: Jan 1, 2018
--
-- Settings.lua
-- -----------------------------------------------------------------------------

local LAM = LibStub("LibAddonMenu-2.0")

local panelData = {
    type        = "panel",
    name        = "Grim Focus Counter",
    displayName = "Grim Focus Counter",
    author      = "g4rr3t",
    version     = GFC.version,
    registerForRefresh  = true,
}

local optionsTable = {
    [1] = {
        type = "header",
        name = "Display Options",
        width = "full",
    },
    [2] = {
        type = "button",
        name = function() if GFC.preferences.unlocked then return "Lock" else return "Unlock" end end,
        tooltip = "Toggle lock/unlock state of counter display for repositioning.",
        func = function(control) ToggleLocked(control) end,
        width = "half",
    },
    [3] = {
        type = "button",
        --name = "Toggle Show",
        name = function() if GFC.ForceShow then return "Hide" else return "Show" end end,
        tooltip = "Force show for position or previewing display settings.",
        func = function(control) ForceShow(control) end,
        width = "half",
    },
    [4] = {
        type = "dropdown",
        name = "Counter Style",
        tooltip = "Style of counter display.",
        choices = {"Color Squares", "DOOM", "Horizontal Dots", "Numbers", "Dice"},
        choicesValues = {0, 1, 2, 3, 4},
        getFunc = function() return GetTexture() end,
        setFunc = function(texture) SetTexture(texture) end,
        width = "full",
    },
	[5] = {
		type = "description",
		text = "",
		width = "half",
	},
	[6] = {
		type = "description",
		text = "All styles are a work in progress, non-final, and very rough.",
		width = "half",
	},
    [7] = {
        type = "slider",
        name = "Display Size",
        tooltip = "Display size of counter.",
        min = 0,
        max = 500,
        step = 5,
        getFunc = function() return GetSize() end,
        setFunc = function(value) SetSize(value) end,
        width = "full",
        default = 40,
    },
    [8] = {
        type = "checkbox",
        name = "Show Zero Stacks",
        tooltip = "Show when skill is active but no stacks tracked.",
        requiresReload = true,
        getFunc = function() return GetZeroStacks() end,
        setFunc = function(value) SetZeroStacks(value) end,
        width = "full",
    },
	[9] = {
		type = "description",
		text = "",
		width = "half",
	},
	[10] = {
		type = "description",
		text = "Not all display styles currently include indicators for zero stacks.",
		width = "half",
	},
}

-- -----------------------------------------------------------------------------
-- Helper functions to set/get settings
-- -----------------------------------------------------------------------------

-- Locked State
function ToggleLocked(control)
    GFC.preferences.unlocked = not GFC.preferences.unlocked
    GFC.GFCContainer:SetMovable(GFC.preferences.unlocked)
    if GFC.preferences.unlocked then
        control:SetText("Lock")
    else 
        control:SetText("Unlock")
    end 
end

-- Force Showing
function ForceShow(control)
	GFC.ForceShow = not GFC.ForceShow
    if GFC.ForceShow then
        control:SetText("Hide")
		GFC.HUDHidden = false
		GFC.GFCContainer:SetHidden(false)
		GFC.UpdateStacks(5)
    else 
        control:SetText("Show")
		GFC.HUDHidden = true
		GFC.GFCContainer:SetHidden(true)
		GFC.UpdateStacks(0)
    end 
end

-- Textures
function SetTexture(value)
    GFC.GFCTexture:SetTexture(GFC.TEXTURE_VARIANTS[value].asset)
    GFC.preferences.selectedTexture = value
end

function GetTexture()
    return GFC.preferences.selectedTexture
end

-- Sizing
function SetSize(value)
    GFC.preferences.size = value
    GFC.GFCContainer:SetDimensions(value, value)
    GFC.GFCTexture:SetDimensions(value, value)
end

function GetSize()
    return GFC.preferences.size
end

-- Zero Stacks
function SetZeroStacks(value)
    GFC.preferences.showEmptyStacks = value
end

function GetZeroStacks()
    return GFC.preferences.showEmptyStacks
end


-- -----------------------------------------------------------------------------
-- Initialize Settings
-- -----------------------------------------------------------------------------

function GFC:InitSettings()
    LAM:RegisterAddonPanel(GFC.name, panelData)
    LAM:RegisterOptionControls(GFC.name, optionsTable)
end

