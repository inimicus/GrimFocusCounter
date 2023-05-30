-- -----------------------------------------------------------------------------
-- Grim Focus Counter
-- Author:  g4rr3t
-- Created: Jan 28, 2018
--
-- Interface.lua
-- -----------------------------------------------------------------------------

local WM = WINDOW_MANAGER
local GFC = GFC

function GFC:AddSceneFragments()
    if not self.fragment then
        self.fragment = ZO_SimpleSceneFragment:New(self.GFCContainer)
        HUD_UI_SCENE:AddFragment(self.fragment)
        HUD_SCENE:AddFragment(self.fragment)
    end
end

function GFC:RemoveSceneFragments()
    if self.fragment then
        HUD_UI_SCENE:RemoveFragment(self.fragment)
        HUD_SCENE:RemoveFragment(self.fragment)
        self.fragment = nil
    end
end

function GFC:DrawUI()
    local c = WM:CreateTopLevelWindow("GFCContainer")
    c:SetClampedToScreen(true)
    c:SetDimensions(self.preferences.size, self.preferences.size)
    c:ClearAnchors()
    c:SetMouseEnabled(true)
    c:SetAlpha(1)
    c:SetMovable(self.preferences.unlocked)
    c:SetHidden(false)
    c:SetHandler("OnMoveStop", function() self:SavePosition() end)
    c:SetHandler("OnMouseEnter", function()
        if self.preferences.unlocked then
            WM:SetMouseCursor(MOUSE_CURSOR_PAN)
        end
    end)
    c:SetHandler("OnMouseExit", function()
        if self.preferences.unlocked then
            WM:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
        end
    end)


    -- Check for valid texture
    -- Potential fix for UI error discovered by Porkjet
    if not self.TEXTURE_VARIANTS[self.preferences.selectedTexture] then
        -- If texture selection is not a valid option, reset to default
        self:Trace(1, 'Invalid texture selection: ' .. self.preferences.selectedTexture)
        self.preferences.selectedTexture = self:GetDefaults().selectedTexture
    end

    local t = WM:CreateControl("GFCTexture", c, CT_TEXTURE)
    t:SetTexture(self.TEXTURE_VARIANTS[self.preferences.selectedTexture].asset)
    t:SetDimensions(self.preferences.size, self.preferences.size)
    t:SetTextureCoords(self.TEXTURE_FRAMES[0].REL, self.TEXTURE_FRAMES[1].REL, 0, 1)
    t:SetAnchor(TOPLEFT, c, TOPLEFT, 0, 0)

    self.GFCContainer = c
    self.GFCTexture = t

    self:ToggleHUD()
    self.SetPosition(self.preferences.positionLeft, self.preferences.positionTop)
    self.SetSkillColorOverlay('default')

    self:Trace(2, "Finished DrawUI()")
end

function GFC.SetSkillColorOverlay(overlayType)
    -- Read saved color
    local color = GFC.preferences.colors[overlayType]

    if GFC.preferences.overlay[overlayType] then
        -- Set active color overlay
        GFC.GFCTexture:SetColor(color.r, color.g, color.b, color.a)
    else
        -- Set to default if it's set
        if GFC.preferences.overlay.default then
            local default = GFC.preferences.colors.default
            GFC.GFCTexture:SetColor(default.r, default.g, default.b, default.a)
        else
            -- Set to white AKA none if no default set
            GFC.GFCTexture:SetColor(1, 1, 1, 1)
        end
    end
end

function GFC:UpdateUI()
    local stacks = self.currentStacks
    local active = self.abilityActive

    GFC.SetSkillFade(not active)

    if not active then
        GFC.SetSkillColorOverlay('inactive')
    end

    if stacks == 4 then
        GFC.SetSkillColorOverlay('four')
    elseif stacks == 5 then
        GFC.SetSkillColorOverlay('proc')
    else
        GFC.SetSkillColorOverlay('default')
    end

    GFC.UpdateStacks(stacks)
end

function GFC.SetSkillFade(faded)
    -- Only change fade if our options want us to fade
    if GFC.preferences.fadeInactive then
        if faded then
            local alpha = GFC.preferences.fadeAmount / 100
            GFC.GFCContainer:SetAlpha(alpha)
        else
            GFC.GFCContainer:SetAlpha(1)
        end
    end
end

function GFC:ToggleHUD()
    if self.fragment then
        self:RemoveSceneFragments()
    else
        self:AddSceneFragments()
    end

    self:Trace(2, "Finished ToggleHUD()")
end

