-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/nanosleep.e
include ../../eunumber/minieun/common.e
include ../../eunumber/minieun/defaults.e
include ../../eunumber/minieun/usermisc.e
include ../../eunumber/minieun/Eun.e
include ../../eunumber/minieun/returntouser.e
include ../../eunumber/minieun/AddExp.e
include ../../eunumber/minieun/Multiply.e
include ../../eunumber/minieun/Divide.e
include ../../eunumber/minieun/AdjustRound.e
include ../../eunumber/minieun/ToAtom.e
include ../../eunumber/minieun/ToEun.e
include ../../eunumber/minieun/comparefuncs.e
include ../../eunumber/array/negate.e

include ../trig/GetPI.e

include EunExp.e
include ExpExp.e
include GetE.e
include RealMode.e

-- NOTE: Need to test the original function's domain (and range),
--  then extend the domain using properties of mathematics.

-- Logarithms:
--
-- Log Rules:
--
-- 1) logb(mn) = logb(m) + logb(n)
--
-- 2) logb(m/n) = logb(m) – logb(n)
--
-- 3) logb(m^n) = n * logb(m)
--
-- 4) x^(-n) = 1 / x^(n)
--
-- 5) logb(m^(-n)) = -n * logb(m) = logb(1/m^n) = - logb(m^n)
--
-- 6) ln(x) = - Sum[k = 1 to inf] ((-1)^k * (-1 + x)^k) / k, for abs(-1 + x) < 1; x > 0 and x < 2;
--
-- Identities:
--
-- log(e) = 1
-- log(e^n) = n * log(e)
-- log(e^n) = n * 1
-- log(e^n) = n
-- log(m/e^n) = log(m) - log(e^n)
-- log(m/e^n) = log(m) - n
-- log(m/e^n) + n = log(m)
--
--------------------------------------------------------------------------------
-- if m < 1 and m > 0, n is negative. // good, use "ln(x)", like above
--------------------------------------------------------------------------------
-- log(m/e^n) = log(m * e^(-n))
-- log(m * e^(-n)) = log(m) - n
-- log(m * e^(-n)) + n = log(m)
--
--------------------------------------------------------------------------------
-- Use: (still using this one) // good, need to factor "e" for large numbers.
-- If n > 0, m > 1 // use if x >= 2, to put it back in the domain of (0..2) exclusively.
--------------------------------------------------------------------------------
-- log(m) = log(m/e^n) + n // n is positive
-- Find e^n, substitute with "tmp"
-- log(m / tmp) + n
--
--------------------------------------------------------------------------------
-- If n < 0, m < 1 // don't have to worry about this one.
--------------------------------------------------------------------------------
-- log(m) = log(m * e^(-n)) + n; // n is negative
-- Find e^(-n) == e^(-(-abs(n))) == e^(abs(n)), substitute. // n is still negative
-- log(m * tmp) + n
--
-- If n = 0, m == 1, log(1) == 0
-- return log(m)
--
-- Step 1: Find a power of "e", (that is larger, or smaller then "m"), and save it in "n"
-- Step 2: Divide "m" by "e^n" == tmp -- or, if n is negative, Multiply "m" by "e^(-n)" == tmp.
-- Step 3: and take the logarithm of it.
-- Step 4: Add "n" to the answer, and return it.
--

global function GetLogGuess(sequence n1, integer exp1, TargetLength targetLength, AtomRadix radix)
    atom a
    sequence guessExp
    -- Get guessExp:
    a = ToAtom({n1, exp1, targetLength, radix})
    if a < 0 then
        if realMode then -- not needed, caught in previous lines of code, leave it here for now.
            puts(1, "Error.\n")
            abort(1/0)
        end if
        -- result would be an imaginary number (imag == i)
        -- ln(-1) = PI * i
        -- ln(-a) = ln(a) + (PI * i)
        a = -a -- atom
    end if
    a = log(a) -- it makes a guess
    guessExp = ToEun(sprintf("%e", a), radix, targetLength) -- need to return this value.
    return guessExp
end function

