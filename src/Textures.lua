-- -----------------------------------------------------------------------------
-- Grim Focus Counter
-- Author:  g4rr3t
-- Created: Jan 1, 2018
--
-- Textures.lua
-- -----------------------------------------------------------------------------

GFC.TEXTURE_SIZE = {
    FRAME_HEIGHT    = 128,  -- Height of each texture frame
    FRAME_WIDTH     = 128,  -- Width of each texture frame
    ASSET_WIDTH     = 1024, -- Overall texture width
    ASSET_HEIGHT    = 128,  -- Overall texture height
}

GFC.TEXTURE_VARIANTS = {
    [0] = {
        name    = "Color Squares",
        asset   = "GrimFocusCounter/art/textures/ColorSquares.dds",
    },
    [1] = {
        name    = "DOOM",
        asset   = "GrimFocusCounter/art/textures/Doom.dds",
    },
    [2] = {
        name    = "Horizontal Dots",
        asset   = "GrimFocusCounter/art/textures/HorizontalDots.dds",
    },
    [3] = {
        name    = "Numbers",
        asset   = "GrimFocusCounter/art/textures/Numbers.dds",
    },
    [4] = {
        name    = "Dice",
        asset   = "GrimFocusCounter/art/textures/Dice.dds",
    },
    [5] = {
        name    = "Play Magsorc",
        asset   = "GrimFocusCounter/art/textures/PlayMagsorc.dds",
    },
}

GFC.TEXTURE_FRAMES = {
    [0] = { ABS = 0,    REL = 0.0 },	-- No stacks
    [1] = { ABS = 128,  REL = 0.125 },	-- Stack #1
    [2] = { ABS = 256,  REL = 0.25 },	-- Stack #2
    [3] = { ABS = 384,  REL = 0.375 }, 	-- Stack #3
    [4] = { ABS = 512,  REL = 0.5 },	-- Stack #4
    [5] = { ABS = 640,  REL = 0.625 },	-- Stack #5
    [6] = { ABS = 768,  REL = 0.75 },	-- Empty stack indicator
    [7] = { ABS = 896,  REL = 0.875 },	-- Skill active indicator
    [8] = { ABS = 1024, REL = 1.0 },	-- End of texture
}

