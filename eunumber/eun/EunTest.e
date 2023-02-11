-- Copyright (c) 2016-2023 James Cook

include ../minieun/Eun.e
include ../minieun/CompareFuncs.e
include ../minieun/AdjustRound.e

-- EunTest
global function EunTest(Eun val0, Eun ans)
    -- "val0" is the number we are testing against known value "ans"
    -- "ans" is more precise than "val0"
    sequence val1, range
    -- val0 = EunMultiplicativeInverse(val)
    val1 = ans
    val1[3] = val0[3]
    val1 = AdjustRound(val1[1], val1[2], val1[3], val1[4], NO_SUBTRACT_ADJUST)
    range = Equaln(val0[1], val1[1])
    return range
end function
