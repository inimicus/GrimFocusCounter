-- -----------------------------------------------------------------------------
-- Grim Focus Counter
-- Author:  g4rr3t
-- Created: Jan 28, 2018
--
-- Tracking.lua
-- -----------------------------------------------------------------------------

local GFC = GFC
local concat = table.concat
local EM = EVENT_MANAGER

GFC.currentStacks = 0
GFC.abilityActive = false
GFC.isInCombat = false

local function getEventNamespace(event, morph, type)
    return concat({ GFC.name, event, morph, type }, "_")
end

function GFC:RegisterEvents()
    -- Events for each skill morph
    -- Separate namespaces for each are required as
    -- duplicate filters against the same namespace
    -- overwrite the previously set filter.
    --
    -- These filter the EVENT_EFFECT_CHANGED event to
    -- hit the callback *only* when these specific
    -- ability IDs change and avoid the need to conditionally
    -- exclude all skills we are not interested in.

    for morph, data in pairs(self.ABILITIES) do
        self:Trace(2, "Registering: " .. morph)

        local skillEffect = getEventNamespace("SkillChanged", morph, "Skill")
        local stackEffect = getEventNamespace("EffectChanged", morph, "Stack")

        EM:RegisterForEvent(skillEffect, EVENT_EFFECT_CHANGED, self.OnSkillChanged)
        EM:AddFilterForEvent(skillEffect, EVENT_EFFECT_CHANGED,
            REGISTER_FILTER_ABILITY_ID, data.Skill,
            REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER
        )

        EM:RegisterForEvent(stackEffect, EVENT_EFFECT_CHANGED, self.OnEffectChanged)
        EM:AddFilterForEvent(stackEffect, EVENT_EFFECT_CHANGED,
            REGISTER_FILTER_ABILITY_ID, data.Stack,
            REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER
        )
    end

    -- Combat enter/exit events
    if self.preferences.hideOutOfCombat then
        self:RegisterCombatEvent()
    end

    -- Zone change or load
    EM:RegisterForEvent(self.name .. "PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED, self.OnPlayerChanged)
    EM:RegisterForEvent(self.name .. "ZONE_UPDATE", EVENT_ZONE_UPDATE, self.OnPlayerChanged)

    -- Dead or alive
    EM:RegisterForEvent(self.name .. "PlayerDead", EVENT_PLAYER_DEAD, self.OnPlayerChanged)
    EM:RegisterForEvent(self.name .. "PlayerAlive", EVENT_PLAYER_ALIVE, self.OnPlayerChanged)
end

function GFC:RegisterCombatEvent()
    -- Register start/end combat events
    EM:RegisterForEvent(self.name .. "COMBAT_STATE", EVENT_PLAYER_COMBAT_STATE, self.OnPlayerChanged)
end

function GFC:UnregisterCombatEvent()
    -- Register start/end combat events
    EM:UnregisterForEvent(self.name .. "COMBAT_STATE", EVENT_PLAYER_COMBAT_STATE)
end

function GFC:UnregisterEvents()
    for morph in pairs(self.ABILITIES) do
        self:Trace(2, "Unregistering: " .. morph)

        local skillEffect = getEventNamespace("SkillChanged", morph, "Skill")
        local stackEffect = getEventNamespace("EffectChanged", morph, "Stack")

        EM:UnregisterForEvent(skillEffect, EVENT_EFFECT_CHANGED)
        EM:UnregisterForEvent(stackEffect, EVENT_EFFECT_CHANGED)
    end

    GFC:UnregisterCombatEvent()
    EM:UnregisterForEvent(self.name .. "PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED)
    EM:UnregisterForEvent(self.name .. "ZONE_UPDATE", EVENT_ZONE_UPDATE)
    EM:UnregisterForEvent(self.name .. "PlayerDead", EVENT_PLAYER_DEAD)
    EM:UnregisterForEvent(self.name .. "PlayerAlive", EVENT_PLAYER_ALIVE)
end

function GFC.RegisterUnfilteredEvents()
    EM:RegisterForEvent(GFC.name .. "UNFILTERED", EVENT_EFFECT_CHANGED, GFC.OnEffectChanged)
    GFC:Trace(3, "Registering unfiltered complete")
end

function GFC.UnregisterUnfilteredEvents()
    EM:UnregisterForEvent(GFC.name .. "UNFILTERED", EVENT_EFFECT_CHANGED)
    GFC:Trace(3, "Unregistering unfiltered complete")
end

function GFC:SetInCombat(inCombat)
    self.isInCombat = inCombat
    self:Trace(2, "In Combat: <<1>>", inCombat)

    if not self.preferences.hideOutOfCombat then return end

    if inCombat then
        self:AddSceneFragments()
    else
        self:RemoveSceneFragments()
    end
end

function GFC.OnPlayerChanged()
    GFC:SetInCombat(IsUnitInCombat("player"))

    local buffOrSkillFound = false

    for i = 1, GetNumBuffs("player") do
        local _, _, _, _, stackCount, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        for morph, morphTable in pairs(GFC.ABILITIES) do
            GFC:Trace(3, "Checking for morph <<1>>", morph)
            if morphTable.Stack == abilityId then
                GFC:Trace(2, "Updating ability <<1>> with stacks <<2>>", abilityId, stackCount)
                GFC.currentStacks = stackCount
                buffOrSkillFound = true
            end

            if morphTable.Skill == abilityId then
                GFC:Trace(2, "Updating ability <<1>> active, showing UI", abilityId)
                GFC.abilityActive = true
                buffOrSkillFound = true
            end
        end
    end

    if not buffOrSkillFound then
        -- No buff found
        GFC.currentStacks = 0
        GFC.abilityActive = false
    end

    GFC:UpdateUI()
end

function GFC.OnSkillChanged(_, changeType, _, effectName, _, _, _, stackCount, _, _, _, _, _, _, _, effectAbilityId)
    GFC:Trace(3, "Skill changed: " .. effectName .. " (" .. effectAbilityId .. ")")

    -- NOTE: Can't trust stacks when effect gained/faded and is sometimes incorrect

    -- Not a stack
    if changeType == EFFECT_RESULT_GAINED then
        GFC:Trace(2,
            "Skill Activated: " .. effectName .. " (" .. effectAbilityId .. ") with " .. stackCount .. " stacks")
        GFC.abilityActive = true
    end

    if changeType == EFFECT_RESULT_FADED then
        GFC:Trace(2,
            "Skill Inactive: " .. effectName .. " (" .. effectAbilityId .. ") with " .. stackCount .. " stacks")
        GFC.abilityActive = false
    end

    GFC:UpdateUI()
end

function GFC.OnEffectChanged(_, changeType, _, effectName, _, _, _, stackCount, _, _, _, _, _, _, _, effectAbilityId)
    GFC:Trace(3, "Effect changed: " .. effectName .. " (" .. effectAbilityId .. ")")

    -- If we have a stack
    GFC:Trace(2, "Stack for Ability ID: " .. effectAbilityId)

    if stackCount == 5 and changeType == EFFECT_RESULT_FADED then
        GFC:Trace(2, "Used proc: " .. effectName .. " (" .. effectAbilityId .. ") with " .. stackCount .. " stacks")
        GFC.currentStacks = 0
    else
        GFC:Trace(1, "Stack #" .. GFC.currentStacks)
        GFC.currentStacks = stackCount
    end

    GFC:UpdateUI()
end
