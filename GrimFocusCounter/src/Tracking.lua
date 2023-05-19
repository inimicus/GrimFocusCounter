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

    -- Register start/end combat events
    EVENT_MANAGER:RegisterForEvent(name, EVENT_PLAYER_COMBAT_STATE, function(...) GFC.IsInCombat(...) end)
end

function GFC.UnregisterEvents()
    for morph, morphTable in pairs(GFC.ABILITIES) do
        for abilityType, abilityId in pairs(morphTable) do
            local name = "GFC_" .. morph .. "_" .. abilityType
            GFC:Trace(3, "Unregistering: " .. name .. " (" .. abilityId .. ")")
            EVENT_MANAGER:UnregisterForEvent(name, EVENT_EFFECT_CHANGED)
        end
    end

    EVENT_MANAGER:UnregisterForEvent(GFC.name .. "COMBAT_STATE", EVENT_PLAYER_COMBAT_STATE)
end

function GFC.RegisterUnfilteredEvents()
    EVENT_MANAGER:RegisterForEvent(GFC.name .. "COMBAT_STATE", EVENT_PLAYER_COMBAT_STATE, function(...) GFC.IsInCombat(...) end)
    EVENT_MANAGER:RegisterForEvent(GFC.name .. "UNFILTERED", EVENT_EFFECT_CHANGED, function(...) GFC.OnEffectChanged(...) end)
    GFC:Trace(3, "Registering unfiltered complete")
end

function GFC.UnregisterUnfilteredEvents()
    EVENT_MANAGER:UnregisterForEvent(GFC.name .. "COMBAT_STATE", EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent(GFC.name .. "UNFILTERED", EVENT_EFFECT_CHANGED)
    GFC:Trace(3, "Unregistering unfiltered complete")
end

function GFC.IsInCombat(_, inCombat)
    GFC.isInCombat = inCombat

    if inCombat then
        GFC:Trace(2, "Entered Combat")
    else
        GFC:Trace(2, "Left Combat")
        GFC.UpdateStacks(currentStack)
    end

end

function GFC.OnEffectChanged(_, changeType, _, effectName, unitTag, _, _,
        stackCount, _, _, _, _, _, _, _, effectAbilityId)

    GFC:Trace(3, effectName .. " (" .. effectAbilityId .. ")")

    -- If we have a stack
    if stackCount > 0 then
        GFC:Trace(2, "Stack for Ability ID: " .. effectAbilityId)

        GFC.SetSkillColorOverlay('default')

        if changeType == EFFECT_RESULT_FADED then
            currentStack = 0
            GFC:Trace(2, "Faded on stack #" .. stackCount)
            GFC.UpdateStacks(currentStack)
        else
            currentStack = stackCount
            GFC:Trace(1, "Stack #" .. currentStack)

            -- Update color for 4 stacks and optionally play a sound
            if currentStack == 4 then
                GFC.SetSkillColorOverlay('four')
            -- Update color for proc
            -- There would be a more "true" way to set this
            -- via a callback for the proc event gained,
            -- but this is more straight-forward than setting
            -- up another callback just for changing a color.
            elseif currentStack == 5 then
                GFC.SetSkillColorOverlay('proc')
            end

            GFC.UpdateStacks(currentStack)
        end

        return
    end

    -- Not a stack
    if changeType == EFFECT_RESULT_GAINED then
        GFC:Trace(2, "Skill Activated: " ..  effectName .. " (" .. effectAbilityId ..") with " .. currentStack .. " stacks")
        GFC.abilityActive = true
        GFC.SetSkillFade(false)

        if currentStack == 4 then
            GFC.SetSkillColorOverlay('four')
        elseif currentStack == 5 then
            GFC.SetSkillColorOverlay('proc')
        else
            GFC.SetSkillColorOverlay('default')
        end

        GFC.UpdateStacks(currentStack)
        return
    end

    if changeType == EFFECT_RESULT_FADED then
        GFC:Trace(2, "Skill Inactive: " ..  effectName .. " (" .. effectAbilityId ..") with " .. currentStack .. " stacks")
        GFC.abilityActive = false
        GFC.SetSkillFade(true)
        GFC.SetSkillColorOverlay('inactive')
        GFC.UpdateStacks(currentStack)
        return
    end

end
