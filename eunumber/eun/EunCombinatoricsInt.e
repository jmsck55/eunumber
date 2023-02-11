-- Copyright (c) 2016-2023 James Cook

include ../minieun/Eun.e
include ../minieun/Defaults.e
include ../minieun/AddExp.e

include EunAdjustRound.e
include EunIntPart.e

-- EunCombInt:

global type UpOneRange(integer i)
    return i <= 1 and i >= -1
end type

global function EunCombInt(Eun n1, integer adjustBy = 0, UpOneRange upOne = 0) -- upOne should be: 1, 0, or -1
-- if there is any fraction part, add or subtract one, away from zero,
-- or ceil, if upOne == 1, add one towards positive infinity, if "up = 1"
-- or floor, if upOne == -1, add one towards negative infinity, if "up = -1"
    integer len, exponent
    n1 = EunAdjustRound(n1, adjustBy)
    len = length(n1[1])
    if len then -- if len > 0 then
        exponent = n1[2] + integerModeFloat
        n1 = EunIntPart(n1)
        if (exponent < 0) or (exponent + 1 < len) then
            -- add one, same sign
            if upOne = 0 then
                if n1[1][1] < 0 then
                    upOne = -1
                else
                    upOne = 1
                end if
            end if
            n1 = AddExp(n1[1], n1[2], {upOne}, - (integerModeFloat), n1[3], n1[4])
        end if
    end if
    return n1
end function

global function EunCombinatoricsInt(sequence n1, integer adjustBy = 0, integer upOne = 0)
    return EunCombInt(n1, adjustBy, upOne)
end function
