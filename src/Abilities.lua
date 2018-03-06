-- -----------------------------------------------------------------------------
-- Grim Focus Counter
-- Author:  g4rr3t
-- Created: Jan 1, 2018
--
-- Abilities.lua
-- -----------------------------------------------------------------------------

--[[
    Minor Endurance:    62110
    Minor Savagery:     61898 (and maybe 34386)
    Minor Berserk:      64054, 64055
    Merciless:
        Rank    Skill   Stack
        I:      61919   61920
        II:     62111   62112
        III:    62114   62115
        IV:     62117   62118

    Relentless:
        Rank    Skill   Stack
        I:      61927   61928
        II:     62099   62100
        III:    62103   62104
        IV:     62107   62108

    Grim:
        Rank    Skill   Stack
        I:      61902   61903
        II:     62090   62091
        III:    64176   64177
        IV:     62096   62097
]]

GFC.ABILITIES = {
    GrimFocus = {
        ['I'] = {
            Skill = 61902,
            Stack = 61903,
        },
        ['II'] = {
            Skill = 62090,
            Stack = 62091,
        },
        ['III'] = {
            Skill = 64176,
            Stack = 64177,
        },
        ['IV'] = {
            Skill = 62096,
            Stack = 62097,
        },
    },
    MercilessResolve = {
        ['I'] = {
            Skill = 61919,
            Stack = 61920,
        },
        ['II'] = {
            Skill = 62111,
            Stack = 62112,
        },
        ['III'] = {
            Skill = 62114,
            Stack = 62115,
        },
        ['IV'] = {
            Skill = 62117,
            Stack = 62118,
        },
    },
    RelentlessFocus = {
        ['I'] = {
            Skill = 61927,
            Stack = 61928,
        },
        ['II'] = {
            Skill = 62099,
            Stack = 62100,
        },
        ['III'] = {
            Skill = 62103,
            Stack = 62104,
        },
        ['IV'] = {
            Skill = 62107,
            Stack = 62108,
        },
    },
}
