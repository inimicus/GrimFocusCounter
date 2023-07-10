-- -----------------------------------------------------------------------------
-- Grim Focus Counter
-- Author:  g4rr3t
-- Created: Jan 1, 2018
--
-- Abilities.lua
-- -----------------------------------------------------------------------------

local GFC = GFC

--[[
    NOTE: As of Update 39 Week 1 PTS, the skill and stack IDs
    further below have been replaced by a single ID per skill.

    Investigating if there are different IDs per morph.

    Merciless:
        Rank    ID       Status
        I:
        II:
        III:
        IV:     122586   Confirmed by g4rr3t

    Relentless:
        Rank    ID       Status
        I:
        II:
        III:
        IV:     122587   Confirmed by g4rr3t

    Grim:
        Rank    ID       Status
        I:
        II:
        III:
        IV:     122585   Confirmed by g4rr3t

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
        Skill = 122585,
        Stack = 122585,
    },
    MercilessResolve = {
        Skill = 122586,
        Stack = 122586,
    },
    RelentlessFocus = {
        Skill = 122587,
        Stack = 122587,
    },
}
