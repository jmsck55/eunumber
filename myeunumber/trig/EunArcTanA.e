-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/common.e
include ../../eunumber/minieun/defaults.e
include ../../eunumber/minieun/usermisc.e
include ../../eunumber/minieun/AddExp.e
include ../../eunumber/minieun/Multiply.e
include ../../eunumber/minieun/Divide.e
include ../../eunumber/minieun/returntouser.e
include ../../eunumber/minieun/nanosleep.e
include ../../eunumber/minieun/AdjustRound.e
include ../../eunumber/minieun/Eun.e

include arcTan.e


-- Begin ArcTanExpA()
--                z        +inf         n             2kz^2
-- arctan(z) = ------- * Sumation of Product of --------------------
--             1 + z^2     n=0         k=1      (2k + 1) * (1 + z^2)
--
-- (The term in the sum for n = 0 is the empty product, so is 1.)
--
-- Expanded, it would look like this: (first you do the Product, then you do the Sumation)
--
-- arctan(z) = (z / (1 + z^2)) * [  ] ...
--
-- Alternate forms (from wolframalpha.com):
-- a = z
-- (2 a^2 k)/(2 a^2 k + a^2 + 2 k + 1)
-- (2 a^2 k)/((2 a^2 + 2) k + a^2 + 1)
-- (2 a^2 k)/(a^2 (2 k + 1) + 2 k + 1)
-- a^2/(a^2 + 1) - a^2/((a^2 + 1) (2 k + 1))
-- k = 1 to 4 == product_(k=1)^4(a^2/(a^2 + 1) - a^2/((a^2 + 1) (2 k + 1))) = (128 a^8)/(315 (a^2 + 1)^4)
--
-- z/(1+z^2) * The Sum of:
-- 0: product_(k=1)^0(a^2/(a^2 + 1) - a^2/((a^2 + 1) (2 k + 1))) = 1
-- 1: product_(k=1)^1(a^2/(a^2 + 1) - a^2/((a^2 + 1) (2 k + 1))) = (2 a^2)/(3 (a^2 + 1))
-- 2: product_(k=1)^2(a^2/(a^2 + 1) - a^2/((a^2 + 1) (2 k + 1))) = (8 a^4)/(15 (a^2 + 1)^2)
-- 3: product_(k=1)^3(a^2/(a^2 + 1) - a^2/((a^2 + 1) (2 k + 1))) = (16 a^6)/(35 (a^2 + 1)^3)
-- 4: product_(k=1)^4(a^2/(a^2 + 1) - a^2/((a^2 + 1) (2 k + 1))) = (128 a^8)/(315 (a^2 + 1)^4)
-- 5: product_(k=1)^5(a^2/(a^2 + 1) - a^2/((a^2 + 1) (2 k + 1))) = (256 a^10)/(693 (a^2 + 1)^5)
-- 6: product_(k=1)^6(a^2/(a^2 + 1) - a^2/((a^2 + 1) (2 k + 1))) = (1024 a^12)/(3003 (a^2 + 1)^6)
-- 7: product_(k=1)^7(a^2/(a^2 + 1) - a^2/((a^2 + 1) (2 k + 1))) = (2048 a^14)/(6435 (a^2 + 1)^7)
-- 8: product_(k=1)^8(a^2/(a^2 + 1) - a^2/((a^2 + 1) (2 k + 1))) = (32768 a^16)/(109395 (a^2 + 1)^8)
-- [9..inf]
-- 1, 3, 15, 35, 315, 693, 3003, 6435, 109395, 230945, 969969, 2028117, 16900975, 35102025, 145422675, 300540195, 9917826435, 20419054425, 83945001525, 172308161025, 1412926920405, 2893136075115, 11835556670925, ...
--
-- b = (a^2)/(a^2 + 1)
-- (a^2/(a^2 + 1) - a^2/((a^2 + 1) (2 k + 1))) == b - (b / (2k + 1)) == (2k * b) / (2k + 1)
--
-- Use: product of:
-- b - (b / (2 * k + 1))
--
-- b = (z^2)/(z^2 + 1)
--  NOTE: b is less than 1.
-- arctan(z) = (b / z) * Sumation(n=0 to inf) of Product(k=1 to 'n') of (b - (b / (2 * k + 1)))
--
-- Step0: ('z' can be complex)
-- a0 = z^2 + 1
-- a0 = z / a0 -- store, will use at ending
-- b = a0 * z -- store
-- tmp = 1, for comparing purposes.
-- prod = 1 -- 0th iteration
-- sum = prod -- 0th iteration
-- (n = 1) -- start of 1st iteration
-- k2 = 2
--
-- Step1: repeat until tmp is an infinitesimal, a value approaching zero.
-- (b - b/(2k + 1))
-- k2 += 1
-- tmp = b/k2
-- k2 += 1
-- tmp = b - tmp
-- prod *= tmp
-- sum += prod
-- (n += 1)
--
-- Step2: exit out of the while loop above,
-- a0 *= sum
-- return a0
--
-- End ArcTanExpA()

