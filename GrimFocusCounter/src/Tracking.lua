-- -----------------------------------------------------------------------------
-- Grim Focus Counter
-- Author:  g4rr3t
-- Created: Jan 28, 2018
--
-- Tracking.lua
-- -----------------------------------------------------------------------------

--- Workaround diagnostic errors due to type mismatch
--- @alias luaindex integer
--- @alias bool boolean

local GFC = GFC
local EM = EVENT_MANAGER

--- @type integer Current number of stacks
GFC.currentStacks = 0

--- @type boolean True when Grim Focus (or one of its morphs) is slotted
GFC.skillSlotted = false

--- @type boolean True when the player is in combat
GFC.isInCombat = false

--- Check action bars for slotted skill
--- @param abilityId integer Ability to check bars for
--- @return integer|nil slottedPosition Slot index of first found skill
local function getSlottedPosition(abilityId)
    local SKILL_BAR_FIRST_NORMAL_SLOT_INDEX = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1
    local SKILL_BAR_LAST_NORMAL_SLOT_INDEX = ACTION_BAR_ULTIMATE_SLOT_INDEX

    for x = SKILL_BAR_FIRST_NORMAL_SLOT_INDEX, SKILL_BAR_LAST_NORMAL_SLOT_INDEX do
        local slotPrimary = GetSlotBoundId(x, HOTBAR_CATEGORY_PRIMARY)
        if slotPrimary == abilityId then return x end

        local slotBackup = GetSlotBoundId(x, HOTBAR_CATEGORY_BACKUP)
        if slotBackup == abilityId then return x end
    end

    -- No skill matching ID slotted
    return nil
end

--- Register stack tracking for the given ability ID
--- @param abilityId integer The ability ID to track stacks for
--- @return nil
function GFC:RegisterStacksForId(abilityId)
    local stackId = self.skills[abilityId]

    GFC:Trace(2, "Registering <<1>> (<<2>>) for stackId <<3>>", GetAbilityName(abilityId), abilityId, stackId)

    EM:RegisterForEvent(self.name .. "Stack", EVENT_EFFECT_CHANGED, self.OnEffectChanged)
    EM:AddFilterForEvent(self.name .. "Stack", EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_ABILITY_ID, stackId,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER
    )
end

--- Check if Grim Focus (or one of its morphs) is slotted and register/unregister events accordingly
--- @return boolean slotted True when skill is slotted
function GFC:CheckSkillSlotted()
    local skillPurchased = IsSkillAbilityPurchased(self.skillType, self.skillLineIndex, self.skillIndex)

    -- Check if skill is purchased
    if not skillPurchased then
        GFC:Trace(2, "Skill not purchased")
        return false
    end

    --- Return type of GetSkillAbilityId() has integer and abilityId reversed
    --- Use `@as` to resolve diagnostic
    local abilityId = GetSkillAbilityId(self.skillType, self.skillLineIndex, self.skillIndex, false) --[[@as integer]]
    local abilityName = GetAbilityName(abilityId)
    local slottedPosition = getSlottedPosition(abilityId)

    -- If skill is slotted
    if slottedPosition ~= nil then
        GFC:Trace(2, "Skill <<1>> (<<2>>) found in slot <<1>>, enabling", abilityName, abilityId, slottedPosition)
        self:RegisterStacksForId(abilityId)
        return true
    else
        GFC:Trace(2, "Skill <<1>> (<<2>>) not slotted, disabling", abilityName, abilityId)
        self:UnregisterStacks()
        return false
    end
end

--- Callback when hotbars have been updated, e.g. skill (un)slotted
--- @return nil
local function hotbarsUpdated()
    GFC:Trace(2, "Hotbars Updated!")
    GFC:OnPlayerChanged()
end

