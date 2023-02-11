-- Copyright (c) 2016-2023 James Cook


include ../minieun/Eun.e
include ../minieun/WholeFracParts.e
include ../minieun/AdjustRound.e
include EunDivide.e
include EunMultiply.e
include EunFracPart.e
include EunIntPart.e


-- Remainder functions:

-- EunModf
global function EunModf(Eun fp)
-- similar to C's "modf()"
    return {EunIntPart(fp), EunFracPart(fp)}
end function

-- EunfDiv
global function EunfDiv(Eun num, Eun den)
-- similar to C's "div()"
    -- returns quotient and remainder
    object div
    div = EunModf(EunDivide(num, den))
    div[2] = EunMultiply(div[2], den)
    return div
end function

-- EunfMod
global function EunfMod(Eun num, Eun den)
-- similar to C's "fmod()", just the "mod" or remainder
    return EunMultiply(EunFracPart(EunDivide(num, den)), den)
end function

-- EunFloorCeil(), EunFloor(), EunCeil()
-- No remainder for Floor and Ceil functions:

global function EunFloorCeil(Eun num, ThreeOptions floorMode)
    sequence ret = WholeFracParts(num[1], num[2], WF_WHOLE_PART, integerModeFloat, floorMode)
    ret = ret[1]
    ret = AdjustRound(ret[1], ret[2], num[3], num[4], CARRY_ADJUST)
    return ret
end function

global function EunFloor(Eun num)
    return EunFloorCeil(num, WF_FLOOR)
end function

global function EunCeil(Eun num)
    return EunFloorCeil(num, WF_CEIL)
end function
