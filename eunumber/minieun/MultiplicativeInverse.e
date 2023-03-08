-- Copyright (c) 2016-2023 James Cook
-- Multiplicative Inverse "f(x) = 1 / x" functions of EuNumber.
-- include eunumber/MultiplicativeInverse.e

namespace multiplicativeInverse

include Nanosleep.e
include Common.e
include AddExp.e
include Multiply.e
include UserMisc.e
include AdjustRound.e
include Eun.e
include ReturnToUser.e
include Defaults.e
include ToAtom.e
include TrimZeros.e
include MathConst.e
--include FindIter.e

global PositiveOption multInvMoreAccuracy = -1 -- 15, if -1, then use calculationSpeed

global procedure SetMultiplicativeInverseMoreAccuracy(PositiveOption i)
    multInvMoreAccuracy = i
end procedure

global function GetMultiplicativeInverseMoreAccuracy()
    return multInvMoreAccuracy
end function

global integer iter = 1000000000 -- max number of iterations before returning
global integer lastIterCount = 0 -- MultiplicativeInverseExp has not been called yet, so the value is 0.

-- global constant ATOM_EPSILON = 2.22044604925031308085e-16 -- DBL_EPSILON 64-bit
--global constant LOG_ATOM_SMALLEST = -- log(DOUBLE_SMALLEST)
    -- -709.196208642166084246127866208553314208984375
    -- -709.7827128933839730962063185870647430419921875
--    -708.6097043909481953960494138300418853759765625
--global constant LOG_ATOM_LARGEST = -- log(DOUBLE_LARGEST)
    -- 709.196208642166084246127866208553314208984375
--    709.7827128933839730962063185870647430419921875
--    4.436141955583649831851289491169154644012451171875e+01

global sequence howComplete = {1, 0, {}} -- compare set to {}, means uninitialized.


global Bool divideByZeroFlag = FALSE

global function GetDivideByZeroFlag()
    return divideByZeroFlag
end function

global procedure SetDivideByZeroFlag(Bool i)
    divideByZeroFlag = i
end procedure

-- Division and Multiply Inverse:

global Bool useLongDivision = FALSE -- TRUE is slower.

global procedure SetUseLongDivision(integer i)
    useLongDivision = i -- increase this number for smaller radixes
end procedure

global function GetUseLongDivision()
    return useLongDivision
end function

constant two = {2}
PositiveInteger forSmallRadix = 0 -- this number can be 0 or greater

global procedure SetForSmallRadix(PositiveInteger i)
    forSmallRadix = i -- increase this number for smaller radixes
end procedure

global function GetForSmallRadix()
    return forSmallRadix
end function

global function ProtoMultiplicativeInverseExp(sequence guess, integer exp0, sequence den1, integer exp1, TargetLength targetLength, AtomRadix radix)
    -- a = guess
    -- n1 = den1
    -- f(a) = a * (2 - n1 * a)
    --
    -- Proof: for f(x) = 1/x
    -- f(a) = 2a - n1*a^2
    -- a = 2a - n1*a^2
    -- 0 = a - n1*a^2
    -- x = a
    -- ax^2 + bx + c = 0
    -- a=(- n1), b=1, c=0
    -- x = (-b +-sqrt(b^2 - 4ac)) / (2a)
    -- x = (-1 +-1) / (-2*n1)
    -- x = 0, 1/n1
    sequence tmp, numArray, ret
    integer exp2
    tmp = MultiplyExp(guess, exp0, den1, exp1, targetLength, radix) -- den1 * a
-- tmp -- turns to one
    numArray = tmp[1]
    exp2 = tmp[2]
    tmp = SubtractExp(two, 0, numArray, exp2, targetLength - (forSmallRadix), radix) -- 2 - tmp
-- tmp -- turns to one
    numArray = tmp[1]
    exp2 = tmp[2]
    if length(numArray) = 1 then
        if numArray[1] = 1 then
            if exp2 = 0 then
                -- signal_solution_found = 1
                return {guess, exp0}
            end if
        end if
    end if
    ret = MultiplyExp(guess, exp0, numArray, exp2, targetLength, radix) -- a * tmp
-- ret -- turns to ans
    return ret
end function


global function IntToDigits(atom x, AtomRadix radix)
    sequence numArray
    atom a
    numArray = {}
    while x != 0 do
        a = remainder(x, radix)
        numArray = prepend(numArray, a)
        x = RoundTowardsZero(x / radix) -- must be Round() to work on negative numbers
ifdef not NO_SLEEP_OPTION then
        sleep(nanoSleep)
end ifdef
    end while
    return numArray
end function

integer sigDigits = 0
integer minSigDigits = 0
integer maxSigDigits = 0
atom static_multInvRadix = 0
atom static_logRadix = 0

