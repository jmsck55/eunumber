-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/Eun.e
include ../../eunumber/eun/EunDivide.e

include EunCos.e
include EunSin.e


-- Tangent

global function EunTan(Eun a)
    sequence ret
    ret = a
    -- ret[3] += adjustPrecision
    ret = EunDivide(EunSin(ret), EunCos(ret))
    -- ret[3] -= adjustPrecision
    --ret = AdjustRound(ret[1], ret[2], ret[3], ret[4], NO_SUBTRACT_ADJUST)
    return ret
end function
