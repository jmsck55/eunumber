-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/Eun.e
--include ../../eunumber/minieun/common.e
--include ../../eunumber/minieun/WholeFracParts.e
include ../../eunumber/eun/EunMultiply.e
--include adjustPrecision.e
include GetE.e
include EunExpWhole.e
include ExpExp.e


global function EunExp(Eun n1)
--
-- ExpExp() doesn't like large numbers.
-- so, x = 1/x; x = exp^x; x = 1/x; return x;
--
--      e^(a+b) <=> e^(a) * e^(b)
--      e^(whole+frac) <=> EunExpWhole(E,whole) * EunExp(fract)
--
    -- get the whole and fractional parts of the number:
    sequence num, frac
    integer size
    num = n1
    size = num[2] + 1
    -- factor out (-1), use MultiplicativeInverse (1/x) later
    --isNeg = IsNegative(num[1])
    --if isNeg then -- Take the absolute value of the number, while saving isNeg.
    --    num[1] = Negate(num[1])
    --end if
    frac = num
    if size > 0 then
        if size < length(num[1]) then
            frac[1] = num[1][size + 1..$] -- copy this first.
            frac[2] = -1
            num[1] = num[1][1..size] -- then subscript this.
        else
            frac = {}
        end if
        --num[3] += adjustPrecision
        num = EunExpWhole(GetE(num[3], num[4]), num) --here
        --num[3] -= adjustPrecision
    else
        num = {}
    end if
    if length(frac) then
        frac = ExpExp(frac[1], frac[2], frac[3], frac[4], 0)
        if length(num) then
            num = EunMultiply(num, frac)
        else
            num = frac
        end if
    end if
    --if isNeg then
    --    num = EunMultiplicativeInverse(num)
    --end if
    -- num = AdjustRound(num[1], num[2], num[3], num[4], NO_SUBTRACT_ADJUST)
    return num
end function

global constant eunExpRID = routine_id("EunExp")


include ExpCommon.e


global function EunExpC(Eun x)
    return EunExpId(eunExpRID, x)
end function