global function GetLogDomain(sequence n1, integer exp1, TargetLength targetLength, AtomRadix radix)
    -- n1 is positive and != 1, test if it is less than 1.
    -- Use: (still using this one)
    -- If n > 0, m > 1 // use if x >= 2, to put it back in the domain of (0..2) exclusively.
    -- log(m) = log(m/e^n) + n // n is positive
    -- Find e^n, substitute with "tmp"
    -- return log(m / tmp) + n;
    -- integer n
    sequence t, m --, guessExp
    -- -- Step 1:
    m = GetE(targetLength, radix)
    t = FindPowerOfGreaterThan(n1, exp1, targetLength, radix, m[1], m[2], FIND_POWER_LESS_THAN) -- Less than.
    -- n = m[1] -- need to return this value.
    m = t[2] -- a power of GetE()
    -- Step 2:
    if t[1] < 0 then
        m = MultiplyExp(n1, exp1, m[1], m[2], targetLength, radix) -- need to return m
    else
        m = DivideExp(n1, exp1, m[1], m[2], targetLength, radix) -- need to return m
    end if
    t[2] = m
    -- a = ToAtom(m)
    -- Get guessExp:
    -- guessExp = GetLogGuess(n1, exp1, targetLength, radix)
    -- a = ToAtom({n1, exp1, targetLength, radix})
    -- if a < 0 then
    --     if realMode then -- not needed, caught in previous lines of code, leave it here for now.
    --         puts(1, "Error.\n")
    --         abort(1/0)
    --     end if
    --     -- result would be an imaginary number (imag == i)
    --     -- ln(-1) = PI * i
    --     -- ln(-a) = ln(a) + (PI * i)
    --     a = -a -- atom
    -- end if
    -- a = log(a) -- it makes a guess
    -- guessExp = ToEun(sprintf("%e", a), radix, targetLength) -- need to return this value.
    -- return guessExp
    return t -- {n, m} -- {eun guess, eun m (n1), integer n}
end function

global PositiveOption logMoreAccuracy = -1 -- if -1, then use calculationSpeed

global procedure SetLogMoreAccuracy(PositiveOption i)
    logMoreAccuracy = i
end procedure
global function GetLogMoreAccuracy()
    return logMoreAccuracy
end function

global integer logIter = 1000000000 -- 50
global integer logIterCount = 0

global sequence logHowComplete = {1, 0}

global function GetLogHowCompleteMin()
    return logHowComplete[1]
end function

global function GetLogHowCompleteMax()
    return logHowComplete[2]
end function

global constant ID_Log = 6

-- Raw function: Natural Logarithm

global function NaturalLogarithm(sequence n1, integer exp1, TargetLength targetLength, AtomRadix radix)
    -- Function: NaturalLogarithm()
    -- Use for testing the method.
    -- Alternative, between 0 and 2 exclusively:
    -- ln(x) = - Sum[k = 1 to inf] ((-1)^k * (-1 + x)^k) / k, for abs(-1 + x) < 1; x > 0 and x < 2;
    -- ((-1)^k * (-1 + x)^k) / k
    -- ((-x + 1)^k) / k
    -- Alternative, away from 0 to 2 exclusively: // Use factoring of "e" instead.
    -- ln(x) = ln(-1 + x) - Sum[k = 1 to inf] ((-1)^k * (-1 + x)^(-k)) / k, for abs(-1 + x) > 1, x < 0 or x > 2;
    --
    -- precalculate:
    -- xNegativePlusOne = (1 - x), then multiply, and store as "p".
    -- k = 1, (xNegativePlusOne^1) / 1
    -- k = 2, (xNegativePlusOne^2) / 2
    -- k = 3, (xNegativePlusOne^3) / 3
    -- k = 4, (xNegativePlusOne^4) / 4
    -- k = 5, (xNegativePlusOne^5) / 5
    -- Then, summate and negate, then return sum:
    -- while 1 do
    --  p *= xNegativePlusOne
    --  sum += p / k
    --  if k == inf then -- as k approaches infinity.
    --    exit -- break;
    --  end if
    --  k += 1
    -- end while
    -- return - (sum)
    sequence lookat, s, sum, k, xNegativePlusOne, p
    logHowComplete = {1, 0, {}}
    if CompareExp(n1, exp1, {2}, 0) >= 0 then
        return 2 -- domain error
    end if
    if CompareExp(n1, exp1, {}, 0) <= 0 then
        return 0 -- domain error
    end if
    p = SubtractExp({1}, 0, n1, exp1, targetLength, radix)
    xNegativePlusOne = p
    sum = p
    k = {{2}, 0}
    lookat = {}
    calculating = ID_Log -- begin calculating
    logIterCount = 1
    while calculating and logIterCount <= logIter do
        p = MultiplyExp(p[1], p[2], xNegativePlusOne[1], xNegativePlusOne[2], targetLength, radix)
        s = DivideExp(p[1], p[2], k[1], k[2], targetLength, radix)
        sum = AddExp(sum[1], sum[2], s[1], s[2], targetLength, radix)
        s = ReturnToUserCallBack(ID_Log, logHowComplete, targetLength, sum, lookat, radix)
        lookat = s[2]
        logHowComplete = s[3]
        if s[1] then
            exit
        end if
        k = AddExp(k[1], k[2], {1}, 0, targetLength, radix)
        logIterCount += 1
