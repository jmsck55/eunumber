-- Copyright (c) 2016-2023 James Cook


-- Find the Root of the equation: where it crosses the X-Axis.

-- Supply two values, one above the X-Axis, and one below the X-Axis.


include ../../eunumber/minieun/common.e
include ../../eunumber/minieun/comparefuncs.e
include ../../eunumber/minieun/Eun.e
include ../../eunumber/minieun/AddExp.e
include ../../eunumber/minieun/Multiply.e
include ../../eunumber/minieun/Divide.e
include ../../eunumber/minieun/reverse.e
include ../../eunumber/minieun/returntouser.e
include ../../eunumber/minieun/nanosleep.e
include ../../eunumber/minieun/AdjustRound.e
include ../../eunumber/minieun/usermisc.e
include ../../eunumber/array/negate.e


--myeuroots.e

-- "FindRoot" means: Find the roots (or zeros) of an equation.
-- NOTE: not accurate at PI return values, so far.

global function MyCompareExp(sequence n1, integer exp1, sequence n2, integer exp2)
    return CompareExp(n1, exp1, n2, exp2)
end function

global sequence deltaC = {} -- {{1},-10}
--global sequence deltaC = {{1},-80}
--0.0000000001 -- must be a positive number

global procedure SetDelta(sequence s)
    if Eun(s) then
        deltaC = s
    else
        deltaC = {}
    end if
end procedure

global function GetDelta()
    return deltaC
end function

global PositiveInteger eurootsAdjustRound = 4

global procedure SetEurootsAdjustRound(PositiveInteger i)
    eurootsAdjustRound = i
end procedure

global function GetEurootsAdjustRound()
    return eurootsAdjustRound
end function

-- findRoot private variables:
sequence a, b, c, d, fa, fb, fc, s, fs, tmp, tmp1, tmp2, delta = {}
integer mflag, lookatIter
integer comp1, comp2

global function GetLastDelta()
    return delta
end function

function Condition_1_Through_5(PositiveScalar len, AtomRadix radix)
    sequence sb, bc, cd

    --tmp1 = ((3 * a) + b) / 4
    tmp1 = MultiplyExp({3}, 0, a[1], a[2], len, radix)
    tmp1 = AddExp(tmp1[1], tmp1[2], b[1], b[2], len, radix)
    tmp1 = DivideExp(tmp1[1], tmp1[2], {4}, 0, len, radix)

    comp1 = MyCompareExp(s[1], s[2], tmp1[1], tmp1[2])
    comp2 = MyCompareExp(s[1], s[2], b[1], b[2])

    -- condition 1:
    if (not (comp1 = -1 and comp2 = 1)) and (not (comp2 = -1 and comp1 = 1)) then
        return 1
    end if

    sb = SubtractExp(s[1], s[2], b[1], b[2], len, radix)
    sb[1] = AbsoluteValue(sb[1])

    if mflag = 1 then
        bc = SubtractExp(b[1], b[2], c[1], c[2], len, radix)
        bc[1] = AbsoluteValue(bc[1])
        -- condition 2:
        tmp = DivideExp(bc[1], bc[2], {2}, 0, len, radix)
        comp1 = MyCompareExp(sb[1], sb[2], tmp[1], tmp[2])
        if comp1 >= 0 then
            return 1
        end if
        -- condition 4:
        comp1 = MyCompareExp(bc[1], bc[2], delta[1], delta[2])
        if comp1 = -1 then
            return 1
        end if
    else
        cd = SubtractExp(c[1], c[2], d[1], d[2], len, radix)
        cd[1] = AbsoluteValue(cd[1])
        -- condition 3:
        tmp = DivideExp(cd[1], cd[2], {2}, 0, len, radix)
        comp1 = MyCompareExp(sb[1], sb[2], tmp[1], tmp[2])
        if comp1 >= 0 then
            return 1
        end if
        -- condition 5:
        comp1 = MyCompareExp(cd[1], cd[2], delta[1], delta[2])
        if comp1 = -1 then
            return 1
        end if
    end if
    return 0
end function

global constant ID_FindRootExp = 10

