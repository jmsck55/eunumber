-- Copyright (c) 2016-2023 James Cook


include ../minieun/Eun.e
include ../minieun/AdjustRound.e


-- EunAdjustRound
global function EunAdjustRound(Eun n1, integer adjustBy = 0, integer isMixed = NO_SUBTRACT_ADJUST)
    integer len
    sequence ret
    if length(n1[1]) = 0 then
        return n1
    end if
    len = n1[3]
    if adjustBy > 0 then
        len -= adjustBy
        if len < 0 then
            len = 0
        end if
    end if
    ret = AdjustRound(n1[1], n1[2], len, n1[4], isMixed)
    return ret
end function
