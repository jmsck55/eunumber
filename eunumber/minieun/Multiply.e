-- Copyright (c) 2016-2023 James Cook
-- Multiply functions of EuNumber.
-- include eunumber/Multiply.e

namespace multiply

include NanoSleep.e
include UserMisc.e
include Common.e
include Defaults.e
include AdjustRound.e

-- Three Multiply methods:

ifdef not MULTIPLY_USER then
with define MULTIPLY_LOW_POWER
end ifdef

--    MULTIPLY_POWER_HUNGRY = 0, -- legacy, uses brute force method, consumes the most energy or power.
--    MULTIPLY_OLDER = 1, -- works for most processors.
--    MULTIPLY_LOW_POWER = 2 -- You can try this one on new computers.

-- global procedure CheckForOverFlow(sequence numArray, sequence function_name)
--     if IsPositive(numArray) then
--         for i = 1 to length(numArray) do
--             if numArray[i] > DOUBLE_INT_MAX then
--                 printf(1, "Error, overflow in %s() function.\n", {function_name})
--                 abort(1/0)
--             end if
--         end for
--     else
--         for i = 1 to length(numArray) do
--             if numArray[i] < DOUBLE_INT_MIN then
--                 printf(1, "Error, underflow in %s() function.\n", {function_name})
--                 abort(1/0)
--             end if
--         end for
--     end if
-- end procedure

-- ifdef MULTIPLY_POWER_HUNGRY then
-- 
-- global function Multiply(sequence n1, sequence n2)
--     integer f, len
--     atom g
--     sequence numArray
--     if length(n1) = 0 or length(n2) = 0 then
--         return {}
--     elsif length(n1) = 1 then
--         return n2 * n1[1]
--     elsif length(n2) = 1 then
--         return n1 * n2[1]
--     end if
-- -- This method may be faster:
--     len = length(n1) + length(n2) - 1 -- make sure len is set properly.
--     numArray = repeat(0, len)
--     for i = 1 to length(n1) do
--         f = i
--         g = n1[i]
--         for h = 1 to length(n2) do
--             numArray[f] += g * n2[h]
--             f += 1
-- ifdef not NO_SLEEP_OPTION then
--             sleep(nanoSleep)
-- end ifdef
--         end for
-- ifdef not NO_SLEEP_OPTION then
--         sleep(nanoSleep)
-- end ifdef
--     end for
--     -- CheckForOverFlow(numArray, "MultiplyPowerHungryMethod")
--     return numArray
-- end function
-- 
-- end ifdef

ifdef MULTIPLY_OLDER then

global function Multiply(sequence n1, sequence n2, integer len = length(n1) + length(n2) - 1)
    integer f, j
    atom g
    sequence numArray
    if len <= 0 or length(n1) = 0 or length(n2) = 0 then
        return {}
    elsif length(n1) = 1 then
        return n2 * n1[1]
    elsif length(n2) = 1 then
        return n1 * n2[1]
    end if
    -- len = length(n1) + length(n2) - 1 -- len is set by the function call.
    numArray = repeat(0, len)
    f = length(n2)
    for i = 1 to length(n1) do
        g = n1[i]
        j = 1
        for h = i to min(len, f) do
            numArray[h] += g * n2[j]
            j += 1
ifdef not NO_SLEEP_OPTION then
            sleep(nanoSleep)
end ifdef
        end for
        f += 1
ifdef not NO_SLEEP_OPTION then
        sleep(nanoSleep)
end ifdef
    end for
    -- CheckForOverFlow(numArray, "MultiplyOldProcessorsMethod")
    return numArray
end function

end ifdef

ifdef MULTIPLY_LOW_POWER then

global function Multiply(sequence n1, sequence n2, integer len = length(n1) + length(n2) - 1)
    integer f, j
    atom g
    sequence numArray
    if len <= 0 or length(n1) = 0 or length(n2) = 0 then
        return {}
    elsif length(n1) = 1 then
        return n2 * n1[1]
    elsif length(n2) = 1 then
        return n1 * n2[1]
    end if
    -- len = length(n1) + length(n2) - 1 -- len is set by the function call.
    numArray = repeat(0, len)
    f = 1
    if len > length(n2) then
        for k = length(n2) to len do
        -- for i = 1 to length(n1) do
            g = n1[f]
            j = 1
            -- k = iff(len < f1, len, f1)
            for h = f to k do
                numArray[h] += g * n2[j]
                j += 1
ifdef not NO_SLEEP_OPTION then
                sleep(nanoSleep)
end ifdef
            end for
            f += 1
ifdef not NO_SLEEP_OPTION then
            sleep(nanoSleep)
end ifdef
        end for
    end if
    for i = f to length(n1) do
        g = n1[i]
        j = 1
        -- k = iff(len < f1, len, f1)
        for h = i to len do
            numArray[h] += g * n2[j]
            j += 1
ifdef not NO_SLEEP_OPTION then
            sleep(nanoSleep)
end ifdef
        end for
        f += 1
ifdef not NO_SLEEP_OPTION then
        sleep(nanoSleep)
end ifdef
    end for
    -- CheckForOverFlow(numArray, "MultiplyLowPowerMethod")
    return numArray
end function

end ifdef

global function Squared(sequence n1)
    return Multiply(n1, n1) -- multiply it by its self, once
end function

-- integer multLastLen = 0
-- atom multLastRadix = 0
-- integer multLen
-- atom multlogt, multlogr

PositiveInteger baseMultiplyTargetLength = 1 -- might need to be a constant.

-- global procedure SetBaseMultiplyTargetLength(integer i)
--     baseMultiplyTargetLength = i
-- end procedure
-- 
-- global function GetBaseMultiplyTargetLength()
--     return baseMultiplyTargetLength
-- end function

global function MultiplyExp(sequence n1, integer exp1, sequence n2, integer exp2, TargetLength targetLength, AtomRadix radix) --, integer len = -2)
    sequence numArray, ret
    integer newTargetLength, exponent, len
    exponent = exp1 + exp2
    len = length(n1) + length(n2) - 1
    --if len < -1 then
        --integer flag
        if ROUND_TO_NEAREST_OPTION then
            newTargetLength = exponent + 1 + integerModeFloat
        else
            newTargetLength = targetLength
        end if
        newTargetLength += baseMultiplyTargetLength
        --flag = 0
        --if multLastLen != newTargetLength then
        --      multLastLen = newTargetLength
        --      multlogt = log(newTargetLength)
        --      flag = 1
        --end if
        --if multLastRadix != radix then
        --      multLastRadix = radix
        --      multlogr = log(radix)
        --      flag = 1
        --end if
        --if flag then
        --      multLen = newTargetLength -- iff(length(n1) > length(n2), length(n1), length(n2))
        --      multLen += Ceil(multlogt / multlogr)
        --      multLen += 1
        --end if
        if newTargetLength < len then
            len = newTargetLength
        end if
        numArray = Multiply(n1, n2, len)
    --end if
    ret = AdjustRound(numArray, exponent, targetLength, radix, FALSE) -- TRUE for backwards compatability
    return ret
end function

global function SquaredExp(sequence n1, integer exp1, TargetLength targetLength, AtomRadix radix) --, integer len = -2)
    return MultiplyExp(n1, exp1, n1, exp1, targetLength, radix) --, len)
end function

