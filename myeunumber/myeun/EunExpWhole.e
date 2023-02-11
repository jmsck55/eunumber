-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/nanosleep.e
include ../../eunumber/minieun/common.e
include ../../eunumber/minieun/Eun.e
include ../../eunumber/minieun/ConvertExp.e
include ../../eunumber/minieun/comparefuncs.e
include ../../eunumber/minieun/AddExp.e
include ../../eunumber/minieun/Divide.e
include ../../eunumber/minieun/AdjustRound.e
include ../../eunumber/array/negate.e
include ../../eunumber/eun/EunMultiply.e
include ../../eunumber/eun/EunMultiplicativeInverse.e


global function Remainder2Exp(sequence n1, integer exp1)
-- returns 1 or 0
    integer n
    n = exp1 + 1 -- reminder.
    if n < 1 then
        return 0
    end if
    if n > length(n1) then
        return 0
    end if
    return remainder(n1[n], 2)
end function

global sequence expWholeHowComplete = {0, -1}

global function GetExpWholeHowCompleteMin()
    return expWholeHowComplete[1]
end function

global function GetExpWholeHowCompleteMax()
    return expWholeHowComplete[2]
end function

global function EunExpWhole(Eun u, Eun m)
-- exp function for whole numbers
    sequence q, prod, current
    integer targetLength, radix, isNeg
    expWholeHowComplete = {0, -1}
    current = u
    targetLength = current[3]
    radix = current[4]
    if m[4] != radix then
        q = EunConvert(m, radix, targetLength)
    else
        q = m
        q[3] = targetLength
    end if
    isNeg = IsNegative(q[1])
    if isNeg then -- Take the absolute value of the number, while saving isNeg.
        q[1] = Negate(q[1])
    end if
    prod = {{1}, 0, targetLength, radix}
    while CompareExp(q[1], q[2], {}, 0) = 1 do
        expWholeHowComplete = {q[2], -1}
        if Remainder2Exp(q[1], q[2]) = 1 then
            prod = EunMultiply(prod, current)
            q = AddExp({-1}, 0, q[1], q[2], targetLength, radix)
        end if
        current = EunSquared(current)
        q = DivideExp(q[1], q[2], {2}, 0, targetLength, radix)
ifdef not NO_SLEEP_OPTION then
        sleep(nanoSleep)
end ifdef
    end while
--     if CompareExp(q[1], q[2], {}, 0) = 1 then
--     else
--         while CompareExp(q[1], q[2], {}, 0) = -1 do
--             expWholeHowComplete = {q[2], -1}
--             if Remainder2Exp(q[1], q[2]) = -1 then
--                 prod = EunDivide(prod, current)
--                 q = AddExp({1}, 0, q[1], q[2], targetLength, radix)
--             end if
--             current = EunMultiply(current, current)
--             q = DivideExp(q[1], q[2], {2}, 0, targetLength, radix)
-- ifdef not NO_SLEEP_OPTION then
--             sleep(nanoSleep)
-- end ifdef
--         end while
--     end if
    if isNeg then
        prod = EunMultiplicativeInverse(prod)
    end if
    prod = AdjustRound(prod[1], prod[2], m[3], prod[4], NO_SUBTRACT_ADJUST)
    return prod
end function
