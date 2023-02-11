-- Copyright (c) 2016-2023 James Cook
-- Eun datatype functions of EuNumber.
-- include eunumber/Eun.e

namespace euntype

include Common.e
include Defaults.e
include MathConst.e
include UserMisc.e

-- Make sure our lengths and radixes are within safe limits for multiplication and carry.

global function GetMaxLengthForRadix(AtomRadix radix)
    atom d
    d = radix - 1
    return floor(INT_MAX / (d * d * 2))
end function

global function GetMaxRadixForLength(integer len)
    return sqrt(INT_MAX / (len * 2)) + 1
end function

global function CheckLengthAndRadix(integer len, AtomRadix radix)
    integer maxlen
    maxlen = GetMaxLengthForRadix(radix)
    return len <= maxlen
end function

-- Eun (type)

global type Eun(object x)
    if sequence(x) then
        if length(x) >= 4 and length(x) <= 6 then
        -- length can be either 4, 5, or 6
        --if length(x) >= 4 and length(x) <= 7 then
            if sequence(x[1]) then -- numArray (digits)
            if integer(x[2]) then -- exponent, leading digit is muliplied by radix raised to the power of exponent
            if TargetLength(x[3]) then -- targetLength
            if AtomRadix(x[4]) then -- radix
                if length(x) = 4 then
                    return TRUE
                end if
            if integer(x[5]) then -- true if rounded
                if length(x) = 5 then
                    return TRUE
                end if
            if integer(x[6]) then
                return x[6] >= 0
--                      if Round2(x[6]) then -- RoundingMethod
--                      if CalcSpeedType(x[7]) then -- calculationSpeed
--                              return x[7] <= x[3]
--                      end if
--                      end if
            end if
            end if
            end if
            end if
            end if
            end if
        end if
    end if
    return FALSE
end type

-- NewEun() function:

-- Use RoundFloat() and EunRoundDigits() if you are using a Double (non-Integer) for Radix.

global function RoundFloat(object a, integer correction = 4)
    return Round(a, power(2, 53 - correction))
end function

global function EunRoundDigits(Eun a, integer correction = 5 - floor(log(a[4]) / logTwo))
    a[1] = RoundFloat(a[1], correction)
    return a
end function

-- Set precision:

global function PrecisionToTargetLength(integer prec, atom radix = defaultRadix)
    -- returns targetLength
    return floor(prec * logTwo / log(radix)) + 1
    -- return Ceil(prec * logTwo / log(radix))
end function

global function SetPrecision(Eun n1, integer prec)
    integer targetLength
    targetLength = PrecisionToTargetLength(prec, n1[4])
    n1[3] = targetLength
    n1[6] = prec
    return n1
end function

--global function IsProperLengthAndRadix(TargetLength targetLength = defaultTargetLength, AtomRadix radix = defaultRadix)
--      if ROUND_TO_NEAREST_OPTION then
--              targetLength += adjustRound
--      else
--              targetLength -= adjustRound
--      end if
--      return (targetLength * power(radix - 1, 3) <= DOUBLE_INT_MAX)
--here
--end function

global Bool is_round_array = TRUE

global procedure SetIsRoundArray(integer i)
    is_round_array = i
end procedure

global function GetIsRoundArray()
    return is_round_array
end function

global function NewEun(
            sequence num = {},
            integer exp = 0,
            integer targetLength = defaultTargetLength,
            atom radix = defaultRadix,
            integer rounded = 0, --here, make into significantDigits, or positiveHalf and negativeHalf, or last digit before rounded last digit.
            integer prec = 0
--                      integer roundingMethod = ROUND_INF, --here, what about "round to nearest option" ???
--                      atom calculationSpeed = targetLength
        )
    if is_round_array then
        if not integer(radix) then
            num = RoundFloat(num)
        end if
        -- return AdjustRound(num, exp, targetLength, radix, NO_SUBTRACT_ADJUST)
    end if
    -- else
        Eun ret -- does type checking.
        if prec then
            targetLength = PrecisionToTargetLength(prec, radix)
            ret = {num, exp, targetLength, radix, rounded, prec}
        elsif rounded then
            ret = {num, exp, targetLength, radix, rounded}
        else
            ret = {num, exp, targetLength, radix}
        end if
        --ret = {num, exp, targetLength, radix, rounded, prec, roundingMethod, calculationSpeed}
        return ret
    -- end if
end function

-- Access Members

global function GetNumArray(Eun a)
    return a[1]
end function

global function GetExponent(Eun a)
    return a[2]
end function

global function GetTargetLength(Eun a)
    return a[3]
end function

global function GetRadix(Eun a)
    return a[4]
end function

global function GetRounded(Eun a)
    if length(a) >= 5 then
        return a[5]
    else
        return {}
    end if
end function

global function GetPrecision(Eun a)
    if length(a) >= 6 then
        return a[6]
    else
        return {}
    end if
end function

global function SetNumArray(Eun a, sequence n1)
    a[1] = n1
    return a
end function

global function SetExponent(Eun a, integer exp1)
    a[2] = exp1
    return a
end function

global function SetTargetLength(Eun a, integer targetLength)
    -- Use this instead of "GetMoreAccuratePrec()"
    a[3] = targetLength
    return a
end function

global function SetRadix(Eun a, atom radix)
    a[4] = radix
    return a
end function