ifdef not NO_SLEEP_OPTION then
        sleep(nanoSleep)
end ifdef
    end while
    if logIterCount = logIter then
        printf(1, "Error %d\n", 3)
        abort(1/0)
    end if
    sum[1] = Negate(sum[1])
    return sum
end function

global function LogExpA(sequence n1, integer exp1, TargetLength targetLength, AtomRadix radix)
    -- n1 is positive and != 0, test if >= 2.
    -- Use: (still using this one)
    -- If n > 0, m > 1 // use if x >= 2, to put it back in the domain of (0..2) exclusively.
    -- log(m) = log(m/e^n) + n // n is positive
    -- Find e^n, substitute with "tmp"
    -- return log(m / tmp) + n;
    -- Uses factoring of "e" and NaturalLogarithm() function above.
    -- n1 = x, guess = y
    -- x = 0, y = -inf
    -- x > 0, y == All Real Numbers
    -- x < 0, y = ln(abs(x)) + iPI
    integer protoTargetLength, moreAccuracy, isImag, n = 0
    object guess
    --logHowComplete = {1, 0, {}}
    if length(n1) = 0 then -- tests for the value of zero (0)
        return {-1, 0, targetLength, radix} -- returns the Eun for negative infinity (-inf)
    end if
    if exp1 = 0 then
        if equal(n1, {1}) then
            return {{}, 0, targetLength, radix}
        elsif equal(n1, {-1}) then -- complex number:
            return {{{}, 0, targetLength, radix}, GetPI(targetLength, radix)}
        end if
    end if
    isImag = IsNegative(n1) -- need to return this value
    if isImag then
        if realMode then
            puts(1, "Error.\n")
            abort(1/0)
        end if
        n1 = Negate(n1) -- it's done towards the end of the function.
    end if
    if logMoreAccuracy >= 0 then
        moreAccuracy = logMoreAccuracy
    elsif calculationSpeed then
        moreAccuracy = Ceil(targetLength / calculationSpeed)
    else
        moreAccuracy = 0 -- changed to 0
    end if
    -- targetLength += adjustPrecision
    protoTargetLength = targetLength + moreAccuracy + 1
    -- Calculate the guess
    -- Step 1 and Step 2:
    --if CompareExp(n1, exp1, {2}, 0) >= 0 then
        sequence t
        guess = GetLogDomain(n1, exp1, protoTargetLength, radix)
        n = guess[1]
        n1 = guess[2][1]
        exp1 = guess[2][2]
    --end if
    -- Step 3:
    guess = NaturalLogarithm(n1, exp1, protoTargetLength, radix)
    -- Step 4:
    if n != 0 then
        sequence tmp
        tmp = AdjustRound({n}, 0, radix, protoTargetLength, CARRY_ADJUST)
        guess = AddExp(guess[1], guess[2], tmp[1], tmp[2], protoTargetLength, radix)
    end if
    guess = AdjustRound(guess[1], guess[2], targetLength, radix, NO_SUBTRACT_ADJUST)
    if isImag then -- return a complex number: guess must be positive.
        return { guess, GetPI(targetLength, radix) } -- (ret[3] - adjustPrecision)
    else
        return guess
    end if
end function

