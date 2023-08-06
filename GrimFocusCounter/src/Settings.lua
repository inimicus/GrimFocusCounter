-- -----------------------------------------------------------------------------
-- Grim Focus Counter
-- Author:  g4rr3t
-- Created: Jan 1, 2018
--
-- Settings.lua
-- -----------------------------------------------------------------------------

local LAM = LibAddonMenu2
local GFC = GFC

local panelData = {
    type               = "panel",
    name               = "Grim Focus Counter",
    displayName        = "Grim Focus Counter",
    author             = "g4rr3t",
    version            = GFC.version,
    registerForRefresh = true,
}

-- -----------------------------------------------------------------------------
-- Helper functions to set/get settings
-- -----------------------------------------------------------------------------

--- Update the hideOutOfCombat settings
--- @param hide boolean True to hide when out of combat
--- @return nil
local function setHideOutOfCombat(hide)
    GFC.preferences.hideOutOfCombat = hide

    if hide then
        GFC:RegisterCombatEvent()
        GFC:OnPlayerChanged()
    else
        GFC:UnregisterCombatEvent()
        GFC:AddSceneFragments()
    end
end

--- Get the hideOutOfCombat setting
--- @return boolean hide True when hideOutOfCombat is enabled
local function getHideOutOfCombat()
    return GFC.preferences.hideOutOfCombat
end

-- Locked the locked state
--- @param control any Button control to update text label for
--- @return nil
function ToggleLocked(control)
    GFC.preferences.unlocked = not GFC.preferences.unlocked
    GFC.GFCContainer:SetMovable(GFC.preferences.unlocked)
    if GFC.preferences.unlocked then
        control:SetText("Lock")
    else
        control:SetText("Unlock")
    end
end

--- Force show the display
--- @param control any Button control to update text label for
--- @return nil
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
        GFC:OnPlayerChanged()
    end
end

--- Update the selected texture
--- @param value string Texture picker selection value
--- @return nil
function SetTexture(value)
    local selectedTexture = nil

    -- Search texture array
    -- We are passed the picker's texture,
    -- convert to the index of the texture table.
    for index, texture in pairs(GFC.TEXTURE_VARIANTS) do
        if texture.picker == value then
            selectedTexture = index
            break
        end
    end

    if selectedTexture ~= nil then
        GFC.GFCTexture:SetTexture(GFC.TEXTURE_VARIANTS[selectedTexture].asset)
        GFC.preferences.selectedTexture = selectedTexture
    else
        d('[GFC] Could not load specified texture!')
    end
end

--- Get the selected texture's picker option
--- @return string value Picker texture
function GetTexture()
    local selectedTexture = GFC.preferences.selectedTexture
    return GFC.TEXTURE_VARIANTS[selectedTexture].picker
end

--- Set the display size
--- @param value integer Display size
--- @return nil
function SetSize(value)
    GFC.preferences.size = value
    GFC.GFCContainer:SetDimensions(value, value)
    GFC.GFCTexture:SetDimensions(value, value)
end

--- Get the display size
--- @return integer
function GetSize()
    return GFC.preferences.size
end

--- Set the showEmptyStacks value
--- @param value boolean True to enable showing empty (zero) stacks
--- @return nil
function SetZeroStacks(value)
    GFC.preferences.showEmptyStacks = value
end

--- Get the showEmptyStacks value
--- @return boolean value True to show empty (zero) stacks
function GetZeroStacks()
    return GFC.preferences.showEmptyStacks
end

--- Set the color overlay for the given overlay type
--- @param overlayType string The overlay type
--- @param value boolean True to enable color overlay for the given overlay type
--- @return nil
function SetColorOverlay(overlayType, value)
    GFC.preferences.overlay[overlayType] = value
    GFC.SetSkillColorOverlay('default')
end

--- Get the color overlay for a given type
--- @param overlayType string The overlay type
--- @return boolean value True when color overlay is enabled for the given overlay type
function GetColorOverlay(overlayType)
    return GFC.preferences.overlay[overlayType]
end

--- Set the color overlay values for the given overlay type
--- @param overlayType string The overlay type
--- @param r integer Red value
--- @param g integer Green value
--- @param b integer Blue value
--- @param a integer Alpha value
--- @return nil
function SetColor(overlayType, r, g, b, a)
    GFC.preferences.colors[overlayType] = {
        r = r,
        g = g,
        b = b,
        a = a,
    }
    GFC.SetSkillColorOverlay('default')
end

--- Get color values for the given overlay type
--- @param overlayType string The overlay type to get color values for
--- @return integer r, integer g, integer b, integer a
function GetColor(overlayType)
    return GFC.preferences.colors[overlayType].r,
        GFC.preferences.colors[overlayType].g,
        GFC.preferences.colors[overlayType].b,
        GFC.preferences.colors[overlayType].a
