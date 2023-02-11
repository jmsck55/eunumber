-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/Eun.e
include ../../eunumber/eun/EunAdd.e

include ../myeun/adjustPrecision.e

include EunCos.e
include GetPI.e


-- EunSin:

global function EunSin(Eun x)
-- Cases: 0 equals zero (0)
-- Range: -PI/2 to PI/2, inclusive
-- To find sin(x):
-- sin(x) = cos(x - PI/2)
-- y = sin(x)
-- y = cos(x - PI/2)
    sequence y
    y = x
    y[3] += adjustPrecision
    y = EunSubtract(y, GetHalfPI(y[3], y[4])) -- see if it's accurate enough.
    y[3] -= adjustPrecision
    y = EunCos(y)
    return y
end function
