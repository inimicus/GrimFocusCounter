-- -----------------------------------------------------------------------------
-- Grim Focus Counter
-- Author:  g4rr3t
-- Created: Dec 20, 2017
--
-- Track stacks of Grim Focus and its morphs and display
-- the stacks in a very visual and obvious way.
--
-- Main.lua
-- -----------------------------------------------------------------------------
GFC             = {}
GFC.name        = "GrimFocusCounter"
GFC.version     = "0.2.0"
GFC.dbVersion   = 1
GFC.slash       = "/gfc"
GFC.prefix      = "[GFC] "
GFC.HUDHidden   = false
GFC.ForceShow   = false

-- -----------------------------------------------------------------------------
-- Level of debug output
-- 1: Low    - Basic debug info, show core functionality
-- 2: Medium - More information about skills and addon details
-- 3: High   - Everything
GFC.debugMode = 0
-- -----------------------------------------------------------------------------

local function Trace(debugLevel, ...)
    if debugLevel <= GFC.debugMode then
        d(GFC.prefix .. ...)
    end
end

-- -----------------------------------------------------------------------------
-- Startup
-- -----------------------------------------------------------------------------

function GFC.Initialize(event, addonName)
    if addonName ~= GFC.name then return end

    Trace(1, "GFC Loaded")
    EVENT_MANAGER:UnregisterForEvent(GFC.name, EVENT_ADD_ON_LOADED)

    GFC.preferences = ZO_SavedVars:NewAccountWide("GrimFocusCounterVariables", GFC.dbVersion, nil, GFC:GetDefaults())

    SLASH_COMMANDS[GFC.slash] = GFC.SlashCommand

    GFC:InitSettings()
    GFC.DrawUI()
    GFC.ToggleHUD()

    -- Events for each skill morph
    -- Separate namespaces for each are required as
    -- duplicate filters against the same namespace
    -- overwrite the previously set filter.
    --
    -- These filter the EVENT_EFFECT_CHANGED event to
    -- hit the callback *only* when the three specific
    -- ability IDs change and avoid the need to conditionally
    -- exclude all skills we are not interested in.

    EVENT_MANAGER:RegisterForEvent(GFC.ABILITIES.MERCILESS_RESOLVE.STACK.NAME, EVENT_EFFECT_CHANGED, function(...) GFC.OnStackChanged(...) end)
    EVENT_MANAGER:AddFilterForEvent(GFC.ABILITIES.MERCILESS_RESOLVE.STACK.NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, GFC.ABILITIES.MERCILESS_RESOLVE.STACK.ID)
    EVENT_MANAGER:AddFilterForEvent(GFC.ABILITIES.MERCILESS_RESOLVE.STACK.NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    EVENT_MANAGER:RegisterForEvent(GFC.ABILITIES.RELENTLESS_FOCUS.STACK.NAME, EVENT_EFFECT_CHANGED, function(...) GFC.OnStackChanged(...) end)
    EVENT_MANAGER:AddFilterForEvent(GFC.ABILITIES.RELENTLESS_FOCUS.STACK.NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, GFC.ABILITIES.RELENTLESS_FOCUS.STACK.ID)
    EVENT_MANAGER:AddFilterForEvent(GFC.ABILITIES.RELENTLESS_FOCUS.STACK.NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    EVENT_MANAGER:RegisterForEvent(GFC.ABILITIES.GRIM_FOCUS.STACK.NAME, EVENT_EFFECT_CHANGED, function(...) GFC.OnStackChanged(...) end)
    EVENT_MANAGER:AddFilterForEvent(GFC.ABILITIES.GRIM_FOCUS.STACK.NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, GFC.ABILITIES.GRIM_FOCUS.STACK.ID)
    EVENT_MANAGER:AddFilterForEvent(GFC.ABILITIES.GRIM_FOCUS.STACK.NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    if GFC.preferences.showEmptyStacks then
        EVENT_MANAGER:RegisterForEvent(GFC.ABILITIES.MERCILESS_RESOLVE.SKILL.NAME, EVENT_EFFECT_CHANGED, function(...) GFC.OnEffectChanged(...) end)
        EVENT_MANAGER:AddFilterForEvent(GFC.ABILITIES.MERCILESS_RESOLVE.SKILL.NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, GFC.ABILITIES.MERCILESS_RESOLVE.SKILL.ID)
        EVENT_MANAGER:AddFilterForEvent(GFC.ABILITIES.MERCILESS_RESOLVE.SKILL.NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

        EVENT_MANAGER:RegisterForEvent(GFC.ABILITIES.RELENTLESS_FOCUS.SKILL.NAME, EVENT_EFFECT_CHANGED, function(...) GFC.OnEffectChanged(...) end)
        EVENT_MANAGER:AddFilterForEvent(GFC.ABILITIES.RELENTLESS_FOCUS.SKILL.NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, GFC.ABILITIES.RELENTLESS_FOCUS.SKILL.ID)
        EVENT_MANAGER:AddFilterForEvent(GFC.ABILITIES.RELENTLESS_FOCUS.SKILL.NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

        EVENT_MANAGER:RegisterForEvent(GFC.ABILITIES.GRIM_FOCUS.SKILL.NAME, EVENT_EFFECT_CHANGED, function(...) GFC.OnEffectChanged(...) end)
        EVENT_MANAGER:AddFilterForEvent(GFC.ABILITIES.GRIM_FOCUS.SKILL.NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, GFC.ABILITIES.GRIM_FOCUS.SKILL.ID)
        EVENT_MANAGER:AddFilterForEvent(GFC.ABILITIES.GRIM_FOCUS.SKILL.NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    end

end

-- -----------------------------------------------------------------------------
-- Skill Tracking
-- -----------------------------------------------------------------------------

function GFC.OnStackChanged(eventCode, changeType, effectSlot, effectName,
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
            GFC.UpdateStacks(0)
            Trace(2, "Faded on stack #"..stackCount)
        else
            GFC.UpdateStacks(stackCount)
            Trace(2, "Stack #"..stackCount)
        end
        return
    end

end

function GFC.OnEffectChanged(eventCode, changeType, effectSlot, effectName,
        unitTag, startTimeSec, endTimeSec, stackCount, iconName, buffType,
        effectType, abilityType, statusEffectType, unitName, unitId,
        effectAbilityId)

    Trace(3, effectAbilityId)

    -- Exclude abilities from group members
    if unitTag and string.find(unitTag, 'group') then return end

    -- Not a stack
    if changeType == EFFECT_RESULT_GAINED then
        Trace(2, "Gained: " ..  effectAbilityId)
        GFC.abilityActive = true
        GFC.UpdateStacks(0)
        return
    end

    if changeType == EFFECT_RESULT_FADED then
        Trace(2, "Faded: " ..  effectAbilityId)
        GFC.abilityActive = false
        GFC.UpdateStacks(0)
        return
    end

end

-- -----------------------------------------------------------------------------
-- User Interface
-- -----------------------------------------------------------------------------

function GFC.DrawUI()
    local c = WINDOW_MANAGER:CreateTopLevelWindow("GFCContainer")
    c:SetClampedToScreen(true)
    c:SetDimensions(GFC.preferences.size, GFC.preferences.size)
    c:ClearAnchors()
    c:SetMouseEnabled(true)
    c:SetAlpha(1)
    c:SetMovable(GFC.preferences.unlocked)
    c:SetHidden(false)
    c:SetHandler("OnMoveStop", function(...) GFC.SavePosition() end)

    local t = WINDOW_MANAGER:CreateControl("GFCTexture", c, CT_TEXTURE)
    t:SetTexture(GFC.TEXTURE_VARIANTS[GFC.preferences.selectedTexture].asset)
    t:SetDimensions(GFC.preferences.size, GFC.preferences.size)
    t:SetTextureCoords(GFC.TEXTURE_FRAMES[0].REL, GFC.TEXTURE_FRAMES[1].REL, 0, 1)
    t:SetAnchor(TOPLEFT, c, TOPLEFT, 0, 0)

    GFC.GFCContainer = c
    GFC.GFCTexture = t

    GFC.SetPosition(GFC.preferences.positionLeft, GFC.preferences.positionTop)
end

function GFC.ToggleHUD()
    local hudScene = SCENE_MANAGER:GetScene("hud")
    hudScene:RegisterCallback("StateChange", function(oldState, newState)

        -- Don't change states if display should be forced to show
        if GFC.ForceShow then return end

        -- Transitioning to a menu/non-HUD
        if newState == SCENE_HIDDEN and SCENE_MANAGER:GetNextScene():GetName() ~= "hudui" then
            GFC.HUDHidden = true
            GFC.GFCContainer:SetHidden(true)
        end

        -- Transitioning to a HUD/non-menu
        if newState == SCENE_SHOWING then
            GFC.HUDHidden = false
            GFC.GFCContainer:SetHidden(false)
        end
    end)
end

function GFC.OnMoveStop()
    Trace(1, "Moved")
    GFC.SavePosition()
end

function GFC.SavePosition()
    local top   = GFC.GFCContainer:GetTop()
    local left  = GFC.GFCContainer:GetLeft()

    Trace(2, "Saving position - Left: " .. left .. " Top: " .. top)

    GFC.preferences.positionLeft = left
    GFC.preferences.positionTop  = top
end

function GFC.SetPosition(left, top)
    Trace(2, "Setting - Left: " .. left .. " Top: " .. top)
    GFC.GFCContainer:ClearAnchors()
    GFC.GFCContainer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function GFC.UpdateStacks(stackCount)

    -- Ignore missing stackCount
    if not stackCount then return end

    if stackCount == 0 and GFC.preferences.showEmptyStacks then
        
        if GFC.abilityActive then
            -- Show zero stack indicator
            Trace(1, "Stack #0, Show Empty, Active Skill")
            GFC.GFCTexture:SetTextureCoords(GFC.TEXTURE_FRAMES[6].REL, GFC.TEXTURE_FRAMES[7].REL, 0, 1)
        else
            -- Hide stack indicator
            Trace(1, "Stack #0, Show Empty, Inactive Skill")
            GFC.GFCTexture:SetTextureCoords(GFC.TEXTURE_FRAMES[0].REL, GFC.TEXTURE_FRAMES[1].REL, 0, 1)
        end

    else
        Trace(1, "Stack #" .. stackCount)
        GFC.GFCTexture:SetTextureCoords(GFC.TEXTURE_FRAMES[stackCount].REL, GFC.TEXTURE_FRAMES[stackCount+1].REL, 0, 1)
    end

end

function GFC.SlashCommand(command)
    if command == "debug 0" then
        d(GFC.prefix .. "Setting debug level to 0 (Off)")
        GFC.debugMode = 0
    elseif command == "debug 1" then
        d(GFC.prefix .. "Setting debug level to 1 (Low)")
        GFC.debugMode = 1
    elseif command == "debug 2" then
        d(GFC.prefix .. "Setting debug level to 2 (Medium)")
        GFC.debugMode = 2
    elseif command == "debug 3" then
        d(GFC.prefix .. "Setting debug level to 3 (High)")
        GFC.debugMode = 3
    else
        d(GFC.prefix .. "Command not recognized!")
    end
end

-- -----------------------------------------------------------------------------
-- Event Hooks
-- -----------------------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent(GFC.name, EVENT_ADD_ON_LOADED, function(...) GFC.Initialize(...) end)

