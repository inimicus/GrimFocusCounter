-- -----------------------------------------------------------------------------
-- Grim Focus Counter
-- Author:  g4rr3t
-- Created: Dec 20, 2017
--
-- Track stacks of Grim Focus and its morphs and display 
-- the stacks in a very visual and obvious way.
-- -----------------------------------------------------------------------------
GrimFocusCounter = {}

-- -----------------------------------------------------------------------------
-- Level of debug output
-- 1: Low - Basic debug info, show core functionality
-- 2: Medium - More information about skills and addon details
-- 3: High - Everything
local debugMode = 0
-- -----------------------------------------------------------------------------

local addon = GrimFocusCounter
addon.name	= "GrimFocusCounter"

-- Create separate namespaces for each morph
addon.grim			= "GrimFocusCounterGrim"
addon.relentless	= "GrimFocusCounterRelentless"
addon.merciless		= "GrimFocusCounterMerciless"

-- -----------------------------------------------------------------------------
-- Base Skill IDs:
-- Grim Focus			62096
-- Merciless Resolve	62117
-- Relentless Focus		62110
-- -----------------------------------------------------------------------------
local ABILITIES = {
	GRIM_FOCUS			= 62097,	-- Unmorphed
	MERCILESS_RESOLVE	= 62118,	-- Magicka Morph
	RELENTLESS_FOCUS	= 62108,	-- Stamina Morph
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

	local left	= self.preferences.positionLeft
	local top	= self.preferences.positionTop

	self:SetPosition(left, top)
end

function addon:OnLoaded(event, addonName)
	if addonName == addon.name then
		addon:Initialize()
	end
end

-- -----------------------------------------------------------------------------
-- Stack Tracking
-- -----------------------------------------------------------------------------

function addon:OnEffectChanged(eventCode, changeType, effectSlot, effectName, 
		unitTag, startTimeSec, endTimeSec, stackCount, iconName, buffType, 
		effectType, abilityType, statusEffectType, unitName, unitId, 
		effectAbilityId)

	Trace(3, effectAbilityId)

	-- Exclude abilities from group members
	if unitTag and string.find(unitTag, 'group') then return end

    if stackCount > 0 then
		Trace(3, "Stack for "..effectAbilityId)
        if changeType == EFFECT_RESULT_FADED then
			GrimFocusCounterIndicatorLabel:SetText("")
			Trace(2, "Faded on stack #"..stackCount)
        else
			local displayText = ""

			for i = 1, stackCount, 1
			do
				displayText = displayText .. "*"
			end

			GrimFocusCounterIndicatorLabel:SetText(displayText)
			Trace(1, "Stack #"..stackCount)
        end
        return
    end

end

-- -----------------------------------------------------------------------------
-- User Interface
-- -----------------------------------------------------------------------------

function addon:OnMoveStop()
	Trace(1, "Moved")
	addon:SavePosition()
end

function addon:SavePosition()
	local left	= GrimFocusCounterIndicator:GetLeft()
	local top	= GrimFocusCounterIndicator:GetTop()

	Trace(2, "Saving - Left: "..left.." Top: "..top)

	self.preferences.positionLeft = left
	self.preferences.positionTop = top
end

function addon:SetPosition(left, top)
	Trace(2, "Setting - Left: "..left.." Top: "..top)
	GrimFocusCounterIndicator:ClearAnchors()
	GrimFocusCounterIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

-- -----------------------------------------------------------------------------
-- Event Hooks
-- -----------------------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, function(...) addon:OnLoaded(...) end)

-- Events for each skill morph
-- Separate namespaces for each are required as 
-- duplicate filters against the same namespace
-- overwrite the previously set filter.
--
-- These filter the EVENT_EFFECT_CHANGED event to
-- hit the callback *only* when the three specific 
-- ability IDs change and avoid the need to conditionally 
-- exclude all skills we are not interested in.

EVENT_MANAGER:RegisterForEvent(addon.merciless, EVENT_EFFECT_CHANGED, function(...) addon:OnEffectChanged(...) end)
EVENT_MANAGER:AddFilterForEvent(addon.merciless, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, ABILITIES.MERCILESS_RESOLVE)
EVENT_MANAGER:AddFilterForEvent(addon.merciless, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

EVENT_MANAGER:RegisterForEvent(addon.relentless, EVENT_EFFECT_CHANGED, function(...) addon:OnEffectChanged(...) end)
EVENT_MANAGER:AddFilterForEvent(addon.relentless, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, ABILITIES.RELENTLESS_FOCUS)
EVENT_MANAGER:AddFilterForEvent(addon.relentless, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

EVENT_MANAGER:RegisterForEvent(addon.grim, EVENT_EFFECT_CHANGED, function(...) addon:OnEffectChanged(...) end)
EVENT_MANAGER:AddFilterForEvent(addon.grim, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, ABILITIES.GRIM_FOCUS)
EVENT_MANAGER:AddFilterForEvent(addon.grim, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)