-- Copyright (c) 2016-2023 James Cook
-- ConvertExp function of EuNumber.
-- include eunumber/ConvertExp.e

namespace convertexp

include ../array/ConvertRadix.e
include Common.e
include AdjustRound.e
include Divide.e
include TrimZeros.e
include Eun.e

global function ConvertExp(sequence n1, integer exp1, TargetLength targetLength, AtomRadix fromRadix, AtomRadix toRadix)
    sequence n2, n3, result
    integer exp2, exp3
    PositiveInteger d
    if fromRadix = toRadix then
        return AdjustRound(n1, exp1, targetLength, toRadix, NO_SUBTRACT_ADJUST)
    end if
    n1 = TrimTrailingZeros(n1)
    if length(n1) = 0 then
        result = {{}, 0, targetLength, toRadix}
        return result
    end if
    if length(n1) <= exp1 then
        n1 = n1 & repeat(0, (exp1 + 1) - length(n1))
    end if

-- Example:
-- 12.3 <=> 123 / 10
-- 1.23 <=> 123 / 100
-- 0.00123 <=> 123 / 100000
-- 123 <=> 123 / 1
-- 1230 <=> 1230 / 1
-- 12300 <=> 12300 / 1
-- convert both numerator and denominator to LCD (Least Common Denominator), then divide.

    n2 = ConvertRadix(n1, fromRadix, toRadix)
    exp2 = length(n2) - 1
    d = length(n1) - (exp1 + 1) -- it does work.
    if d then -- d is a PositiveInteger, d >= 0
        n3 = ConvertRadix({1} & repeat(0, d), fromRadix, toRadix)
        exp3 = length(n3) - 1
        result = DivideExp(n2, exp2, n3, exp3, targetLength, toRadix)
    else
        result = AdjustRound(n2, exp2, targetLength, toRadix, NO_SUBTRACT_ADJUST)
    end if
    return result
end function

-- EunConvert
global function EunConvert(Eun n1, AtomRadix toRadix, TargetLength targetLength)
    return ConvertExp(n1[1], n1[2], targetLength, n1[4], toRadix)
end function