global function LogExpB(sequence n1, integer exp1, TargetLength targetLength, AtomRadix radix) --, object guess = 0)
    -- ln(x) == natrual logarithm, ln(e) = 1, "e" is Euler's constant.
    -- ln(x) = y[n] = y[n - 1] + 2 * (x - exp(y[n - 1]))/(x + exp(y[n - 1]))
    -- Alternative, for between 0 and 2 exclusively: ln(x) = - Sum[k = 1 to inf] ((-1)^k * (-1 + x)^k) / k, for abs(-1 + x) < 1; x > 0 and x < 2;
    -- n1 = x, guess = y
    -- x = 0, y = -inf
    -- x > 0, y == All Real Numbers
    -- x < 0, y = ln(abs(x)) + iPI
    sequence expY, xMinus, xPlus, tmp, lookat, s
    integer protoTargetLength, moreAccuracy, isImag, n
    object guess
    logHowComplete = {1, 0, {}}
    if length(n1) = 0 then -- tests for the value of zero (0)
        return {-1, 0, targetLength, radix} -- returns the Eun for negative infinity (-inf)
    end if
    if exp1 = 0 then
        if equal(n1, {1}) then
            return {{}, 0, targetLength, radix}
        elsif equal(n1, {-1}) then -- complex number:
            return {{{}, 0, targetLength, radix}, GetPI(targetLength, radix)}
        end if
    end if
    isImag = IsNegative(n1) -- need to return this value
    if isImag then
        if realMode then
            puts(1, "Error.\n")
            abort(1/0)
        end if
        n1 = Negate(n1) -- it's done towards the end of the function.
    end if
    if logMoreAccuracy >= 0 then
        moreAccuracy = logMoreAccuracy
    elsif calculationSpeed then
        moreAccuracy = Ceil(targetLength / calculationSpeed)
    else
        moreAccuracy = 0 -- changed to 0
    end if
    -- targetLength += adjustPrecision
    protoTargetLength = targetLength + moreAccuracy + 1
    --if atom(guess) then
    -- -- Calculate the guess, Step 1 and Step 2:
    guess = GetLogGuess(n1, exp1, protoTargetLength, radix)
    -- guess = t[1]
    -- n1 = t[2][1]
    -- exp1 = t[2][2]
    -- n = t[3]
    --else
    --    guess = {guess[1], guess[2], protoTargetLength, radix}
    --    n = 0
    --end if
    -- Step 3:
    lookat = {}
    calculating = ID_Log -- begin calculating
    logIterCount = 1
    while calculating and logIterCount <= logIter do
    -- for i = 1 to logIter do
    -- guess = guess + 2 * (num1 - exp(guess))/(num1 + exp(guess))
        expY = EunExp(guess)
        --expY = ExpExp(guess[1], guess[2], protoTargetLength, radix)
        xPlus = AddExp(n1, exp1, expY[1], expY[2], protoTargetLength, radix)
        xMinus = SubtractExp(n1, exp1, expY[1], expY[2], protoTargetLength, radix)
        tmp = DivideExp(xMinus[1], xMinus[2], xPlus[1], xPlus[2], protoTargetLength, radix)
        tmp = MultiplyExp({2}, 0, tmp[1], tmp[2], protoTargetLength, radix)
        --lookat = guess
        guess = AddExp(guess[1], guess[2], tmp[1], tmp[2], protoTargetLength, radix)
        -- if useExtraAdjustRound then
        --     guess = AdjustRound(guess[1], guess[2], targetLength + adjustRound, radix, NO_SUBTRACT_ADJUST)
        -- end if
        -- if guess[2] = lookat[2] then
        --     logHowComplete = Equaln(guess[1], lookat[1], logHowComplete[1]) -- , targetLength - adjustRound)
        --     if logHowComplete[1] > targetLength + 1 or logHowComplete[1] = logHowComplete[2] then
        --     -- if equal(guess[1], lookat[1]) then
        --         exit
        --     end if
        -- end if
        s = ReturnToUserCallBack(ID_Log, logHowComplete, targetLength, guess, lookat, radix)
        lookat = s[2]
        logHowComplete = s[3]
        if s[1] then
            exit
        end if
        logIterCount += 1
ifdef not NO_SLEEP_OPTION then
        sleep(nanoSleep)
