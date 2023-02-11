-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/common.e
include ../../eunumber/minieun/defaults.e
include ../../eunumber/minieun/usermisc.e
include ../../eunumber/minieun/returntouser.e
include ../../eunumber/minieun/nanosleep.e

include Complex.e
include ComplexAdd.e
include ComplexMultiply.e
include ComplexSquared.e
include ComplexDivide.e
include ComplexSubtract.e
include ComplexAdjustRound.e

-- ComplexArcTanA Function

global PositiveOption complexArcTanMoreAccuracy = -1 -- if -1, then use calculationSpeed

global procedure SetComplexArcTanMoreAccuracy(integer i)
    complexArcTanMoreAccuracy = i
end procedure
global function GetComplexArcTanMoreAccuracy()
    return complexArcTanMoreAccuracy
end function

global integer complexArcTanIter = 1000000000
global integer complexArcTanCount = 0

global sequence complexArcTanHowComplete = {{1, 0}, {1,0}}

global function GetComplexArcTanHowCompleteMin()
    return complexArcTanHowComplete[1]
end function

global function GetComplexArcTanHowCompleteMax()
    return complexArcTanHowComplete[2]
end function

global constant ID_ComplexArcTan = 11

global function ComplexArcTanA(Complex z)
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
    sequence a, b, tmp, prod, sum, k2, lookat, ret, one, s
    integer targetLength, protoTargetLength, protoMoreAccuracy
    atom radix
    complexArcTanHowComplete = repeat({1, 0, {}}, 2)
    targetLength = z[1][3]
    radix = z[1][4]
    if complexArcTanMoreAccuracy >= 0 then
        protoMoreAccuracy = complexArcTanMoreAccuracy
    elsif calculationSpeed then
        protoMoreAccuracy = Ceil(targetLength / calculationSpeed)
    else
        protoMoreAccuracy = 0 -- changed to 0
    end if
    protoTargetLength = targetLength + protoMoreAccuracy + 1
    z[REAL][3] = protoTargetLength
    z[IMAG][3] = protoTargetLength
    -- Step0:
    a = ComplexSquared(z)
    one = NewComplex({{1}, 0, protoTargetLength, radix}, {{}, 0, protoTargetLength, radix}) -- Complex one (1).
    a = ComplexAdd(a, one)
    a = ComplexDivide(z, a)
    b = ComplexMultiply(a, z) -- NOTE: b is less than 1.
    tmp = one
    prod = tmp
    sum = tmp
    ret = tmp
    k2 = ComplexAdd(one, one)
    -- Step1:
    lookat = repeat({}, 2)
    calculating = ID_ComplexArcTan -- begin calculating in a loop
    complexArcTanCount = 1
    while calculating and complexArcTanCount <= complexArcTanIter do
    -- for n = 1 to complexArcTanIter do
        k2 = ComplexAdd(k2, one)
        tmp = ComplexDivide(b, k2) -- k2 only has a real part
        k2 = ComplexAdd(k2, one)
        tmp = ComplexSubtract(b, tmp)
        prod = ComplexMultiply(prod, tmp)
        sum = ComplexAdd(prod, sum)
        --lookat = ret
        --ret = sum
        --if useExtraAdjustRound then
        --      ret = ComplexAdjustRound(ret)
        --end if
        -- if ret[REAL][2] = lookat[REAL][2] and ret[IMAG][2] = lookat[IMAG][2] then
        --     complexArcTanHowComplete = {
        --         Equaln(ret[REAL][1], lookat[REAL][1], complexArcTanHowComplete[REAL][1]), -- , targetLength - adjustRound),
        --         Equaln(ret[IMAG][1], lookat[IMAG][1], complexArcTanHowComplete[IMAG][1]) -- , targetLength - adjustRound)
        --     }
        --     if (complexArcTanHowComplete[REAL][1] > targetLength + 1 or complexArcTanHowComplete[REAL][1] = complexArcTanHowComplete[REAL][2])
        --     and (complexArcTanHowComplete[IMAG][1] > targetLength + 1 or complexArcTanHowComplete[IMAG][1] = complexArcTanHowComplete[IMAG][2]) then
        --     -- if equal(ret, lookat) then
        --         exit
        --     end if
        -- end if
        --if tmp[2] < protoTargetLength then
        --      complexArcTanCount = n
        --      exit
        --end if
        s = ReturnToUserCallBack(ID_ComplexArcTan, complexArcTanHowComplete, targetLength, sum, lookat, radix)
        lookat = s[2]
        complexArcTanHowComplete = s[3]
        if s[1] then
            exit
        end if
        complexArcTanCount += 1
ifdef not NO_SLEEP_OPTION then
        sleep(nanoSleep)
end ifdef
    end while
    -- end for
    if complexArcTanCount = complexArcTanIter then
        printf(1, "Error %d\n", 3)
        abort(1/0)
    end if
    -- Step2: exit out of the while loop above,
    a = ComplexMultiply(a, sum)
    a[REAL][3] = targetLength
    a[IMAG][3] = targetLength
    a = ComplexAdjustRound(a)
    return a
end function