end

--- Set if the display should fade when inactive
--- @param value boolean True to enable skill fade
--- @return nil
function SetFade(value)
    -- Note: To avoid having to change alpha every time,
    -- even if we never wanted to fade in the first place,
    -- turning OFF the option must first SetSkillFade(false)
    -- before setting preferences.fadeInactive to false.
    -- Otherwise we may get stuck in a faded state.
    GFC.SetSkillFade(value)
    GFC.preferences.fadeInactive = value
end

--- Get the fadeInactive value
--- @return boolean fadeInactive True to fade when inactive
function GetFade()
    return GFC.preferences.fadeInactive
end

--- Set the amount to fade when inactive
--- @param value integer Amount to fade
--- @return nil
function SetFadeAmount(value)
    GFC.preferences.fadeAmount = value
    GFC.SetSkillFade()
end

--- Get the amount to fade when inactive
--- @return integer value Amount to fade
function GetFadeAmount()
    return GFC.preferences.fadeAmount
end

--- Set if the display should be locked to reticle
--- @param value boolean True to lock to reticle
--- @return nil
local function setLockReticle(value)
    GFC:LockToReticle(value)
end

--- Get the lock to reticle setting
--- @return boolean value True to lock to reticle
local function getLockReticle()
    return GFC.preferences.lockedToReticle
end

