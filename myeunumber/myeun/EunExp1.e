-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/nanosleep.e
include ../../eunumber/minieun/common.e
include ../../eunumber/minieun/AddExp.e
include ../../eunumber/minieun/Multiply.e
include ../../eunumber/minieun/Divide.e
include ../../eunumber/minieun/Eun.e
include ../../eunumber/minieun/returntouser.e
include ../../eunumber/minieun/AdjustRound.e
include ../../eunumber/minieun/FindIter.e
include ../../eunumber/eun/Remainder.e

include ExpCommon.e


global PositiveScalar exp1Iter = 4 -- try to keep this number small, but greater or equal to 4.
global PositiveScalar exp1IterMax = 1024
global PositiveInteger exp1Half = 0
global PositiveInteger exp1Confidence = 0

procedure ExpFindIter(integer i)
    sequence s = FindIter(i, {exp1Iter, exp1Half, exp1Confidence}, 4, exp1IterMax)
    exp1Iter = s[1]
    exp1Half = s[2]
    exp1Confidence = s[3]
end procedure

global function GetExp1Iter()
    return exp1Iter
end function

global procedure SetExp1Iter(integer i) -- when switching radixes, store exp1Iter, switch, and then call SetExp1Iter() when you switch back.
    exp1Iter = i
end procedure


global sequence exp1HowComplete = {1, 0}

global function GetExp1HowCompleteMin()
    return exp1HowComplete[1]
end function

global function GetExp1HowCompleteMax()
    return exp1HowComplete[2]
end function


global function ExpExp1(sequence n1, integer exp1, TargetLength targetLength, AtomRadix radix, PositiveScalar theExp1Iter)
-- not quite accurate enough for large numbers.

-- it doesn't like large numbers.

-- does work for negative numbers.
-- using taylor series
-- https://en.wikipedia.org/wiki/Taylor_series
--
-- My code:
-- sum = sum * x / i + 1;
--      integer maxIter = 100
--      atom x, sum, tmp
--      x = input, such as 1
--      sum = 1
--      for i = maxIter to 1 by -1 do
--              tmp = (x/i)
--              sum *= tmp
--              sum += 1
--      end for
--      return sum
-- end My code.
    sequence sum, tmp, den
    exp1HowComplete = {1, 0}
    sum = {{1}, 0}
    den = AdjustRound({theExp1Iter}, 0, targetLength, radix, 0)
    for i = theExp1Iter to 1 by -1 do
        tmp = DivideExp(n1, exp1, den[1], den[2], targetLength, radix)
        sum = MultiplyExp(sum[1], sum[2], tmp[1], tmp[2], targetLength, radix)
        sum = AddExp(sum[1], sum[2], {1}, 0, targetLength, radix)
        den = AddExp(den[1], den[2], {-1}, 0, targetLength, radix)
        exp1HowComplete[1] = i
ifdef not NO_SLEEP_OPTION then
        sleep(nanoSleep)
end ifdef
    end for
    return sum
end function

global function EunExp1(Eun a)
-- My TI-83 Basic code:
--      Prompt X,T,N
--      X/ln(10) = B
--      iPart(B) = C
--      (B-C)*ln(10) = Y
--      Y/T = Y -- T=1 in this implimentation
--      1 = A
--      For(I,N,1,-1)
--      A*Y/I+1 = A
--      End
--      Disp e^(X)
--      (A^T)*10^(C) = R
--      Disp R
-- end My TI-83 Basic code.
    object t, b, c, lnRadix, y
    sequence s, lookat, ret
    integer targetLength = a[3]
    atom radix = a[4]
    lnRadix = GetLnRadix(targetLength, radix)
    b = DivideExp(a[1], a[2], lnRadix[1], lnRadix[2], targetLength, radix)
    c = EunFloor(b) -- should this be EunFloor() or something else?  For negative numbers?
    b = SubtractExp(b[1], b[2], c[1], c[2], targetLength, radix)
    y = MultiplyExp(b[1], b[2], lnRadix[1], lnRadix[2], targetLength, radix)
    --t = {{1}, 0}
    --y = DivideExp(y[1], y[2], t[1], t[2], targetLength, radix)
    
    -- exp1HowComplete = {1, 0}
    calculating = 999
    while calculating with entry do
        lookat = ExpExp1(y[1], y[2], targetLength + 1, radix, exp1Iter - 1)

        s = ReturnToUserCallBack(999, exp1HowComplete, targetLength, ret, lookat, radix)
        ret = s[2]
        exp1HowComplete = s[3]
        ExpFindIter(s[1])
        if s[1] then
            exit
        end if
    entry
        ifdef DEBUG_TASK then
            printf(1, "exp1Iter in EunExp1() = %d\n", exp1Iter)
        end ifdef
        ret = ExpExp1(y[1], y[2], targetLength + 1, radix, exp1Iter)
        
ifdef not NO_SLEEP_OPTION then
        sleep(nanoSleep)
end ifdef
    end while
    ifdef DEBUG_TASK then
        printf(1, "exp1Iter after EunExp1() = %d\n", exp1Iter)
    end ifdef
    ret[2] += ToAtom(c)
    ret = AdjustRound(ret[1], ret[2], targetLength, radix, NO_SUBTRACT_ADJUST)
    return ret
end function

global constant eunExp1RID = routine_id("EunExp1")


global function EunExp1A(Eun x)
    return EunExpId(eunExp1RID, x)
end function

