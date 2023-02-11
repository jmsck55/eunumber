-- Copyright (c) 2016-2023 James Cook


include ../minieun/Eun.e
include ../minieun/AdjustRound.e


-- NOTE: Most functions are designed to be accurate to the last digit but,
-- sometimes we want something less accurate.
-- To get less accurate results, you can use "RemoveLastDigits()".
global function RemoveLastDigits(sequence num, PositiveInteger digits = 1, PositiveInteger minlength = 0)
    integer newlen
    newlen = length(num) - digits
    if newlen < minlength then
        newlen = minlength
    end if
    if newlen <= 0 then
        return {}
    end if
    if newlen < length(num) then
        num = num[1..newlen]
    end if
    return num
end function

global function EunRoundLastDigits(Eun n1, PositiveInteger digits = 1, PositiveInteger minlength = 0)
    integer newlen
    newlen = length(n1[1]) - digits
    if newlen < minlength then
        newlen = minlength
    end if
    n1 = AdjustRound(n1[1], n1[2], newlen, n1[4], NO_SUBTRACT_ADJUST)
    return n1
end function
