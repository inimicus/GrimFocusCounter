-- -----------------------------------------------------------------------------
-- Grim Focus Counter
-- Author:  g4rr3t
-- Created: Dec 20, 2017
--
-- Track stacks of Grim Focus and its morphs and display
-- the stacks in a very visual and obvious way.
-- -----------------------------------------------------------------------------
GrimFocusCounter = {}
local addon = GrimFocusCounter
addon.name  = "GrimFocusCounter"

-- Create separate namespaces for each morph
addon.grim          = "GrimFocusCounterBase"
addon.relentless    = "GrimFocusCounterRelentless"
addon.merciless     = "GrimFocusCounterMerciless"
addon.grimSkill     	= "GrimFocusCounterBaseSkill"
addon.relentlessSkill   = "GrimFocusCounterRelentlessSkill"
addon.mercilessSkill    = "GrimFocusCounterMercilessSkill"


-- -----------------------------------------------------------------------------
-- Level of debug output
-- 1: Low - Basic debug info, show core functionality
-- 2: Medium - More information about skills and addon details
-- 3: High - Everything
local debugMode = 0
-- -----------------------------------------------------------------------------

local ABILITIES = {
    GRIM_FOCUS          = { STACK = 62097, BASE = 62096 },
    MERCILESS_RESOLVE   = { STACK = 62118, BASE = 62117 },
    RELENTLESS_FOCUS    = { STACK = 62108, BASE = 62110 },
}

local TEXTURE_SIZE = {
    DISPLAY_WIDTH   = 40,   -- Default width
    DISPLAY_HEIGHT  = 40,   -- Default height
    FRAME_HEIGHT    = 128,  -- Height of each texture frame
    FRAME_WIDTH     = 128,  -- Width of each texture frame
    ASSET_WIDTH     = 1024, -- Overall texture width
    ASSET_HEIGHT    = 128,  -- Overall texture height
}

local TEXTURE_VARIANTS = {
    COLOR_SQUARES       = "GrimFocusCounter/assets/ColorSquares.dds",
    DOOM                = "GrimFocusCounter/assets/Doom.dds",
    HORIZONTAL_DOTS     = "GrimFocusCounter/assets/HorizontalDots.dds",
}

local TEXTURE_FRAMES = {
    [0] = { ABS = 0,    REL = 0.0 },	-- No stacks
    [1] = { ABS = 128,  REL = 0.125 },	-- Stack #1
    [2] = { ABS = 256,  REL = 0.25 },	-- Stack #2
    [3] = { ABS = 384,  REL = 0.375 }, 	-- Stack #3
    [4] = { ABS = 512,  REL = 0.5 },	-- Stack #4
    [5] = { ABS = 640,  REL = 0.625 },	-- Stack #5
    [6] = { ABS = 768,  REL = 0.75 },	-- Empty stack indicator
    [7] = { ABS = 896,  REL = 0.875 },	-- Skill active indicator
    [8] = { ABS = 1024, REL = 1.0 },	-- End of texture
}

local function Trace(debugLevel, ...)
    if debugLevel <= debugMode then
        d(...)
    end
end

-- -----------------------------------------------------------------------------
-- Startup
-- -----------------------------------------------------------------------------

