-- -----------------------------------------------------------------------------
-- Grim Focus Counter
-- Author:  g4rr3t
-- Created: Jan 28, 2018
--
-- Tracking.lua
-- -----------------------------------------------------------------------------

function GFC.OnStackChanged(eventCode, changeType, effectSlot, effectName,
        unitTag, startTimeSec, endTimeSec, stackCount, iconName, buffType,
        effectType, abilityType, statusEffectType, unitName, unitId,
        effectAbilityId)

    GFC:Trace(3, effectAbilityId)

    -- Exclude abilities from group members
    if unitTag and string.find(unitTag, 'group') then return end

    -- If we have a stack
    if stackCount > 0 then
        GFC:Trace(3, "Stack for " .. effectAbilityId)
        if changeType == EFFECT_RESULT_FADED then
            GFC.UpdateStacks(0)
            GFC:Trace(2, "Faded on stack #"..stackCount)
        else
            GFC.UpdateStacks(stackCount)
            GFC:Trace(2, "Stack #"..stackCount)
        end
        return
    end

end

function GFC.OnEffectChanged(eventCode, changeType, effectSlot, effectName,
        unitTag, startTimeSec, endTimeSec, stackCount, iconName, buffType,
        effectType, abilityType, statusEffectType, unitName, unitId,
        effectAbilityId)

    GFC:Trace(3, effectAbilityId)

    -- Exclude abilities from group members
    if unitTag and string.find(unitTag, 'group') then return end

    -- Not a stack
    if changeType == EFFECT_RESULT_GAINED then
        GFC:Trace(2, "Gained: " ..  effectAbilityId)
        GFC.abilityActive = true
        GFC.UpdateStacks(0)
        return
    end

    if changeType == EFFECT_RESULT_FADED then
        GFC:Trace(2, "Faded: " ..  effectAbilityId)
        GFC.abilityActive = false
        GFC.UpdateStacks(0)
        return
    end

end
