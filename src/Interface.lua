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

    local t = WINDOW_MANAGER:CreateControl("GFCTexture", c, CT_TEXTURE)
    t:SetTexture(GFC.TEXTURE_VARIANTS[GFC.preferences.selectedTexture].asset)
    t:SetDimensions(GFC.preferences.size, GFC.preferences.size)
    t:SetTextureCoords(GFC.TEXTURE_FRAMES[0].REL, GFC.TEXTURE_FRAMES[1].REL, 0, 1)
    t:SetAnchor(TOPLEFT, c, TOPLEFT, 0, 0)

    GFC.GFCContainer = c
    GFC.GFCTexture = t

    GFC.SetPosition(GFC.preferences.positionLeft, GFC.preferences.positionTop)
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
        GFC:Trace(1, "Stack #" .. stackCount)
        GFC.GFCTexture:SetTextureCoords(GFC.TEXTURE_FRAMES[stackCount].REL, GFC.TEXTURE_FRAMES[stackCount+1].REL, 0, 1)

    else

        -- Show zero stack indicator for active ability
        if GFC.preferences.showEmptyStacks and GFC.abilityActive then
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

