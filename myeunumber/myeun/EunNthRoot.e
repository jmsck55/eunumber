-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/nanosleep.e
include ../../eunumber/minieun/common.e
include ../../eunumber/minieun/Multiply.e
include ../../eunumber/minieun/Divide.e
include ../../eunumber/minieun/AddExp.e
include ../../eunumber/minieun/defaults.e
include ../../eunumber/minieun/usermisc.e
include ../../eunumber/minieun/AdjustRound.e
include ../../eunumber/minieun/returntouser.e
include ../../eunumber/minieun/Eun.e
include ../../eunumber/minieun/ToAtom.e
include ../../eunumber/minieun/ToEun.e
include ../../eunumber/minieun/ConvertExp.e
include ../../eunumber/array/negate.e
include ../../eunumber/eun/EunNegate.e

include RealMode.e


--nthroot.e

-- NthRoot algorithm

-- Find the nth root of any number

global function IntPowerExp(PositiveInteger toPower, sequence n1, integer exp1,
                    TargetLength targetLength, AtomRadix radix)
-- b^x = e^(x * ln(b))
    sequence p
    if toPower = 0 then
        return {{1}, 0, targetLength, radix, 0}
    end if
    p = {n1, exp1}
    for i = 2 to toPower do
        p = MultiplyExp(p[1], p[2], n1, exp1, targetLength, radix)
ifdef not NO_SLEEP_OPTION then
        sleep(nanoSleep)
end ifdef
    end for
    return p
end function

-- function NthRoot(object x, object guess, object n)
--      object quotient, average
--      quotient = x / power(guess, n-1)
--      average = (quotient + ((n-1) * guess)) / n
--      return average
-- end function

global function NthRootProtoExp(PositiveScalar n, sequence x1, integer x1Exp,
                   sequence guess, integer guessExp,
                   TargetLength targetLength, AtomRadix radix)
    sequence p, quot, average
    p = IntPowerExp(n - 1, guess, guessExp, targetLength, radix)
    quot = DivideExp(x1, x1Exp, p[1], p[2], targetLength, radix)
    p = MultiplyExp({n - 1}, 0, guess, guessExp, targetLength, radix)
    p = AddExp(p[1], p[2], quot[1], quot[2], targetLength, radix)
    average = DivideExp(p[1], p[2], {n}, 0, targetLength, radix)
    return average
end function

global PositiveOption nthRootMoreAccuracy = -1 -- if -1, then use calculationSpeed

global procedure SetNthRootMoreAccuracy(PositiveOption i)
    nthRootMoreAccuracy = i
end procedure
global function GetNthRootMoreAccuracy()
    return nthRootMoreAccuracy
end function

global integer nthRootIter = 1000000000
global integer lastNthRootIter = 0

global sequence nthRootHowComplete = {1, 0}

global function GetNthRootHowCompleteMin()
    return nthRootHowComplete[1]
end function

global function GetNthRootHowCompleteMax()
    return nthRootHowComplete[2]
end function

global constant ID_NthRoot = 3

global function NthRootExp(PositiveScalar n, sequence x1, integer x1Exp, sequence guess,
            integer guessExp, TargetLength targetLength, AtomRadix radix)
    sequence lookat, ret, s
    integer protoTargetLength, moreAccuracy
    nthRootHowComplete = {1, 0}
    if length(x1) = 0 then
        nthRootHowComplete = {0, 0}
        lastNthRootIter = 1
        return {x1, x1Exp, targetLength, radix, 0}
    end if
    if length(x1) = 1 then
        if x1[1] = 1 or x1[1] = -1 then
            nthRootHowComplete = {1, 1}
            lastNthRootIter = 1
            return {x1, x1Exp, targetLength, radix, 0}
        end if
    end if
    if nthRootMoreAccuracy >= 0 then
        moreAccuracy = nthRootMoreAccuracy
    elsif calculationSpeed then
        moreAccuracy = Ceil(targetLength / calculationSpeed)
    else
        moreAccuracy = 0 -- changed to 0
    end if
    -- Use adjustPrecision for higher order functions, such as Trig functions.
    -- targetLength += adjustPrecision
    protoTargetLength = targetLength + moreAccuracy + 1
    ret = AdjustRound(guess, guessExp, protoTargetLength, radix, FALSE)
    lookat = {}
    calculating = ID_NthRoot -- begin calculating
    lastNthRootIter = 1
    while calculating and lastNthRootIter <= nthRootIter do
    -- for i = 1 to nthRootIter do
        --lookat = ret
        ret = NthRootProtoExp(n, x1, x1Exp, ret[1], ret[2], protoTargetLength, radix)
        --guess = ret[1]
        --guessExp = ret[2]
        --if useExtraAdjustRound then
        --    ret = AdjustRound(guess, guessExp, targetLength + adjustRound, radix, NO_SUBTRACT_ADJUST)
        --end if
        --if ret[2] = lookat[2] then
        --    nthRootHowComplete = Equaln(ret[1], lookat[1], nthRootHowComplete[1]) -- , targetLength - adjustRound)
        --    if nthRootHowComplete[1] > targetLength + 1 or nthRootHowComplete[1] = nthRootHowComplete[2] then
        --    -- if equal(ret[1], lookat[1]) then
        --        exit
        --    end if
        --end if
        s = ReturnToUserCallBack(ID_NthRoot, nthRootHowComplete, targetLength, ret, lookat, radix)
        lookat = s[2]
        nthRootHowComplete = s[3]
        if s[1] then
            exit
        end if
        lastNthRootIter += 1
ifdef not NO_SLEEP_OPTION then
        sleep(nanoSleep)
end ifdef
    end while
    -- end for
    if lastNthRootIter = nthRootIter then
        printf(1, "Error %d\n", 3)
        abort(1/0)
    end if
    ret = AdjustRound(ret[1], ret[2], targetLength, radix, NO_SUBTRACT_ADJUST)
    return ret
end function

global function EunNthRoot(PositiveScalar n, Eun n1, object guess = 0)
    integer isImag, exp1, f
    sequence ret
    atom a
    exp1 = 0
    if atom(guess) then
        -- Latest code:
        exp1 = n1[2]
        f = remainder(exp1, n)
        if f then
            exp1 -= f
            if exp1 <= 0 then
                exp1 += n
            end if
        end if
        n1[2] -= exp1
        guess = ToAtom(n1)
        a = guess
        f = 0
        if a < 0 then
            -- factor out sqrt(-1), an imaginary number, on even roots
            a = -a -- atom
            f = IsIntegerOdd(n)
        end if
        a = power(a, 1 / n)
        if f then
            a = -a -- atom
        end if
        guess = ToEun(sprintf("%e", a), n1[4], n1[3])
    end if
    if n1[4] != guess[4] then -- still needed if guess is supplied as an argument of this function.
        guess = EunConvert(guess, n1[4], n1[3])
    end if
    if IsIntegerEven(n) then
        if length(n1[1]) and n1[1][1] < 0 then
            if realMode then
                printf(1, "Error %d\n", 4)
                abort(1/0)
            end if
            -- factor out sqrt(-1)
            isImag = 1
            n1[1] = Negate(n1[1])
        else
            isImag = 0
        end if
        if IsNegative(guess[1]) then
            guess[1] = Negate(guess[1])
        end if
    end if
    ret = NthRootExp(n, n1[1], n1[2], guess[1], guess[2], n1[3], n1[4])
    exp1 = floor(exp1 / n)
    ret[2] += exp1
    if IsIntegerOdd(n) then
        return ret
    else
        return {isImag, ret, EunNegate(ret)}
    end if
end function
