-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/common.e
include ../../eunumber/minieun/Eun.e
include ../../eunumber/minieun/defaults.e
include ../../eunumber/minieun/usermisc.e
include ../../eunumber/minieun/Multiply.e
include ../../eunumber/minieun/returntouser.e
include ../../eunumber/minieun/Divide.e
include ../../eunumber/minieun/AddExp.e
include ../../eunumber/minieun/nanosleep.e
include ../../eunumber/minieun/AdjustRound.e

include trighowcomplete.e

-- !!! Remember to use Radians (Rad) on these functions !!!

global PositiveOption sinMoreAccuracy = -1 -- if -1, then use calculationSpeed

global procedure SetSinMoreAccuracy(PositiveOption i)
    sinMoreAccuracy = i
end procedure
global function GetSinMoreAccuracy()
    return sinMoreAccuracy
end function

global integer sinIter = 1000000000 -- 500
global integer sinIterCount = 0

global constant ID_Sine = 7

global function SinExp(sequence n1, integer exp1, TargetLength targetLength, AtomRadix radix, integer inside = 0)
-- sine(x) = x - ((x^3)/(3!)) + ((x^5)/(5!)) - ((x^7)/(7!)) + ((x^9)/(9!)) - ...
    -- Cases: 0 equals zero (0)
    -- Range: -PI/2 to PI/2, inclusive
    sequence a, b, tmp, xSquared, lookat, ret, s
    integer step, protoTargetLength, moreAccuracy
    if length(n1) = 0 then
        trigHowComplete = {0, 0, {}}
        return NewEun({}, 0, targetLength, radix)
    end if
    trigHowComplete = {1, 0, {}}
    if sinMoreAccuracy >= 0 then
        moreAccuracy = sinMoreAccuracy
    elsif calculationSpeed then
        moreAccuracy = Ceil(targetLength / calculationSpeed)
    else
        moreAccuracy = 0 -- changed to 0
    end if
    -- targetLength += adjustPrecision
    protoTargetLength = targetLength + moreAccuracy + 1
    step = 1 -- SinExp() uses 1
    xSquared = SquaredExp(n1, exp1, protoTargetLength, radix)
    a = {n1, exp1} -- a is the numerator, SinExp() starts with x.
    b = {{1}, 0} -- b is the denominator.
    -- copy x to ans:
    -- ret = a -- in SinExp(), ret starts with x.
    ret = NewEun(n1, exp1, targetLength, radix)
    lookat = {}
    if inside then
        calculating = inside
    else
        calculating = ID_Sine -- begin calculating
    end if
    sinIterCount = 1 -- must be one (1), used in loop.
    while calculating and sinIterCount <= sinIter do
    -- for i = 1 to sinIter do
        -- first step is 3, for SinExp()
        step += 2
        tmp = MultiplyExp({step - 1}, 0, {step}, 0, protoTargetLength, radix)
        b = MultiplyExp(b[1], b[2], tmp[1], tmp[2], protoTargetLength, radix)
        a = MultiplyExp(a[1], a[2], xSquared[1], xSquared[2], protoTargetLength, radix)
        tmp = DivideExp(a[1], a[2], b[1], b[2], protoTargetLength, radix)
        --lookat = ret
        if IsPositiveOdd(sinIterCount) then
            -- Subtract
            ret = SubtractExp(ret[1], ret[2], tmp[1], tmp[2], protoTargetLength, radix)
        else
            ret = AddExp(ret[1], ret[2], tmp[1], tmp[2], protoTargetLength, radix)
        end if
        --n1 = ret[1]
        --exp1 = ret[2]
        -- if useExtraAdjustRound then
        --     ret = AdjustRound(n1, exp1, targetLength + adjustRound, radix, NO_SUBTRACT_ADJUST)
        -- end if
        -- if ret[2] = lookat[2] then
        --     trigHowComplete = Equaln(ret[1], lookat[1], trigHowComplete[1]) -- , targetLength - adjustRound)
        --     if trigHowComplete[1] > targetLength + 1 or trigHowComplete[1] = trigHowComplete[2] then
        --     -- if equal(ret[1], lookat[1]) then
        --         exit
        --     end if
        -- end if
        s = ReturnToUserCallBack(ID_Sine, trigHowComplete, targetLength, ret, lookat, radix)
        lookat = s[2]
        trigHowComplete = s[3]
        if s[1] then
            exit
        end if
        sinIterCount += 1
ifdef not NO_SLEEP_OPTION then
        sleep(nanoSleep)
end ifdef
    end while
    -- end for
    if sinIterCount = sinIter then
        printf(1, "Error %d\n", 3)
        abort(1/0)
    end if
    -- targetLength -= adjustPrecision
    ret = AdjustRound(ret[1], ret[2], targetLength, radix, NO_SUBTRACT_ADJUST)
    return ret
end function