global function FindRootExp(integer rid, sequence n1, integer exp1,
        sequence n2, integer exp2, TargetLength targetLength, AtomRadix radix,
        integer littleEndian = 0, object passToFunc1 = {})
    sequence ret
    integer len
    len = targetLength + eurootsAdjustRound
    if Eun(deltaC) and deltaC[4] = radix then
        delta = deltaC
    else
        delta = NewEun({1}, floor((exp1 + exp2) / 2) - (len) + 2, len, radix)
    end if

    a = {n1, exp1}
    b = {n2, exp2}
    if littleEndian then
        fa = call_func(rid, {reverse(n1), exp1, len, radix, passToFunc1})
        fa[1] = reverse(fa[1])
        fb = call_func(rid, {reverse(n2), exp2, len, radix, passToFunc1})
        fb[1] = reverse(fb[1])
    else
        fa = call_func(rid, {n1, exp1, len, radix, passToFunc1})
        fb = call_func(rid, {n2, exp2, len, radix, passToFunc1})
    end if

    if length(fa[1]) and length(fb[1]) then
        if fa[1][1] < 0 and fb[1][1] > 0 then -- if both are same sign, error
            return 1 -- error
        end if
    end if

    comp1 = MyCompareExp(AbsoluteValue(fa[1]), fa[2], AbsoluteValue(fb[1]), fb[2])
    if comp1 = -1 then
        -- swap, and set c=a
        c = b
        b = a
        a = c
    else
        c = a
    end if
    fc = fa
    fs = {{1}, 0}
    mflag = 1
    lookatIter = 0
    calculating = ID_FindRootExp -- begin calculating
    while calculating do
        lookatIter += 1

        comp1 = MyCompareExp(fa[1], fa[2], fc[1], fc[2])
        comp2 = MyCompareExp(fb[1], fb[2], fc[1], fc[2])
        if comp1 != 0 and comp2 != 0 then
            -- calculate "s" (inverse quadratic interpolation)
            --s = (a*fb*fc) / ((fa-fb)*(fa-fc))
            tmp1 = SubtractExp(fa[1], fa[2], fb[1], fb[2], len, radix)
            tmp2 = SubtractExp(fa[1], fa[2], fc[1], fc[2], len, radix)
            tmp1 = MultiplyExp(tmp1[1], tmp1[2], tmp2[1], tmp2[2], len, radix)
            tmp2 = MultiplyExp(fb[1], fb[2], fc[1], fc[2], len, radix)
            tmp2 = MultiplyExp(tmp2[1], tmp2[2], a[1], a[2], len, radix)
            tmp1 = DivideExp(tmp2[1], tmp2[2], tmp1[1], tmp1[2], len, radix)
            s = tmp1

            --s += (b*fa*fc) / ((fb-fa)*(fb-fc))
            tmp1 = SubtractExp(fb[1], fb[2], fa[1], fa[2], len, radix)
            tmp2 = SubtractExp(fb[1], fb[2], fc[1], fc[2], len, radix)
            tmp1 = MultiplyExp(tmp1[1], tmp1[2], tmp2[1], tmp2[2], len, radix)
            tmp2 = MultiplyExp(fa[1], fa[2], fc[1], fc[2], len, radix)
            tmp2 = MultiplyExp(tmp2[1], tmp2[2], b[1], b[2], len, radix)
            tmp1 = DivideExp(tmp2[1], tmp2[2], tmp1[1], tmp1[2], len, radix)
            s = AddExp(s[1], s[2], tmp1[1], tmp1[2], len, radix)

            --s += (c*fa*fb) / ((fc-fa)*(fc-fb))
            tmp1 = SubtractExp(fc[1], fc[2], fa[1], fa[2], len, radix)
            tmp2 = SubtractExp(fc[1], fc[2], fb[1], fb[2], len, radix)
            tmp1 = MultiplyExp(tmp1[1], tmp1[2], tmp2[1], tmp2[2], len, radix)
            tmp2 = MultiplyExp(fa[1], fa[2], fb[1], fb[2], len, radix)
            tmp2 = MultiplyExp(tmp2[1], tmp2[2], c[1], c[2], len, radix)
            tmp1 = DivideExp(tmp2[1], tmp2[2], tmp1[1], tmp1[2], len, radix)
            s = AddExp(s[1], s[2], tmp1[1], tmp1[2], len, radix)
        else
            -- calculate "s" (secant rule)
            --s = b - (fb * (b-a)/(fb-fa))
            tmp1 = SubtractExp(b[1], b[2], a[1], a[2], len, radix)
            tmp2 = SubtractExp(fb[1], fb[2], fa[1], fa[2], len, radix)
            tmp1 = MultiplyExp(tmp1[1], tmp1[2], fb[1], fb[2], len, radix)
            tmp1 = DivideExp(tmp1[1], tmp1[2], tmp2[1], tmp2[2], len, radix)
            s = SubtractExp(b[1], b[2], tmp1[1], tmp1[2], len, radix)
        end if

        mflag = Condition_1_Through_5(len, radix)
        if mflag then
            s = AddExp(a[1], a[2], b[1], b[2], len, radix)
            s = DivideExp(s[1], s[2], {2}, 0, len, radix)
        end if

        if littleEndian then
            fs = call_func(rid, {reverse(s[1]), s[2], len, radix, passToFunc1})
            fs[1] = reverse(fs[1])
        else
            fs = call_func(rid, {s[1], s[2], len, radix, passToFunc1})
        end if

        d = c -- (d is assigned for the first time here, it won't be used above on the first iteration because mflag is set)
        c = b
        if IsNegative(fa[1]) xor IsNegative(fs[1]) then
        --if fa[1][1] * fs[1][1] < 0 then
            b = s
        else
            a = s
        end if

        comp1 = MyCompareExp(AbsoluteValue(fa[1]), fa[2], AbsoluteValue(fb[1]), fb[2])
        if comp1 = -1 then
            -- swap(a, b)
            tmp = b
            b = a
            a = tmp
        end if

        tmp1 = SubtractExp(b[1], b[2], a[1], a[2], len, radix)
        tmp1[1] = AbsoluteValue(tmp1[1])
        comp1 = MyCompareExp(tmp1[1], tmp1[2], delta[1], delta[2])
        if length(fb[1]) = 0 or length(fs[1]) = 0 or comp1 = -1 then
            exit
        end if
        ret = ReturnToUserCallBack(ID_FindRootExp, {lookatIter, 0}, targetLength, b, s, radix)
        if ret[1] then
            exit
        end if
        -- calculating = ReturnToUserCallBack(ID_FindRootExp, {lookatIter, 0})
ifdef not NO_SLEEP_OPTION then
        sleep(nanoSleep)
end ifdef
    end while

    len -= eurootsAdjustRound
    b = AdjustRound(b[1], b[2], len, radix)
    s = AdjustRound(s[1], s[2], len, radix)

    return {b, s, lookatIter}
end function

global function EunFindRoot(integer rid, Eun n1, Eun n2, integer littleEndian = 0, object passToFunc1 = {})
    object x
    if n1[4] != n2[4] then
        puts(1, "Error, radixes are not the same.\n")
        abort(1/0)
    end if
    x = FindRootExp(rid, n1[1], n1[2], n2[1], n2[2], max(n1[3], n2[3]), n1[4], littleEndian, passToFunc1)
    if atom(x) then
        return {} -- error
    end if
    return x
end function