end ifdef
    end while
    -- end for
    -- -- Step 4:
    -- if n != 0 then
    --     tmp = ToEun(n, radix, protoTargetLength)
    --     guess = AddExp(guess[1], guess[2], tmp[1], tmp[2], protoTargetLength, radix)
    -- end if
    if logIterCount = logIter then
        printf(1, "Error %d\n", 3)
        abort(1/0)
    end if
    guess = AdjustRound(guess[1], guess[2], targetLength, radix, NO_SUBTRACT_ADJUST)
    if isImag then -- return a complex number: guess must be positive.
        return { guess, GetPI(targetLength, radix) } -- (ret[3] - adjustPrecision)
    else
        return guess
    end if
end function

-- Begin EunLog1:

-- EunLogRadix()

global sequence eunLogRadix = {}

-- NOTE: To precalculate, put the largest value for targetLength first, then use the same radix for all your calculations, before switching to another radix.
-- Or, you can also use the "SwapE()" function below:

global function SwapLogRadix(sequence s = eunLogRadix) -- SwapE when changing radixes, then swap back when changing back.
    object oldvalue = eunLogRadix
    eunLogRadix = s
    return oldvalue
end function

global function EunLogRadix(TargetLength targetLength = defaultTargetLength, AtomRadix radix = defaultRadix)
    -- targetLength += adjustPrecision
    if not length(eunLogRadix) or not length(eunLogRadix[1]) or eunLogRadix[3] <= targetLength or eunLogRadix[4] != radix then
        eunLogRadix = LogExpB({1}, 1, targetLength + 1, radix)
    end if
    return AdjustRound(eunLogRadix[1], eunLogRadix[2], targetLength, radix, NO_SUBTRACT_ADJUST)
end function

-- EunLogTwo()

global sequence eunLogTwo = {}

-- NOTE: To precalculate, put the largest value for targetLength first, then use the same radix for all your calculations, before switching to another radix.
-- Or, you can also use the "SwapE()" function below:

global function SwapLogTwo(sequence s = eunLogTwo) -- SwapE when changing radixes, then swap back when changing back.
    object oldvalue = eunLogTwo
    eunLogTwo = s
    return oldvalue
end function

global function EunLogTwo(TargetLength targetLength = defaultTargetLength, AtomRadix radix = defaultRadix)
    -- targetLength += adjustPrecision
    if not length(eunLogTwo) or not length(eunLogTwo[1]) or eunLogTwo[3] <= targetLength or eunLogTwo[4] != radix then
        eunLogTwo = LogExpB({2}, 0, targetLength + 1, radix)
    end if
    return AdjustRound(eunLogTwo[1], eunLogTwo[2], targetLength, radix, NO_SUBTRACT_ADJUST)
end function

-- EunLog1()

global function EunLog1(Eun x)
    sequence logRadix, logTwo, tmp, ret, imag
    integer exp1, targetLength
    atom radix
    exp1 = x[2]
    targetLength = x[3]
    radix = x[4]
    -- Precalculate: log(radix), log(sqrt(2)) or log(2)
    logRadix = EunLogRadix(targetLength, radix)
    logTwo = EunLogTwo(targetLength, radix)
    -- tmp = 2 * x / radix^(exp1 + 1)
    tmp = MultiplyExp(x[1], -1, {2}, 0, targetLength, radix)
    -- ret = log(tmp)
    ret = LogExpA(tmp[1], tmp[2], tmp[3], tmp[4])
    if length(ret) = 2 then
        -- Complex number
        imag = ret[2]
        ret = ret[1]
    else
        imag = {}
    end if
    if not Eun(ret) then
        return ret
    end if
    -- ret = ret + ((exp1 + 1) * log(radix))
    tmp = AdjustRound({exp1 + 1}, 0, targetLength, radix, CARRY_ADJUST)
    tmp = MultiplyExp(tmp[1], tmp[2], logRadix[1], logRadix[2], targetLength, radix)
    ret = AddExp(ret[1], ret[2], tmp[1], tmp[2], targetLength, radix)
    -- ret = ret - log(2)
    ret = SubtractExp(ret[1], ret[2], logTwo[1], logTwo[2], targetLength, radix)
    if length(imag) then
        ret = {ret, imag}
    end if
    return ret
end function

-- End EunLog1.

global function EunLog(Eun m) --, object guess = 0)
    sequence tmp
    tmp = LogExpB(m[1], m[2], m[3], m[4]) --, guess) -- both parameters must be positive.
    return tmp
end function
