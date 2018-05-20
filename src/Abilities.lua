-- -----------------------------------------------------------------------------
-- Grim Focus Counter
-- Author:  g4rr3t
-- Created: Jan 1, 2018
--
-- Abilities.lua
-- -----------------------------------------------------------------------------

--[[
    NOTE: As of Summerset PTS Week 1, all ranks of each morph
    use the Rank I Skill and Stack ID. This means we do not
    need to be concerned with IDs for ranks II-IV anymore.

    Merciless:
        Rank    Skill   Stack   Status
        I:      61919   61920   Confirmed by g4rr3t
        II:     62111   62112   Unconfirmed
        III:    62114   62115   Confirmed by Jae
        IV:     62117   62118   Confirmed by g4rr3t

    Relentless:
        Rank    Skill   Stack   Status
        I:      61927   61928   Confirmed by g4rr3t
        II:     62099   62100   Unconfirmed
        III:    62103   62104   Unconfirmed
        IV:     62107   62108   Confirmed by g4rr3t

    Grim:
        Rank    Skill   Stack   Status
        I:      61902   61905   Confirmed by Phinix
        II:     62090   62091   Unconfirmed
        III:    64176   64177   Confirmed by Seldaris
        IV:     62096   62097   Confirmed by g4rr3t
]]

GFC.ABILITIES = {
    GrimFocus = {
        Skill = 61902,
        Stack = 61905,
    },
    MercilessResolve = {
        Skill = 61919,
        Stack = 61920,
    },
    RelentlessFocus = {
        Skill = 61927,
        Stack = 61928,
    },
}

