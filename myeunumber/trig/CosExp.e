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

global PositiveOption cosMoreAccuracy = -1 -- if -1, then use calculationSpeed

global procedure SetCosMoreAccuracy(PositiveOption i)
    cosMoreAccuracy = i
end procedure
global function GetCosMoreAccuracy()
    return cosMoreAccuracy
end function

global integer cosIter = 1000000000 -- 500
global integer cosIterCount = 0

global constant ID_Cosine = 8

global function CosExp(sequence n1, integer exp1, TargetLength targetLength, AtomRadix radix, integer inside = 0)
-- cos(x) = 1 - ((x^2)/(2!)) + ((x^4)/(4!)) - ((x^6)/(6!)) + ((x^8)/(8!)) - ...
    -- Range: -PI/2 to PI/2, exclusive
    sequence a, b, tmp, xSquared, lookat, ret, s
    integer step, protoTargetLength, moreAccuracy
    trigHowComplete = {1, 0, {}}
    if cosMoreAccuracy >= 0 then
        moreAccuracy = cosMoreAccuracy
    elsif calculationSpeed then
        moreAccuracy = Ceil(targetLength / calculationSpeed)
    else
        moreAccuracy = 0 -- changed to 0
    end if
    -- targetLength += adjustPrecision
    protoTargetLength = targetLength + moreAccuracy + 1
    step = 0 -- CosExp() uses 0
    xSquared = SquaredExp(n1, exp1, protoTargetLength, radix)
    n1 = {1}
    exp1 = 0
    a = {n1, exp1} -- a is the numerator, CosExp() starts with 1.
    b = a -- b is the denominator.
    -- copy "1" to ans:
    -- ret = a -- in CosExp(), ans starts with 1.
    ret = NewEun(n1, exp1, targetLength, radix)
    lookat = {}
    if inside then
        calculating = inside
    else
        calculating = ID_Cosine -- begin calculating
    end if
    cosIterCount = 1 -- must be one (1), used in loop.
    while calculating and cosIterCount <= cosIter do
    -- for i = 1 to cosIter do
        -- first step is 2, for CosExp()
        step += 2
        tmp = MultiplyExp({step - 1}, 0, {step}, 0, protoTargetLength, radix)
        b = MultiplyExp(b[1], b[2], tmp[1], tmp[2], protoTargetLength, radix)
        a = MultiplyExp(a[1], a[2], xSquared[1], xSquared[2], protoTargetLength, radix)
        tmp = DivideExp(a[1], a[2], b[1], b[2], protoTargetLength, radix)
        --lookat = ret
        if IsPositiveOdd(cosIterCount) then
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
        s = ReturnToUserCallBack(ID_Cosine, trigHowComplete, targetLength, ret, lookat, radix)
        lookat = s[2]
        trigHowComplete = s[3]
        if s[1] then
            exit
        end if
        cosIterCount += 1
ifdef not NO_SLEEP_OPTION then
        sleep(nanoSleep)
end ifdef
    end while
    -- end for
    if cosIterCount = cosIter then
        printf(1, "Error %d\n", 3)
        abort(1/0)
    end if
    -- targetLength -= adjustPrecision
    ret = AdjustRound(ret[1], ret[2], targetLength, radix, NO_SUBTRACT_ADJUST)
    return ret
end function