procedure set_div_static_vars(atom radix)
    atom tmp
    static_multInvRadix = radix
    static_logRadix = log(radix)
    --ifdef BITS64 then
    --      sigDigits = Ceil(18 / (static_logRadix / logTen))
    --elsedef
    -- Use double floating point, 52 explicitly stored bits
    --tmp = logTwo * 52 -- 53 bits at logTwo
    tmp = logTen * 13 -- 15 decimals at logTen
    sigDigits = floor(tmp / static_logRadix)
    --end ifdef
    --minSigDigits = floor(LOG_ATOM_SMALLEST / static_logRadix)
    maxSigDigits = floor(LOG_DOUBLE_INT_MAX / static_logRadix)
    minSigDigits = - (maxSigDigits)
end procedure

global function LongDivision(atom num, integer exp1, atom denom, integer exp2, TargetLength protoTargetLength, AtomRadix radix)
    integer exp0, optionNegOne
    atom quot
    sequence guess
    if static_multInvRadix != radix then
        set_div_static_vars(radix)
    end if
    optionNegOne = 1
    if num < 0 then
        num = - (num)
        optionNegOne *= -1
    end if
    if denom < 0 then
        denom = - (denom)
        optionNegOne *= -1
    end if
    if num <= denom then
        exp0 = 0
        while 1 do
            quot = floor(num / denom) * optionNegOne
            num = remainder(num, denom)
            num *= radix
            exp0 -= 1
            if quot != 0 then
                exit
            end if
ifdef not NO_SLEEP_OPTION then
            sleep(nanoSleep)
end ifdef
        end while
        guess = {quot}
    else
        quot = floor(num / denom) * optionNegOne
        num = remainder(num, denom)
        num *= radix
        exp0 = floor(log(quot) / static_logRadix)
        guess = IntToDigits(quot, radix)
    end if
    while num != 0 and length(guess) < protoTargetLength do
        quot = floor(num / denom) * optionNegOne
        num = remainder(num, denom)
        num *= radix
--        if length(guess) = 0 and quot = 0 then
--            exp0 -= 1
--        else
            guess = guess & {quot}
--        end if
ifdef not NO_SLEEP_OPTION then
        sleep(nanoSleep)
end ifdef
    end while
--    oldlen = length(guess)
--    guess = TrimLeadingZeros(guess)
--    exp0 += length(guess) - oldlen
    exp0 += exp1 - exp2 + 1
    return AdjustRound(guess, exp0, protoTargetLength, radix, NO_SUBTRACT_ADJUST)
end function

global function ExpToAtom(sequence n1, integer exp1, PositiveInteger targetLen, AtomRadix radix)
    atom p, ans, lookat, ele
    integer overflowBy
    if length(n1) = 0 then
        return 0 -- tried to divide by zero
    end if
    if static_multInvRadix != radix then
        set_div_static_vars(radix)
    end if
    -- what if exp1 is too large?
    overflowBy = exp1 - maxSigDigits + 2 -- +2 may need to be bigger
        -- overflowBy = exp1 - floor(LOG_ATOM_MAX / p) + 2 -- +2 may need to be bigger
    if overflowBy > 0 then
        -- overflow warning in "power()" function
        -- reduce size
        exp1 -= overflowBy
    else
        -- what if exp1 is too small?
        overflowBy = exp1 - minSigDigits - 2 -- -2 may need to be bigger
        -- overflowBy = exp1 - floor(LOG_ATOM_MIN / p) - 2 -- -2 may need to be bigger
        if overflowBy < 0 then
            exp1 -= overflowBy
        else
            overflowBy = 0
        end if
    end if
    exp1 -= targetLen
    p = power(radix, exp1)
    ans = n1[1] * p
    for i = 2 to length(n1) do
        p = p / radix
        ele = n1[i]
        if ele != 0 then
            lookat = ans
            ans += ele * p
            if ans = lookat then
                exit
            end if
        end if
ifdef not NO_SLEEP_OPTION then
        sleep(nanoSleep)
end ifdef
    end for
    -- if overflowBy is positive, then there was an overflow
    -- overflowBy is an offset of that overflow in the given radix
    return {ans, overflowBy}
end function