--TODO: Write a complex version of ArcTanExpA().


global function ArcTanExpA(sequence n1, integer exp1, TargetLength targetLength, AtomRadix radix)
-- b = (z^2)/(z^2 + 1)
--  NOTE: b is less than 1.
-- arctan(z) = (b / z) * Sumation(n=0 to inf) of Product(k=1 to 'n') of (b - (b / (2 * k + 1)))
--
-- Step0: ('z' can be complex)
-- a0 = z^2 + 1
-- a0 = z / a0 -- store, will use at ending
-- b = a0 * z -- store
-- tmp = 1, for comparing purposes.
-- prod = 1 -- 0th iteration
-- sum = prod -- 0th iteration
-- (n = 1) -- start of 1st iteration
-- k2 = 2
--
-- Step1: repeat until tmp is an infinitesimal, a value approaching zero.
-- (b - b/(2k + 1))
-- k2 += 1
-- tmp = b/k2
-- k2 += 1
-- tmp = b - tmp
-- prod *= tmp
-- sum += prod
-- (n += 1)
--
-- Step2: exit out of the while loop above,
-- a0 *= sum
-- return a0
--
    sequence a, b, tmp, prod, sum, k2, lookat, s
    integer protoTargetLength, moreAccuracy
    arcTanHowComplete = {1, 0, {}}
    if arcTanMoreAccuracy >= 0 then
        moreAccuracy = arcTanMoreAccuracy
    elsif calculationSpeed then
        moreAccuracy = Ceil(targetLength / calculationSpeed)
    else
        moreAccuracy = 0 -- changed to 0
    end if
    -- targetLength += adjustPrecision
    protoTargetLength = targetLength + moreAccuracy + 1
    -- Step0:
    a = SquaredExp(n1, exp1, protoTargetLength, radix)
    a = AddExp(a[1], a[2], {1}, 0, protoTargetLength, radix)
    a = DivideExp(n1, exp1, a[1], a[2], protoTargetLength, radix)
    b = MultiplyExp(n1, exp1, a[1], a[2], protoTargetLength, radix)
    tmp = {{1}, 0}
    prod = tmp
    sum = tmp
    -- ret = tmp
    k2 = {{2}, 0}
    -- Step1:
    lookat = {}
    calculating = ID_ArcTan -- begin calculating in a loop
    arcTanCount = 1
    while calculating and arcTanCount <= arcTanIter do
    -- for n = 1 to arcTanIter do -- NOTE: b is less than 1.
        k2 = AddExp(k2[1], k2[2], {1}, 0, protoTargetLength, radix)
        tmp = DivideExp(b[1], b[2], k2[1], k2[2], protoTargetLength, radix)
        k2 = AddExp(k2[1], k2[2], {1}, 0, protoTargetLength, radix)
        tmp = SubtractExp(b[1], b[2], tmp[1], tmp[2], protoTargetLength, radix)
        prod = MultiplyExp(prod[1], prod[2], tmp[1], tmp[2], protoTargetLength, radix)
        --lookat = sum
        sum = AddExp(prod[1], prod[2], sum[1], sum[2], protoTargetLength, radix)
        --ret = sum
        -- if useExtraAdjustRound then
        --     ret = AdjustRound(ret[1], ret[2], targetLength + adjustRound, radix, NO_SUBTRACT_ADJUST)
        -- end if
        -- if ret[2] = lookat[2] then
        --     arcTanHowComplete = Equaln(ret[1], lookat[1], arcTanHowComplete[1]) -- , targetLength - adjustRound)
        --     if arcTanHowComplete[1] > targetLength + 1 or arcTanHowComplete[1] = arcTanHowComplete[2] then
        --     -- if equal(ret[1], lookat[1]) then
        --         exit
        --     end if
        -- end if
        --if tmp[2] < protoTargetLength then
        --      arcTanCount = n
        --      exit
        --end if
        s = ReturnToUserCallBack(ID_ArcTan, arcTanHowComplete, targetLength, sum, lookat, radix)
        lookat = s[2]
        arcTanHowComplete = s[3]
        if s[1] then
            exit
        end if
        arcTanCount += 1
ifdef not NO_SLEEP_OPTION then
        sleep(nanoSleep)
end ifdef
    end while
    -- end for
    if arcTanCount = arcTanIter then
        printf(1, "Error %d\n", 3)
        abort(1/0)
    end if
    -- Step2: exit out of the while loop above,
    a = MultiplyExp(a[1], a[2], sum[1], sum[2], protoTargetLength, radix)
    s = ReturnToUserCallBack(ID_ArcTan, {}, targetLength, a, lookat, radix) -- {} means, don't actually compare
    a = s[2]
    -- targetLength -= adjustPrecision
    a = AdjustRound(a[1], a[2], targetLength, a[4], NO_SUBTRACT_ADJUST)
    return a
end function

global function EunArcTanA(Eun a)
    return ArcTanExpA(a[1], a[2], a[3], a[4])
end function