local optionsTable = {
    {
        type = "header",
        name = "Positioning",
        width = "full",
    },
    {
        type = "button",
        name = function() if GFC.preferences.unlocked then return "Lock" else return "Unlock" end end,
        tooltip = "Toggle lock/unlock state of counter display for repositioning.",
        func = ToggleLocked,
        width = "half",
    },
    {
        type = "button",
        name = function() if GFC.ForceShow then return "Hide" else return "Show" end end,
        tooltip = "Force show for position or previewing display settings.",
        func = ForceShow,
        width = "half",
    },
    {
        type = "checkbox",
        name = "Lock to Reticle",
        tooltip =
        "Snap display of counter to center of reticle. Some display options may appear better than others positioned this way.",
        getFunc = getLockReticle,
        setFunc = setLockReticle,
        width = "full",
    },
    {
        type = "header",
        name = "Style",
        width = "full",
    },
    {
        type = "checkbox",
        name = "Hide Out of Combat",
        tooltip = "Hide the display when out of combat.",
        getFunc = getHideOutOfCombat,
        setFunc = setHideOutOfCombat,
        width = "full",
    },
    {
        type = "iconpicker",
        name = "Counter Style",
        choices = {
            "GrimFocusCounter/art/textures/Picker-ColorSquares.dds",
            "GrimFocusCounter/art/textures/Picker-Doom.dds",
            "GrimFocusCounter/art/textures/Picker-HorizontalDots.dds",
            "GrimFocusCounter/art/textures/Picker-FilledDots.dds",
            "GrimFocusCounter/art/textures/Picker-Numbers.dds",
            "GrimFocusCounter/art/textures/Picker-NumbersThickStroke.dds",
            "GrimFocusCounter/art/textures/Picker-Dice.dds",
            "GrimFocusCounter/art/textures/Picker-PlayMagsorc.dds",
            "GrimFocusCounter/art/textures/Picker-CH01_red.dds",
            "GrimFocusCounter/art/textures/Picker-CH01_BW.dds",
        },
        getFunc = GetTexture,
        setFunc = SetTexture,
        tooltip = "Style of counter display.",
        choicesTooltips = {
            "Color Squares",
            "DOOM",
            "Horizontal Dots",
            "Filled Dots",
            "Numbers",
            "Numbers (Thick Stroke)",
            "Dice",
            "Play Magsorc",
            "Red Compass (by Porkjet)",
            "Mono Compass (by Porkjet)",
        },
        maxColumns = 3,
        visibleRows = 2.5,
        iconSize = 64,
        width = "full",
    },
    {
        type = "slider",
        name = "Display Size",
        tooltip = "Display size of counter.",
        min = 0,
        max = 500,
        step = 5,
        getFunc = GetSize,
        setFunc = SetSize,
        width = "full",
        default = 40,
    },
    {
        type = "checkbox",
        name = "Show Zero Stacks",
        tooltip = "Show when skill is active but no stacks tracked.",
        getFunc = GetZeroStacks,
        setFunc = SetZeroStacks,
        width = "full",
    },
    {
        type = "description",
        text = "Not all display styles include indicators for zero stacks.",
        width = "full",
    },
    {
        type = "header",
        name = "Advanced Options",
        width = "full",
    },
    {
        type = "checkbox",
        name = "Fade on Skill Inactive",
        tooltip = "Lower opacity when stacks exist and in combat, but buff has expired.",
        getFunc = GetFade,
        setFunc = SetFade,
        width = "full",
    },
    {
        type = "slider",
        name = "Fade Amount",
        tooltip = "Opacity of inactive skill with counted stacks",
        min = 0,
        max = 100,
        disabled = function() return not GetFade() end,
        getFunc = GetFadeAmount,
        setFunc = SetFadeAmount,
        width = "full",
        default = 90,
    },
    {
        type = "checkbox",
        name = "Color Overlay: Default",
        tooltip = "Overlay the indicator with a color. Works better on some textures than others.",
        getFunc = function() return GetColorOverlay('default') end,
        setFunc = function(value) SetColorOverlay('default', value) end,
        width = "full",
    },
    {
        type = "colorpicker",
        disabled = function() return not GetColorOverlay('default') end,
        tooltip = "Color used for Color Overlay: Default",
        getFunc = function() return GetColor('default') end,
        setFunc = function(r, g, b, a) SetColor('default', r, g, b, a) end,
    },
    {
        type = "checkbox",
        name = "Color Overlay: Inactive",
        tooltip = "When skill is inactive, overlay the indicator with a color.",
        getFunc = function() return GetColorOverlay('inactive') end,
        setFunc = function(value) SetColorOverlay('inactive', value) end,
        width = "full",
    },
    {
        type = "colorpicker",
        disabled = function() return not GetColorOverlay('inactive') end,
        tooltip = "Color used for Color Overlay: Inactive",
        getFunc = function() return GetColor('inactive') end,
        setFunc = function(r, g, b, a) SetColor('inactive', r, g, b, a) end,
    },
    {
        type = "checkbox",
        name = "Color Overlay: 4 Stacks",
        tooltip = "Differentiate the significance of 4 stacks to prepare to fire bow proc.",
        getFunc = function() return GetColorOverlay('four') end,
        setFunc = function(value) SetColorOverlay('four', value) end,
        width = "full",
    },
    {
        type = "colorpicker",
        disabled = function() return not GetColorOverlay('four') end,
        tooltip = "Color used for Color Overlay: Proc",
        getFunc = function() return GetColor('four') end,
        setFunc = function(r, g, b, a) SetColor('four', r, g, b, a) end,
    },
    {
        type = "checkbox",
        name = "Color Overlay: Proc",
        tooltip = "When a proc is active and spectral bow is ready to be fired, overlay the indicator with a color.",
        getFunc = function() return GetColorOverlay('proc') end,
        setFunc = function(value) SetColorOverlay('proc', value) end,
        width = "full",
    },
    {
        type = "colorpicker",
        disabled = function() return not GetColorOverlay('proc') end,
        tooltip = "Color used for Color Overlay: Proc",
        getFunc = function() return GetColor('proc') end,
        setFunc = function(r, g, b, a) SetColor('proc', r, g, b, a) end,
    },
    {
        type = "submenu",
        name = "Acknowledgements",
        controls = {
            [1] = {
                type = "description",
                text = "|cBCBCBC|u0:40::Porkjet|u|rCreator of Red Compass and Mono Compass textures",
                width = "full",
            },
            [2] = {
                type = "description",
                text = "|cBCBCBC|u0:40::aquamantom|u|rHomeowner of primary facility for testing, parsing and AFKing",
                width = "full",
            },
            [3] = {
                type = "description",
                text = "|cBCBCBC|u0:40::Vierron|u|rAdditional blind-people perspective, testing and input",
                width = "full",
            },
            [4] = {
                type = "description",
                text =
                "|cBCBCBC|u0:40::meanmegan|u|rMy amazing wife and baby's mama who, through her support by allowing me to spend far too much time in-game, has made Grim Focus Counter possible -- send all your gold and goodies to her!",
                width = "full",
            },
        },
    },
}

--- Initialize settings
--- @return nil
function GFC:InitSettings()
    LAM:RegisterAddonPanel(self.name, panelData)
    LAM:RegisterOptionControls(self.name, optionsTable)

    self:Trace(2, "Finished InitSettings()")
end

--- Upgrade settings
--- @return nil
function GFC:UpgradeSettings()
    -- Check if we've already upgraded
    if self.preferences.colorOverlay == nil and self.preferences.color == nil then return end

    -- Copy default color overlay to new savedvar
    self.preferences.overlay.default = self.preferences.colorOverlay
    self.preferences.colors.default = self.preferences.color

    -- Clear old, indicate upgraded
    self.preferences.colorOverlay = nil
    self.preferences.color = nil
end
