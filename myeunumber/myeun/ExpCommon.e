-- Copyright (c) 2023 James Cook
-- ExpCommon.e file of EuNumber.

-- -- Exponentiation, e^x
-- 
-- "ln" is log[e](), "log" is log[10]()
-- 
-- e^x = 10^n, solve for x
-- 10 = radix
-- 
-- e^(n * ln(10)) = 10^n
-- 10^(x * log(e)) = e^x
-- 
-- n * ln(10) = x
-- 
-- (e^a) * (e^b) = e^(a + b)
-- 
-- e^(m + n * ln(10)) = (e^m) * (e^(n * ln(10))) = (e^m) * (10^n)
-- 
-- x - m = n * ln(10)
-- 
-- x - n * ln(10) = m, floor(x / ln(10)) = n
-- 
-- n = (x - m) / (ln(10))
-- 
-- ----
-- 
-- x = 55, n = floor(x / ln(10)) = floor(55 / ln(10)) = 23
-- 
-- m = x - n * ln(10) = 55 - 23 * ln(10) = 2.040542861
-- 
-- e^x = (e^m) * (10^n) = 7.694785265 * 10^23 = e^55
-- 
-- 10 can be any radix.
-- n becomes the exponent.
-- 
-- ----
-- 
-- 1. Precalculate:
-- c = ln(radix)
-- 
-- 2. In exp(x), Eun's:
-- n = floor( x / c )
-- 
-- 3. Do the exponentiation:
-- numArray = e^( x - (n * c) )
-- 
-- 4. Return the Eun:
-- {numArray, exponent, targetLength = 70, radix = 10}


include ../../eunumber/minieun/common.e
include ../../eunumber/minieun/defaults.e
include ../../eunumber/minieun/AdjustRound.e
include EunLog.e


global sequence lnRadix = {}

global function SwapLnRadix(sequence s = lnRadix)
    object oldvalue = lnRadix
    lnRadix = s
    return oldvalue
end function

global function GetLnRadix(TargetLength targetLength = defaultTargetLength, AtomRadix radix = defaultRadix)
    if not length(lnRadix) or not length(lnRadix[1]) or lnRadix[3] <= targetLength or lnRadix[4] != radix then
        lnRadix = EunLog({{1}, 1, targetLength + 1, radix})
    end if
    return AdjustRound(lnRadix[1], lnRadix[2], targetLength, radix, NO_SUBTRACT_ADJUST)
end function


include ../../eunumber/eun/Remainder.e
include ../../eunumber/eun/EunAdd.e
include ../../eunumber/eun/EunDivide.e
include ../../eunumber/eun/EunMultiply.e


global PositiveInteger expPowerOfTwo = 3 -- 0 to turn off feature, 1 or above to use feature.

global function EunExpId(integer eunExpId, Eun x)
    sequence c, tmp
    integer isNeg = IsNegative(x[1])
    -- 1. Precalculate:
    -- c = ln(radix)
    c = GetLnRadix(x[3], x[4])
    -- 2. In exp(x), Eun's:
    -- n = floor( x / c )
    tmp = EunFloor(EunDivide(x, c))
    -- 3. Do the exponentiation:
    -- numArray = e^( x - (n * c) )
    -- 3.1. Subtract
    -- x - (n * c)
    c = EunSubtract(x, EunMultiply(tmp, c))
    -- 3.2. Divide by a power of two:
    -- e^(x/(2^n))^(2^n)
    c = EunDivide(x, AdjustRound({power(2, expPowerOfTwo)}, 0, x[3], x[4], CARRY_ADJUST))
    -- 3.3. Call Exp function:
    c = call_func(eunExpId, {c})
    -- 3.3. Square the result, n times:
    for i = 1 to expPowerOfTwo do
        c = EunSquared(c)
    end for
    -- 4. Return the Eun:
    -- {numArray, exponent, targetLength = 70, radix = 10}
    return c
end function

