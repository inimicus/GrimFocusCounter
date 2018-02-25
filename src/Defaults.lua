-- -----------------------------------------------------------------------------
-- Grim Focus Counter
-- Author:  g4rr3t
-- Created: Jan 1, 2018
--
-- Defaults.lua
-- -----------------------------------------------------------------------------

local defaults = {
    showEmptyStacks = false,
    selectedTexture = 1,
    positionLeft = 800,
    positionTop = 600,
    size = 40,
    unlocked = true,
    lockedToReticle = false,
}

function GFC:GetDefaults()
    return defaults
end
