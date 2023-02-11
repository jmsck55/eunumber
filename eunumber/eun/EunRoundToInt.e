-- Copyright (c) 2016-2023 James Cook


include ../minieun/Eun.e
include ../minieun/Common.e
include ../minieun/Defaults.e
include ../minieun/MultiplicativeInverse.e
include EunFracPart.e
include EunCompare.e
include EunNegate.e
include EunRoundSignificantDigits.e
include EunCombinatoricsInt.e

-- EunRoundToInt
global function EunRoundToInt(Eun n1, integer intModeFloat = integerModeFloat) -- Round to nearest integer
    integer tmp
    if ROUND_TO_NEAREST_OPTION then
        n1[2] += intModeFloat
    end if
    if n1[2] < -1 then
        n1[1] = {}
        n1[2] = 0
    else
        n1[2] += 1
        n1 = EunCombInt(n1)
        tmp = n1[2]
        n1[2] -= 1
        n1 = EunRoundSig(n1, tmp)
        if length(n1[1]) > tmp then
            tmp = IsNegative(n1[1])
            if tmp then
                n1 = EunNegate(n1)
            end if
            if 1 = EunCompare(EunFracPart(n1),
                    MultiplicativeInverseExp({2}, 0, n1[3], n1[4])) then
                if tmp then
                    tmp = -1
                else
                    tmp = 1
                end if
                n1[1] = {tmp} -- one digit value (1 or -1 in this case)
                n1[2] = 0
            else
                n1[1] = {} -- value for zero.
                n1[2] = 0
            end if
        end if
    end if
    if ROUND_TO_NEAREST_OPTION then
        n1[2] -= intModeFloat
    end if
    return n1
end function
