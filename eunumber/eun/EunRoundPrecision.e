-- Copyright (c) 2016-2023 James Cook

include ../minieun/Eun.e
include ../minieun/ConvertExp.e

-- EunRoundPrecision
global function EunRoundPrecision(Eun a, integer prec = 0)
    sequence b
    if not prec then
        if length(a) >= 6 then
            prec = a[6]
        end if
        if not prec then
            return a
        end if
    end if
    b = EunConvert(a, 2, prec)
    b = EunConvert(b, a[4], PrecisionToTargetLength(prec, a[4]))
    b = NewEun(b[1], b[2], b[3], b[4], 0, prec)
    return b
end function