function addon:Initialize()
    Trace(1, "GFC Loaded")
    self.preferences = ZO_SavedVars:NewAccountWide("GrimFocusCounterVariables", 1, nil, {})
	self.preferences.showEmptyStacks = true
	self.preferences.selectedTexture = TEXTURE_VARIANTS.HORIZONTAL_DOTS
    self:DrawUI()

	-- Events for each skill morph
	-- Separate namespaces for each are required as
	-- duplicate filters against the same namespace
	-- overwrite the previously set filter.
	--
	-- These filter the EVENT_EFFECT_CHANGED event to
	-- hit the callback *only* when the three specific
	-- ability IDs change and avoid the need to conditionally
	-- exclude all skills we are not interested in.

	EVENT_MANAGER:RegisterForEvent(addon.merciless, EVENT_EFFECT_CHANGED, function(...) addon:OnStackChanged(...) end)
	EVENT_MANAGER:AddFilterForEvent(addon.merciless, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, ABILITIES.MERCILESS_RESOLVE.STACK)
	EVENT_MANAGER:AddFilterForEvent(addon.merciless, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

	EVENT_MANAGER:RegisterForEvent(addon.relentless, EVENT_EFFECT_CHANGED, function(...) addon:OnStackChanged(...) end)
	EVENT_MANAGER:AddFilterForEvent(addon.relentless, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, ABILITIES.RELENTLESS_FOCUS.STACK)
	EVENT_MANAGER:AddFilterForEvent(addon.relentless, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

	EVENT_MANAGER:RegisterForEvent(addon.grim, EVENT_EFFECT_CHANGED, function(...) addon:OnStackChanged(...) end)
	EVENT_MANAGER:AddFilterForEvent(addon.grim, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, ABILITIES.GRIM_FOCUS.STACK)
	EVENT_MANAGER:AddFilterForEvent(addon.grim, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

	if self.preferences.showEmptyStacks then
		EVENT_MANAGER:RegisterForEvent(addon.mercilessSkill, EVENT_EFFECT_CHANGED, function(...) addon:OnEffectChanged(...) end)
		EVENT_MANAGER:AddFilterForEvent(addon.mercilessSkill, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, ABILITIES.MERCILESS_RESOLVE.BASE)
		EVENT_MANAGER:AddFilterForEvent(addon.mercilessSkill, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

		EVENT_MANAGER:RegisterForEvent(addon.relentlessSkill, EVENT_EFFECT_CHANGED, function(...) addon:OnEffectChanged(...) end)
		EVENT_MANAGER:AddFilterForEvent(addon.relentlessSkill, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, ABILITIES.RELENTLESS_FOCUS.BASE)
		EVENT_MANAGER:AddFilterForEvent(addon.relentlessSkill, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

		EVENT_MANAGER:RegisterForEvent(addon.grimSkill, EVENT_EFFECT_CHANGED, function(...) addon:OnEffectChanged(...) end)
		EVENT_MANAGER:AddFilterForEvent(addon.grimSkill, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, ABILITIES.GRIM_FOCUS.BASE)
		EVENT_MANAGER:AddFilterForEvent(addon.grimSkill, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
	end

end

function addon:OnLoaded(event, addonName)
    if addonName ~= addon.name then return end
	self:Initialize()
end

-- -----------------------------------------------------------------------------
-- Skill Tracking
-- -----------------------------------------------------------------------------

function addon:OnStackChanged(eventCode, changeType, effectSlot, effectName,
        unitTag, startTimeSec, endTimeSec, stackCount, iconName, buffType,
        effectType, abilityType, statusEffectType, unitName, unitId,
        effectAbilityId)

    Trace(3, effectAbilityId)

    -- Exclude abilities from group members
    if unitTag and string.find(unitTag, 'group') then return end

	-- If we have a stack
    if stackCount > 0 then
        Trace(3, "Stack for " .. effectAbilityId)
		if changeType == EFFECT_RESULT_FADED then
			self:UpdateStacks(0)
			Trace(2, "Faded on stack #"..stackCount)
		else
			self:UpdateStacks(stackCount)
			Trace(2, "Stack #"..stackCount)
		end
        return
    end

end

function addon:OnEffectChanged(eventCode, changeType, effectSlot, effectName,
        unitTag, startTimeSec, endTimeSec, stackCount, iconName, buffType,
        effectType, abilityType, statusEffectType, unitName, unitId,
        effectAbilityId)

    Trace(3, effectAbilityId)

    -- Exclude abilities from group members
    if unitTag and string.find(unitTag, 'group') then return end

	-- Not a stack
    if changeType == EFFECT_RESULT_GAINED then
		Trace(2, "Gained: " ..  effectAbilityId)
		self.abilityActive = true
		self:UpdateStacks(0)
        return
    end

    if changeType == EFFECT_RESULT_FADED then
		Trace(2, "Faded: " ..  effectAbilityId)
		self.abilityActive = false
		self:UpdateStacks(0)
        return
    end

end

-- -----------------------------------------------------------------------------
-- User Interface
-- -----------------------------------------------------------------------------

function addon:DrawUI()
    local left  = self.preferences.positionLeft
    local top   = self.preferences.positionTop

    local width = self.preferences.width
    local height = self.preferences.height

	if not width then
		width = TEXTURE_SIZE.DISPLAY_WIDTH
	end

	if not height then
		height = TEXTURE_SIZE.DISPLAY_HEIGHT
	end

    local c = WINDOW_MANAGER:CreateTopLevelWindow("GFCContainer")
	c:SetClampedToScreen(true)
    c:SetDimensions(width, height)
    c:ClearAnchors()
    c:SetMouseEnabled(true)
    c:SetAlpha(1)
    c:SetMovable(true)
    c:SetHidden(false)
	c:SetHandler("OnMoveStop", function(...) self:SavePosition() end)

	local t = WINDOW_MANAGER:CreateControl("GFCTexture", c, CT_TEXTURE)
	t:SetTexture(self.preferences.selectedTexture)
	t:SetDimensions(TEXTURE_SIZE.DISPLAY_WIDTH, TEXTURE_SIZE.DISPLAY_HEIGHT)
    t:SetTextureCoords(TEXTURE_FRAMES[0].REL, TEXTURE_FRAMES[1].REL, 0, 1)
	t:SetAnchor(TOPLEFT, c, TOPLEFT, 0, 0)

	self.GFCContainer = c
	self.GFCTexture = t

    self:SetPosition(left, top)
end

function addon:OnMoveStop()
    Trace(1, "Moved")
    addon:SavePosition()
end

function addon:SavePosition()
    local left = self.GFCContainer:GetLeft()
    local top  = self.GFCContainer:GetTop()

    Trace(2, "Saving - Left: "..left.." Top: "..top)

    self.preferences.positionLeft = left
    self.preferences.positionTop  = top
end

function addon:SetPosition(left, top)
    Trace(2, "Setting - Left: "..left.." Top: "..top)
    self.GFCContainer:ClearAnchors()
    self.GFCContainer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function addon:UpdateStacks(stackCount)

	-- Ignore missing stackCount
	if not stackCount then return end

	if stackCount == 0 and self.preferences.showEmptyStacks then
		
		if self.abilityActive then
			-- Show zero stack indicator
			Trace(1, "Stack #0, Show Empty, Active Skill")
			self.GFCTexture:SetTextureCoords(TEXTURE_FRAMES[6].REL, TEXTURE_FRAMES[7].REL, 0, 1)
		else
			-- Hide stack indicator
			Trace(1, "Stack #0, Show Empty, Inactive Skill")
			self.GFCTexture:SetTextureCoords(TEXTURE_FRAMES[0].REL, TEXTURE_FRAMES[1].REL, 0, 1)
		end

	else
		Trace(1, "Stack #" .. stackCount)
		self.GFCTexture:SetTextureCoords(TEXTURE_FRAMES[stackCount].REL, TEXTURE_FRAMES[stackCount+1].REL, 0, 1)
	end

end

-- -----------------------------------------------------------------------------
-- Event Hooks
-- -----------------------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, function(...) addon:OnLoaded(...) end)

