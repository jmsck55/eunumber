-- Copyright (c) 2016-2023 James Cook

include ../minieun/Eun.e
include ../minieun/Common.e
include ../minieun/Defaults.e
include ../minieun/AdjustRound.e

-- EunRoundSignificantDigits:

global function EunRoundSig(Eun n1, PositiveInteger sigDigits = defaultTargetLength)
    -- TargetLength targetLength = n1[3]
    n1 = AdjustRound(n1[1], n1[2], sigDigits, n1[4], NO_SUBTRACT_ADJUST)
    -- n1[3] = targetLength
    return n1
end function

global function EunRoundSignificantDigits(sequence n1, integer sigDigits = defaultTargetLength)
    return EunRoundSig(n1, sigDigits)
end function
