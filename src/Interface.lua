-- -----------------------------------------------------------------------------
-- Grim Focus Counter
-- Author:  g4rr3t
-- Created: Jan 28, 2018
--
-- Interface.lua
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

    -- Check for valid texture
    -- Potential fix for UI error discovered by Porkjet
    if not GFC.TEXTURE_VARIANTS[GFC.preferences.selectedTexture] then
        -- If texture selection is not a valid option, reset to default
        GFC:Trace(1, 'Invalid texture selection: ' .. GFC.preferences.selectedTexture)
        GFC.preferences.selectedTexture = GFC:GetDefaults().selectedTexture
    end

    local t = WINDOW_MANAGER:CreateControl("GFCTexture", c, CT_TEXTURE)
    t:SetTexture(GFC.TEXTURE_VARIANTS[GFC.preferences.selectedTexture].asset)
    t:SetDimensions(GFC.preferences.size, GFC.preferences.size)
    t:SetTextureCoords(GFC.TEXTURE_FRAMES[0].REL, GFC.TEXTURE_FRAMES[1].REL, 0, 1)
    t:SetAnchor(TOPLEFT, c, TOPLEFT, 0, 0)

    GFC.GFCContainer = c
    GFC.GFCTexture = t

    GFC.SetPosition(GFC.preferences.positionLeft, GFC.preferences.positionTop)
    GFC.SetSkillColorOverlay('default')

    GFC:Trace(2, "Finished DrawUI()")
end

function GFC.SetSkillColorOverlay(overlayType)

    -- Read saved color
    color = GFC.preferences.colors[overlayType]

    if GFC.preferences.overlay[overlayType] then
        -- Set active color overlay
        GFC.GFCTexture:SetColor(color.r, color.g, color.b, color.a)
    else
        -- Set to default if it's set
        if GFC.preferences.overlay.default then
            default = GFC.preferences.colors.default
            GFC.GFCTexture:SetColor(default.r, default.g, default.b, default.a)
        else
            -- Set to white AKA none if no default set
            GFC.GFCTexture:SetColor(1, 1, 1, 1)
        end

    end
end

function GFC.SetSkillFade(faded)
    -- Only change fade if our options want us to fade
    if GFC.preferences.fadeInactive then
        if faded then
            alpha = GFC.preferences.fadeAmount / 100
            GFC.GFCContainer:SetAlpha(alpha)
        else
            GFC.GFCContainer:SetAlpha(1)
        end
    end
end

function GFC.ToggleHUD()
    local hudScene = SCENE_MANAGER:GetScene("hud")
    hudScene:RegisterCallback("StateChange", function(oldState, newState)

        -- Don't change states if display should be forced to show
        if GFC.ForceShow then return end

        -- Transitioning to a menu/non-HUD
        if newState == SCENE_HIDDEN and SCENE_MANAGER:GetNextScene():GetName() ~= "hudui" then
            GFC:Trace(3, "Hiding HUD")
            GFC.HUDHidden = true
            GFC.GFCContainer:SetHidden(true)
        end

        -- Transitioning to a HUD/non-menu
        if newState == SCENE_SHOWING then
            GFC:Trace(3, "Showing HUD")
            GFC.HUDHidden = false
            GFC.GFCContainer:SetHidden(false)
        end
    end)

    GFC:Trace(2, "Finished ToggleHUD()")
end

function GFC.LockToReticle(lockToReticle)
    if lockToReticle then
        GFC.preferences.lockedToReticle = true
        GFC:Trace(1, "Locked to Reticle")
    else
        GFC.preferences.lockedToReticle = false
        GFC:Trace(1, "Unlocked from Reticle")
    end
    GFC.SetPosition(GFC.preferences.positionLeft, GFC.preferences.positionTop)
end

function GFC.OnMoveStop()
    GFC:Trace(1, "Moved")
    GFC.SavePosition()
end

function GFC.SavePosition()
    local top   = GFC.GFCContainer:GetTop()
    local left  = GFC.GFCContainer:GetLeft()

    -- If locked to reticle, but unlocked and moved,
    -- then we are no longer locked to reticle.
    GFC.preferences.lockedToReticle = false

    GFC:Trace(2, "Saving position - Left: " .. left .. " Top: " .. top)

    GFC.preferences.positionLeft = left
    GFC.preferences.positionTop  = top
end

