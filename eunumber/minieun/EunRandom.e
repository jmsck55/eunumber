-- Copyright (c) 2016-2023 James Cook
-- Random functions for EuNumber.
-- include eunumber/eunrandom.e

namespace random

public include std/rand.e

include ../array/Borrow.e
include ../array/Negate.e
include Common.e
include Eun.e
include TrimZeros.e

-- Rand functions:

global function GetRand()
    return get_rand()
end function

global procedure SetRand(atom a, atom b)
    set_rand({a, b})
end procedure

global procedure ResetRand()
    set_rand({})
end procedure

type Round3(integer i)
    return i >= 0 and i <= 5
end type

global function InaccurateFill(sequence n1, integer starting = length(n1) + 1, TargetLength targetLength, PositiveScalar radix, Round3 roundingRules = 0) -- roundingRules = 0 means don't round.
--NOTE: Supply "roundingRules" with an integer from 0 to 5.
-- global constant ROUND_INF = 1 -- Round towards +infinity or -infinity, (positive or negative infinity)
-- global constant ROUND_ZERO = 2 -- Round towards zero
-- global constant ROUND_TRUNCATE = 3 -- Don't round, truncate
-- global constant ROUND_POS_INF = 4 -- Round towards positive +infinity
-- global constant ROUND_NEG_INF = 5 -- Round towards negative -infinity
    sequence tmp
    integer isNeg, sign
    if starting > targetLength then
        return n1
    end if
    --if starting <= targetLength then
        starting -= 1
        if starting <= 0 then
            n1 = {}
        elsif starting < length(n1) then
            n1 = n1[1..starting]
        else
            n1 = n1 & repeat(0, starting - length(n1))
        end if
    --end if
    if roundingRules = ROUND_TRUNCATE then
        return n1
    end if
    tmp = rand(repeat(radix, targetLength - length(n1))) - 1
    isNeg = -1
    if length(n1) then
        sign = n1[1] < 0 -- if n1 is negative
        switch roundingRules do
            case ROUND_INF then
                isNeg = sign
            case ROUND_ZERO then
                isNeg = not sign
            case else
                -- do nothing
        end switch
    else
        sign = -1 -- n1's value is zero.
    end if
    if isNeg = -1 then
        switch roundingRules do
            case ROUND_POS_INF then
                isNeg = FALSE
            case ROUND_NEG_INF then
                isNeg = TRUE
            case else -- default (roundingRules = 0)
                isNeg = rand(2) - 1
        end switch
    end if
    if isNeg then
    -- if length(n1) and n1[1] < 0 then
        tmp = Negate(tmp)
    end if
    tmp = n1 & tmp
    if sign != -1 then
        if sign xor isNeg then -- if isMixed then
            if sign then
                tmp = NegativeBorrow(tmp, radix)
            else
                tmp = Borrow(tmp, radix)
            end if
        end if
    end if
    return tmp
end function

global function InaccurateFillExp(sequence n1, integer exp1, TargetLength targetLength, PositiveScalar radix, integer exp0, Round3 roundingRules = ROUND)
    integer oldlen
    n1 = InaccurateFill(n1, exp1 - exp0 + 1, targetLength, radix, roundingRules)
    if exp0 > exp1 then
        exp1 = exp0
    end if
    oldlen = length(n1)
    if oldlen then
        if n1[1] = 0 then
            n1 = TrimLeadingZeros(n1)
            exp1 += (length(n1) - (oldlen))
        end if
    end if
    return NewEun(n1, exp1, targetLength, radix)
end function

global function EunInaccurateFill(Eun a, integer exp0, Round3 roundingRules = ROUND)
    return InaccurateFillExp(a[1], a[2], a[3], a[4], exp0, roundingRules)
end function

global function EunInaccurateSigDigits(Eun a, integer sigDigits, Round3 roundingRules = ROUND)
    return EunInaccurateFill(a, a[2] - sigDigits, roundingRules)
end function