--- Register addon events
--- @return nil
function GFC:RegisterEvents()
    -- Combat enter/exit events
    if self.preferences.hideOutOfCombat then
        self:RegisterCombatEvent()
    end

    local function onPlayerChanged()
        self:OnPlayerChanged()
    end

    -- Zone change or load
    EM:RegisterForEvent(self.name .. "PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED, onPlayerChanged)
    EM:RegisterForEvent(self.name .. "ZONE_UPDATE", EVENT_ZONE_UPDATE, onPlayerChanged)

    -- Dead or alive
    EM:RegisterForEvent(self.name .. "PlayerDead", EVENT_PLAYER_DEAD, onPlayerChanged)
    EM:RegisterForEvent(self.name .. "PlayerAlive", EVENT_PLAYER_ALIVE, onPlayerChanged)

    EM:RegisterForEvent(self.name .. "HotbarUpdated", EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, hotbarsUpdated)
end

--- Register combat state tracking events
--- @return nil
function GFC:RegisterCombatEvent()
    -- Register start/end combat events
    EM:RegisterForEvent(self.name .. "COMBAT_STATE", EVENT_PLAYER_COMBAT_STATE, function() self:OnPlayerChanged() end)
end

--- Unregister combat state tracking events
--- @return nil
function GFC:UnregisterCombatEvent()
    -- Register start/end combat events
    EM:UnregisterForEvent(self.name .. "COMBAT_STATE", EVENT_PLAYER_COMBAT_STATE)
end

--- Unregister stack tracking events
--- @return nil
function GFC:UnregisterStacks()
    GFC:Trace(2, "Unregistering stacks")

    EM:UnregisterForEvent(GFC.name .. 'Stack', EVENT_EFFECT_CHANGED)
end

--- Unregister tracking events
--- @return nil
function GFC:UnregisterEvents()
    GFC:UnregisterCombatEvent()
    EM:UnregisterForEvent(self.name .. "PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED)
    EM:UnregisterForEvent(self.name .. "ZONE_UPDATE", EVENT_ZONE_UPDATE)
    EM:UnregisterForEvent(self.name .. "PlayerDead", EVENT_PLAYER_DEAD)
    EM:UnregisterForEvent(self.name .. "PlayerAlive", EVENT_PLAYER_ALIVE)
    EM:UnregisterForEvent(self.name .. "HotbarUpdated", EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED)
end

--- Register event tracking without a filter
--- @return nil
function GFC.RegisterUnfilteredEvents()
    EM:RegisterForEvent(GFC.name .. "UNFILTERED", EVENT_EFFECT_CHANGED, GFC.OnEffectChanged)
    GFC:Trace(3, "Registering unfiltered complete")
end

--- Unregister event tracking without a filter
--- @return nil
function GFC.UnregisterUnfilteredEvents()
    EM:UnregisterForEvent(GFC.name .. "UNFILTERED", EVENT_EFFECT_CHANGED)
    GFC:Trace(3, "Unregistering unfiltered complete")
end

--- Set the in combat state
--- @param inCombat boolean True when in combat
--- @return nil
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

--- Get the current number of stacks active
--- @return integer stackCount Current number of stacks
function GFC:GetBuffStacks()
    for i = 1, GetNumBuffs("player") do
        local _, _, _, _, stackCount --[[ @as integer ]], _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        for ability, stackId in pairs(GFC.skills) do
            local abilityName = GetAbilityName(ability)
            GFC:Trace(3, "Checking for <<1>> (<<2>>)", abilityName, ability)
            if stackId == abilityId then
                -- Fix diagnostic for GetUnitBuffInfo() returns
                return stackCount --[[@as integer]]
            end
        end
    end

    return 0
end

--- Update various states when something about the player changed
--- @return nil
function GFC:OnPlayerChanged()
    self:SetInCombat(IsUnitInCombat("player") --[[@as boolean]])

    local slotted = self:CheckSkillSlotted()

    if slotted then
        local stacks = self:GetBuffStacks()
        self.skillSlotted = true
        self.currentStacks = stacks
    else
        self.skillSlotted = false
        self.currentStacks = 0
    end

    self:UpdateUI()
end

--- Handle stack effect changes
--- @param changeType integer
--- @param effectName string
--- @param stackCount integer
--- @param effectAbilityId integer
--- @return nil
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