function GFC:LockToReticle(lockToReticle)
    if lockToReticle then
        self.preferences.lockedToReticle = true
        self:Trace(1, "Locked to Reticle")
    else
        self.preferences.lockedToReticle = false
        self:Trace(1, "Unlocked from Reticle")
    end
    self.SetPosition(self.preferences.positionLeft, self.preferences.positionTop)
end

function GFC:OnMoveStop()
    self:Trace(1, "Moved")
    self:SavePosition()
end

function GFC:SavePosition()
    local top = self.GFCContainer:GetTop()
    local left = self.GFCContainer:GetLeft()

    -- If locked to reticle, but unlocked and moved,
    -- then we are no longer locked to reticle.
    self.preferences.lockedToReticle = false

    self:Trace(2, "Saving position - Left: " .. left .. " Top: " .. top)

    self.preferences.positionLeft = left
    self.preferences.positionTop  = top
end

function GFC.SetPosition(left, top)
    if GFC.preferences.lockedToReticle then
        local height = GuiRoot:GetHeight()

        GFC.GFCContainer:ClearAnchors()
        GFC.GFCContainer:SetAnchor(CENTER, GuiRoot, TOP, 0, height / 2)
    else
        GFC:Trace(2, "Setting - Left: " .. left .. " Top: " .. top)
        GFC.GFCContainer:ClearAnchors()
        GFC.GFCContainer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    end
end

function GFC.UpdateStacks(stackCount)
    local stackFrame

    -- Ignore missing stackCount
    if not stackCount then return end

    if stackCount > 0 then
        GFC:Trace(1, "Stack #<<1>>", stackCount)
        stackFrame = stackCount
    else
        if GFC.preferences.showEmptyStacks then
            GFC:Trace(1, "Stack #0 (Show Empty)")
            stackFrame = 6
        else
            GFC:Trace(1, "Stack #0")
            stackFrame = 0
        end
    end

    GFC.GFCTexture:SetTextureCoords(GFC.TEXTURE_FRAMES[stackFrame].REL, GFC.TEXTURE_FRAMES[stackFrame + 1].REL, 0, 1)
end

function GFC:SlashCommand(command)
    -- Debug Options ----------------------------------------------------------
    if command == "debug 0" then
        self:Trace(0, "Setting debug level to 0 (Off)")
        self.debugMode = 0
        self.preferences.debugMode = 0
    elseif command == "debug 1" then
        self:Trace(0, "Setting debug level to 1 (Low)")
        self.debugMode = 1
        self.preferences.debugMode = 1
    elseif command == "debug 2" then
        self:Trace(0, "Setting debug level to 2 (Medium)")
        self.debugMode = 2
        self.preferences.debugMode = 2
    elseif command == "debug 3" then
        self:Trace(0, "Setting debug level to 3 (High)")
        self.debugMode = 3
        self.preferences.debugMode = 3

        -- Position Options -------------------------------------------------------
    elseif command == "position reset" then
        self:Trace(0, "Resetting position to reticle")
        local tempPos = self.preferences.lockedToReticle
        self.preferences.lockedToReticle = true
        self.SetPosition()
        self.preferences.lockedToReticle = tempPos
    elseif command == "position show" then
        self:Trace(
            0,
            "Display position is set to: <<1>> x <<2>>",
            self.preferences.positionTop,
            self.preferences.positionLeft
        )
    elseif command == "position lock" then
        self:Trace(0, "Locking display")
        self.preferences.unlocked = false
        self.GFCContainer:SetMovable(false)
    elseif command == "position unlock" then
        self:Trace(0, "Unlocking display")
        self.preferences.unlocked = true
        self.GFCContainer:SetMovable(true)

        -- Manage Registration ----------------------------------------------------
    elseif command == "register" then
        self:Trace(0, "Reregistering all events")
        self:UnregisterEvents()
        self:RegisterEvents()
    elseif command == "unregister" then
        self:Trace(0, "Unregistering all events")
        self:UnregisterEvents()
        self.abilityActive = false
        self.UpdateStacks(0)
    elseif command == "register unfiltered" then
        self:Trace(0, "Unregistering all events")
        self:UnregisterEvents()
        self.abilityActive = false
        self.UpdateStacks(0)
        self:Trace(0, "Registering for ALL events unfiltered")
        self.RegisterUnfilteredEvents()
    elseif command == "unregister unfiltered" then
        self:Trace(0, "Unregistering unfiltered events")
        self:UnregisterUnfilteredEvents()
        self.abilityActive = false
        self.UpdateStacks(0)

        -- Default ----------------------------------------------------------------
    else
        self:Trace(0, "Command not recognized!")
    end
end
