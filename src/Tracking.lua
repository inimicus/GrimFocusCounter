-- -----------------------------------------------------------------------------
-- Grim Focus Counter
-- Author:  g4rr3t
-- Created: Jan 28, 2018
--
-- Tracking.lua
-- -----------------------------------------------------------------------------

local currentStack = 0

function GFC.RegisterEvents()

    -- Events for each skill morph
    -- Separate namespaces for each are required as
    -- duplicate filters against the same namespace
    -- overwrite the previously set filter.
    --
    -- These filter the EVENT_EFFECT_CHANGED event to
    -- hit the callback *only* when these specific
    -- ability IDs change and avoid the need to conditionally
    -- exclude all skills we are not interested in.

    for morph, morphTable in pairs(GFC.ABILITIES) do
        GFC:Trace(2, "Registering: " .. morph)
        for abilityType, abilityId in pairs(morphTable) do
            local name = "GFC_" .. morph .. "_" .. abilityType
            GFC:Trace(3, "Registering: " .. name .. " (" .. abilityId .. ")")

            EVENT_MANAGER:RegisterForEvent(name, EVENT_EFFECT_CHANGED, function(...) GFC.OnEffectChanged(...) end)
            EVENT_MANAGER:AddFilterForEvent(name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId)
            EVENT_MANAGER:AddFilterForEvent(name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
        end
    end
end

function GFC.UnregisterEvents()
    for morph, morphTable in pairs(GFC.ABILITIES) do
        for abilityType, abilityId in pairs(morphTable) do
            local name = "GFC_" .. morph .. "_" .. abilityType
            GFC:Trace(3, "Unregistering: " .. name .. " (" .. abilityId .. ")")
            EVENT_MANAGER:UnregisterForEvent(name, EVENT_EFFECT_CHANGED)
        end
    end
end

function GFC.RegisterUnfilteredEvents()
    EVENT_MANAGER:RegisterForEvent(GFC.name, EVENT_EFFECT_CHANGED, function(...) GFC.OnEffectChanged(...) end)
    GFC:Trace(3, "Registering unfiltered complete")
end

function GFC.UnregisterUnfilteredEvents()
    EVENT_MANAGER:UnregisterForEvent(GFC.name, EVENT_EFFECT_CHANGED)
    GFC:Trace(3, "Unregistering unfiltered complete")
end

function GFC.OnEffectChanged(eventCode, changeType, effectSlot, effectName,
        unitTag, startTimeSec, endTimeSec, stackCount, iconName, buffType,
        effectType, abilityType, statusEffectType, unitName, unitId,
        effectAbilityId)

    GFC:Trace(3, effectAbilityId)

    -- Exclude abilities from group members
    if unitTag and string.find(unitTag, 'group') then return end

    -- If we have a stack
    if stackCount > 0 then
        GFC:Trace(2, "Stack for Ability ID: " .. effectAbilityId)
        if changeType == EFFECT_RESULT_FADED then
            currentStack = 0
            GFC.UpdateStacks(currentStack)
            GFC:Trace(2, "Faded on stack #"..stackCount)
        else
            currentStack = stackCount
            GFC.UpdateStacks(currentStack)
            GFC:Trace(1, "Stack #"..stackCount)
        end
        return
    end

    -- Not a stack
    if changeType == EFFECT_RESULT_GAINED then
        GFC:Trace(2, "Skill Activated: " ..  effectAbilityId)
        GFC.abilityActive = true
        GFC.SetSkillFade(false)
        GFC.UpdateStacks(currentStack)
        return
    end

    if changeType == EFFECT_RESULT_FADED then
        GFC:Trace(2, "Skill Inactive: " ..  effectAbilityId)
        GFC.abilityActive = false
        GFC.SetSkillFade(true)
        GFC.UpdateStacks(currentStack)
        return
    end

end
