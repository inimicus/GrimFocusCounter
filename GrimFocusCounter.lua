GrimFocusCounter = {}

local addon = GrimFocusCounter
addon.name = "GrimFocusCounter"
addon.grim = "GrimFocusCounterRelentless"
addon.relentless = "GrimFocusCounterRelentless"
addon.merciless = "GrimFocusCounterMerciless"

-- ------------------------------
-- Level of debug output
-- 1: Low - Basic debug info, make sure addon works
-- 2: Medium - More information about skills and addon functionality
-- 3: High - Everything
local debugMode = 3
-- ------------------------------

local function Trace(debugLevel, ...)
	if debugLevel <= debugMode then
		d(...)
	end
end

-- ------------------------------
-- Base Skill IDs:
-- Grim Focus				62096
-- Merciless Resolve		62117
-- Relentless Focus			62108
-- ------------------------------

local ABILITIES = {
	GRIM_FOCUS			= 62097,	-- Unmorphed
	MERCILESS_RESOLVE	= 62118,	-- Magicka Morph
	RELENTLESS_FOCUS	= 62110,	-- Stamina Morph
}

function addon:Initialize()
	Trace(1, "GFC Loaded")
end

function addon.OnLoaded(event, addonName)
  if addonName == addon.name then
    addon:Initialize()
  end
end

function addon:OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag,
		startTimeSec, endTimeSec, stackCount, iconName, buffType, effectType, abilityType, 
		statusEffectType, unitName, unitId, effectAbilityId)

	Trace(3, effectAbilityId)

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

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, addon.OnLoaded)

EVENT_MANAGER:RegisterForEvent(addon.merciless, EVENT_EFFECT_CHANGED, function(...) addon:OnEffectChanged(...) end)
EVENT_MANAGER:AddFilterForEvent(addon.merciless, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, ABILITIES.MERCILESS_RESOLE)
EVENT_MANAGER:AddFilterForEvent(addon.merciless, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

EVENT_MANAGER:RegisterForEvent(addon.relentless, EVENT_EFFECT_CHANGED, function(...) addon:OnEffectChanged(...) end)
EVENT_MANAGER:AddFilterForEvent(addon.relentless, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, ABILITIES.GRIM_FOCUS)
EVENT_MANAGER:AddFilterForEvent(addon.relentless, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

EVENT_MANAGER:RegisterForEvent(addon.grim, EVENT_EFFECT_CHANGED, function(...) addon:OnEffectChanged(...) end)
EVENT_MANAGER:AddFilterForEvent(addon.grim, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, ABILITIES.GRIM_FOCUS)
EVENT_MANAGER:AddFilterForEvent(addon.grim, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)