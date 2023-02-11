-- Copyright (c) 2016-2023 James Cook

include ../../eunumber/minieun/Eun.e
include EunNthRoot.e

global function EunSquareRoot(Eun n1, object guess = 0)
-- Set "realMode" variable to TRUE (or 1), if you want it to crash if supplied a negative number.
-- Use "isImag" to determine if the result is complex,
-- which will happen if a negative number is passed to this function.
    return EunNthRoot(2, n1, guess)
end function

global function EunSqrt(Eun n1, object guess = 0)
    return EunSquareRoot(n1, guess)
end function
