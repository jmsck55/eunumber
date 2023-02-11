-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/Eun.e
include ../../eunumber/minieun/ConvertExp.e
include ../../eunumber/minieun/AdjustRound.e
include ../../eunumber/eun/EunMultiply.e
include ../../eunumber/eun/EunDivide.e

include ../myeun/adjustPrecision.e

include GetPI.e


-- function RadiansToDegrees(r)
--       return (r / halfPI) * 90
-- end function
--
-- function DegreesToRadians(d)
--       return (d / 90) * halfPI
-- end function

global function EunRadiansToDegrees(Eun r)
    sequence ninety
    Eun d = r
    d[3] += adjustPrecision
    ninety = NewEun({9}, 1, d[3], 10)
    if d[4] != 10 then
        ninety = EunConvert(ninety, d[4], d[3])
    end if
    d = EunMultiply(EunDivide(d, GetHalfPI(r[3], d[4])), ninety)
    d[3] -= adjustPrecision
    d = AdjustRound(d[1], d[2], r[3], d[4], NO_SUBTRACT_ADJUST)
    return d
end function

global function EunDegreesToRadians(Eun d)
    sequence ninety
    Eun r = d
    r[3] += adjustPrecision
    ninety = NewEun({9}, 1, r[3], 10)
    if r[4] != 10 then
        ninety = EunConvert(ninety, r[4], r[3])
    end if
    r = EunMultiply(EunDivide(r, ninety), GetHalfPI(d[3], r[4]))
    d[3] -= adjustPrecision
    r = AdjustRound(r[1], r[2], d[3], r[4], NO_SUBTRACT_ADJUST)
    return r
end function