global function GetGuessExp(sequence den, integer exp1, TargetLength protoTargetLength, AtomRadix radix)
    sequence guess, tmp
    atom denom, one, ans
    integer raised, mySigDigits, exp2
    object val
    if static_multInvRadix != radix then
        set_div_static_vars(radix)
    end if
    if protoTargetLength < sigDigits then
        mySigDigits = protoTargetLength
    else
        mySigDigits = sigDigits
    end if
    
    if useLongDivision then
        val = ToAtom(NewEun(den, exp1, protoTargetLength, radix))
        if atom(val) and val != 0 then
            denom = val
            val = floor(log(abs(denom)) / static_logRadix)
            if integer(val) then
                exp2 = val
                denom = denom / power(radix, exp2)
                tmp = LongDivision(1, 0, denom, exp2, protoTargetLength, radix)
                return tmp
            end if
        end if
    end if
    raised = length(den) - 1
    tmp = ExpToAtom(den, raised, mySigDigits, radix)
    denom = tmp[1]
    raised -= tmp[2]
    one = power(radix, raised)
    ans = Round(one / denom) -- try this.
    -- ans = RoundTowardsZero(one / denom)
    guess = IntToDigits(ans, radix) -- works on negative numbers
    -- tmp = AdjustRound(guess, exp1, mySigDigits - 1, radix, FALSE)
    -- tmp[3] = protoTargetLength
    tmp = AdjustRound(guess, - (exp1) - 1, protoTargetLength, radix, NO_SUBTRACT_ADJUST)
    return tmp
end function

global constant ID_MultiplicativeInverse = 2

global function MultiplicativeInverseExp(sequence den1, integer exp1, TargetLength targetLength, AtomRadix radix, sequence guess = {})
    sequence lookat, ret, s
    integer exp0, protoTargetLength, protoMoreAccuracy
    howComplete = {1, 0, {}}
    den1 = TrimTrailingZeros(den1)
    if length(den1) = 0 then
        lastIterCount = 1
        divideByZeroFlag = 1
        printf(1, "Error %d\n", 1)
        abort(1/0)
    end if
    if length(den1) = 1 then
        if den1[1] = 1 or den1[1] = -1 then -- optimization
            howComplete = {1, 1, {}}
            lastIterCount = 1
            exp0 = -(exp1)
            return NewEun(den1, exp0, targetLength, radix)
        end if
        if den1[1] = 2 or den1[1] = -2 then
            object half = floor(radix / 2)
            if den1[1] < 0 then
                half = -(half)
            end if
            if IsIntegerEven(radix) then
                half = {half}
            else
                half = repeat(half, targetLength)
            end if
            exp0 = -(exp1) - 1
            return NewEun(half, exp0, targetLength, radix)
        end if
    end if
    if multInvMoreAccuracy >= 0 then
        protoMoreAccuracy = multInvMoreAccuracy
    elsif calculationSpeed then
        protoMoreAccuracy = Ceil(targetLength / calculationSpeed)
    else
        protoMoreAccuracy = 0 -- changed to 0
    end if
    protoTargetLength = targetLength + protoMoreAccuracy + 1
    if length(guess) then
        exp0 = - (exp1) - 1
        ret = AdjustRound(guess, exp0, protoTargetLength, radix, FALSE)
    else
        -- factor out a power of radix, from both the numerator and the denominator,
        -- then multiply them later.
        ret = GetGuessExp(den1, exp1, protoTargetLength, radix)
        --guess = ret[1]
        --exp0 = ret[2]
    end if
    lookat = {}
    calculating = ID_MultiplicativeInverse -- begin calculating
    lastIterCount = 1
    while calculating and lastIterCount <= iter do
    -- for i = 1 to iter do
        --lookat = ret
        ret = ProtoMultiplicativeInverseExp(ret[1], ret[2], den1, exp1, protoTargetLength, radix)
        --guess = ret[1]
        -- ? {length(guess), protoTargetLength}
        --exp0 = ret[2]

        --if useExtraAdjustRound then
        --ret = AdjustRound(guess, exp0, targetLength + 1, radix, NO_SUBTRACT_ADJUST)
        --end if

        --if ret[2] = lookat[2] then
        --    howComplete = Equaln(ret[1], lookat[1], howComplete[1]) -- , targetLength + adjustRound)
        --    if howComplete[1] > targetLength + 1 or howComplete[1] = howComplete[2] then
        --    -- if equal(ret[1], lookat[1]) then
        --        exit
        --    end if
        --end if

        -- NOTE: most or all loops are like this one: TODO: [x] done.

        --This code only works on this function:
        if length(ret) = 2 then
            -- solution found:
            howComplete = {}
        end if
        s = ReturnToUserCallBack(ID_MultiplicativeInverse, howComplete, targetLength, ret, lookat, radix)
        lookat = s[2]
        howComplete = s[3]
        if s[1] then
            exit
        end if

        lastIterCount += 1
ifdef not NO_SLEEP_OPTION then
        sleep(nanoSleep)
end ifdef
    end while
    -- end for
    if lastIterCount = iter then
        printf(1, "Error %d\n", 2)
        abort(1/0)
    end if
    ret = AdjustRound(ret[1], ret[2], targetLength, radix, NO_SUBTRACT_ADJUST)
    return ret
end function

-- See also:
-- https://en.wikipedia.org/wiki/Newton%27s_method#Multiplicative_inverses_of_numbers_and_power_series