function GFC.SetPosition(left, top)
    if GFC.preferences.lockedToReticle then
        local height = GuiRoot:GetHeight()

        GFC.GFCContainer:ClearAnchors()
        GFC.GFCContainer:SetAnchor(CENTER, GuiRoot, TOP, 0, height/2)
    else
        GFC:Trace(2, "Setting - Left: " .. left .. " Top: " .. top)
        GFC.GFCContainer:ClearAnchors()
        GFC.GFCContainer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    end
end

function GFC.UpdateStacks(stackCount)

    -- Ignore missing stackCount
    if not stackCount then return end

    if stackCount > 0 then

        -- Show stacks
        GFC.GFCTexture:SetTextureCoords(GFC.TEXTURE_FRAMES[stackCount].REL, GFC.TEXTURE_FRAMES[stackCount+1].REL, 0, 1)

    else

        -- Show zero stack indicator for active ability
        if GFC.preferences.showEmptyStacks and (GFC.abilityActive or GFC.isInCombat) then
            GFC:Trace(1, "Stack #0 (Show Empty)")
            GFC.GFCTexture:SetTextureCoords(GFC.TEXTURE_FRAMES[6].REL, GFC.TEXTURE_FRAMES[7].REL, 0, 1)
            return
        end

        -- Skill dead or do not show empty stacks
        GFC:Trace(1, "Skill inactive or don't show empty stacks")
        GFC.GFCTexture:SetTextureCoords(GFC.TEXTURE_FRAMES[0].REL, GFC.TEXTURE_FRAMES[1].REL, 0, 1)

    end
end

function GFC.SlashCommand(command)
    -- Debug Options ----------------------------------------------------------
    if command == "debug 0" then
        d(GFC.prefix .. "Setting debug level to 0 (Off)")
        GFC.debugMode = 0
        GFC.preferences.debugMode = 0
    elseif command == "debug 1" then
        d(GFC.prefix .. "Setting debug level to 1 (Low)")
        GFC.debugMode = 1
        GFC.preferences.debugMode = 1
    elseif command == "debug 2" then
        d(GFC.prefix .. "Setting debug level to 2 (Medium)")
        GFC.debugMode = 2
        GFC.preferences.debugMode = 2
    elseif command == "debug 3" then
        d(GFC.prefix .. "Setting debug level to 3 (High)")
        GFC.debugMode = 3
        GFC.preferences.debugMode = 3

    -- Position Options -------------------------------------------------------
    elseif command == "position reset" then
        d(GFC.prefix .. "Resetting position to reticle")
        local tempPos = GFC.preferences.lockedToReticle
        GFC.preferences.lockedToReticle = true
        GFC.SetPosition()
        GFC.preferences.lockedToReticle = tempPos
    elseif command == "position show" then
        d(GFC.prefix .. "Display position is set to: [" ..
            GFC.preferences.positionTop ..
            ", " ..
            GFC.preferences.positionLeft ..
            "]")
    elseif command == "position lock" then
        d(GFC.prefix .. "Locking display")
        GFC.preferences.unlocked = false
        GFC.GFCContainer:SetMovable(false)
    elseif command == "position unlock" then
        d(GFC.prefix .. "Unlocking display")
        GFC.preferences.unlocked = true
        GFC.GFCContainer:SetMovable(true)

    -- Manage Registration ----------------------------------------------------
    elseif command == "register" then
        d(GFC.prefix .. "Reregistering all events")
        GFC.UnregisterEvents()
        GFC.RegisterEvents()
    elseif command == "unregister" then
        d(GFC.prefix .. "Unregistering all events")
        GFC.UnregisterEvents()
        GFC.abilityActive = false
        GFC.UpdateStacks(0)
    elseif command == "register unfiltered" then
        d(GFC.prefix .. "Unregistering all events")
        GFC.UnregisterEvents()
        GFC.abilityActive = false
        GFC.UpdateStacks(0)
        d(GFC.prefix .. "Registering for ALL events unfiltered")
        GFC.RegisterUnfilteredEvents()
    elseif command == "unregister unfiltered" then
        d(GFC.prefix .. "Unregistering unfiltered events")
        GFC.UnregisterUnfilteredEvents()
        GFC.abilityActive = false
        GFC.UpdateStacks(0)

    -- Default ----------------------------------------------------------------
    else
        d(GFC.prefix .. "Command not recognized!")
    end
end

