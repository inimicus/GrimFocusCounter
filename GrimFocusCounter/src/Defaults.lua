-- -----------------------------------------------------------------------------
-- Grim Focus Counter
-- Author:  g4rr3t
-- Created: Jan 1, 2018
--
-- Defaults.lua
-- -----------------------------------------------------------------------------

local defaults = {
    debugMode = 0,
    showEmptyStacks = false,
    selectedTexture = 2,
    positionLeft = 800,
    positionTop = 600,
    size = 100,
    unlocked = true,
    lockedToReticle = false,
    overlay = {
        default   = false,
        inactive  = false,
        four      = false,
        proc      = false,
    },
    colors = {
        default = {
            r = 1,
            g = 1,
            b = 1,
            a = 1,
        },
        inactive = {
            r = 1,
            g = 1,
            b = 1,
            a = 1,
        },
        four = {
            r = 1,
            g = 1,
            b = 1,
            a = 1,
        },
        proc = {
            r = 1,
            g = 1,
            b = 1,
            a = 1,
        },
    },
    fadeInactive = false,
    fadeAmount = 90,
}

function GFC:GetDefaults()
    return defaults
end
