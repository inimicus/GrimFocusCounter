-- -----------------------------------------------------------------------------
-- Grim Focus Counter
-- Author:  g4rr3t
-- Created: Jan 1, 2018
--
-- Defaults.lua
-- -----------------------------------------------------------------------------

local defaults = {
    showEmptyStacks = false,
    selectedTexture = 2,
    positionLeft = 800,
    positionTop = 600,
    size = 40,
    unlocked = true,
    lockedToReticle = false,
    colorOverlay = false,
    color = {
        r = 1,
        g = 1,
        b = 1,
        a = 1,
    },
    fadeInactive = false,
    fadeAmount = 90,
}

function GFC:GetDefaults()
    return defaults
end
