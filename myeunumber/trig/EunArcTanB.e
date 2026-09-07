-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/common.e
include ../../eunumber/minieun/defaults.e
include ../../eunumber/minieun/usermisc.e
include ../../eunumber/minieun/AddExp.e
include ../../eunumber/minieun/Multiply.e
include ../../eunumber/minieun/Divide.e
include ../../eunumber/minieun/AdjustRound.e
include ../../eunumber/minieun/returntouser.e
include ../../eunumber/minieun/nanosleep.e
include ../../eunumber/minieun/Eun.e

include arcTan.e


global function ArcTanExpB(sequence n1, integer exp1, TargetLength targetLength, AtomBase base)

-- Doesn't like really large or really small numbers.

    sequence a, b, c, d, e, f, tmp, count, xSquared, xSquaredPlusOne, lookat, ret, s
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
    -- First iteration:
    -- x*x + 1
    e = MultiplyExp(n1, exp1, n1, exp1, protoTargetLength, base)
    e = AddExp(e[1], e[2], {1}, 0, protoTargetLength, base)
    -- x/e
    ret = DivideExp(n1, exp1, e[1], e[2], protoTargetLength, base)
    a = {{1}, 0}
    b = a
    c = a
    count = a
    d = {n1, exp1}
    xSquared = SquaredExp(n1, exp1, protoTargetLength, base)
    xSquaredPlusOne = AddExp(xSquared[1], xSquared[2], {1}, 0, protoTargetLength, base)
    e = xSquaredPlusOne
    -- Second iteration(s):
    n1 = ret[1]
    exp1 = ret[2]
    ret = AdjustRound(n1, exp1, protoTargetLength, base, NO_SUBTRACT_ADJUST)
    lookat = {}
    calculating = ID_ArcTan -- begin calculating in a loop
    arcTanCount = 1 -- must be one (1), used in loop.
    while calculating and arcTanCount <= arcTanIter do
    -- for n = 1 to arcTanIter do
        a = MultiplyExp(a[1], a[2], {4}, 0, protoTargetLength, base)
        tmp = AdjustRound({arcTanCount}, 0, protoTargetLength, base, FALSE) -- uses "arcTanCount"
        b = MultiplyExp(b[1], b[2], tmp[1], tmp[2], protoTargetLength, base)
        tmp = MultiplyExp(b[1], b[2], b[1], b[2], protoTargetLength, base)
        -- it needs these statements:
        count = AddExp(count[1], count[2], {1}, 0, protoTargetLength, base)
        c = MultiplyExp(c[1], c[2], count[1], count[2], protoTargetLength, base)
        count = AddExp(count[1], count[2], {1}, 0, protoTargetLength, base)
        c = MultiplyExp(c[1], c[2], count[1], count[2], protoTargetLength, base)
        d = MultiplyExp(d[1], d[2], xSquared[1], xSquared[2], protoTargetLength, base)
        e = MultiplyExp(e[1], e[2], xSquaredPlusOne[1], xSquaredPlusOne[2], protoTargetLength, base)
        f = MultiplyExp(a[1], a[2], tmp[1], tmp[2], protoTargetLength, base)
        f = DivideExp(f[1], f[2], c[1], c[2], protoTargetLength, base)
        f = MultiplyExp(f[1], f[2], d[1], d[2], protoTargetLength, base)
        f = DivideExp(f[1], f[2], e[1], e[2], protoTargetLength, base)
        --lookat = ret
        ret = AddExp(ret[1], ret[2], f[1], f[2], protoTargetLength, base)
        -- n1 = ret[1]
        -- exp1 = ret[2]
        -- if useExtraAdjustRound then
        --     ret = AdjustRound(n1, exp1, targetLength + adjustRound, base, NO_SUBTRACT_ADJUST)
        -- end if
        -- if ret[2] = lookat[2] then
        --     arcTanHowComplete = Equaln(ret[1], lookat[1], arcTanHowComplete[1]) -- , targetLength - adjustRound)
        --     if arcTanHowComplete[1] > targetLength + 1 or arcTanHowComplete[1] = arcTanHowComplete[2] then
        --     -- if equal(ret[1], lookat[1]) then
        --         exit
        --     end if
        -- end if
        s = ReturnToUserCallBack(ID_ArcTan, arcTanHowComplete, targetLength, ret, lookat, base)
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
    -- targetLength -= adjustPrecision
    ret = AdjustRound(ret[1], ret[2], targetLength, base, NO_SUBTRACT_ADJUST)
    return ret
end function

global function EunArcTanB(Eun a)
    return ArcTanExpB(a[1], a[2], a[3], a[4])
end function
