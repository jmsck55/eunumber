-- Copyright (c) 2016-2023 James Cook
-- "AdjustRound" functions of EuNumber.
-- include eunumber/AdjustRound.e

namespace adjustround

include ../array/Carry.e
include ../array/Subtract.e
include Common.e
include Defaults.e
include TrimZeros.e
include NanoSleep.e
include MultiTasking.e


global constant CARRY_ADJUST = 0, BORROW_ADJUST = 1, NO_SUBTRACT_ADJUST = 2

-- TODO, test AdjustRound(), not done yet.

global function AdjustRound(sequence num, integer exponent, TargetLength targetLength, AtomRadix radix, ThreeOptions isMixed = 1)
    integer oldlen, roundTargetLength, rounded, isNeg
    atom halfRadix, compareHalfRadix, f
    sequence ret, roundedDigits
    ifdef USE_TASK_YIELD then
        if useTaskYield then
            task_yield()
        end if
    end ifdef
    roundedDigits = {}
    -- if not CheckLengthAndRadix(targetLength, radix) then
    --      puts(2, "Error, bad length and radix.\n")
    --      abort(1/0)
    -- end if
    if targetLength < 0 then
        -- -- suppress error
        -- exponent += targetLength
        -- targetLength = 0
        abort(1/0) -- don't suppress error anymore.
    end if
    oldlen = length(num)
    num = TrimLeadingZeros(num)
    if isMixed != NO_SUBTRACT_ADJUST then
        --adjustExponent()
        -- in Subtract, the first element of num cannot be a zero.
        num = Subtract(num, radix, isMixed)
        -- NOTE: Use Subtract() when there are both negative and positive numbers.
        -- otherwise, you can use Carry().
        num = TrimLeadingZeros(num)
    end if
    exponent += (length(num) - (oldlen))
    -- rounded = 0
    --if length(num) = 0 then
    --    ret = {{}, exponent, targetLength, radix} --, rounded}
    --    return ret
    --end if

    --if COMPRESS_LEAD then -- Use function, CompressLeadingDigit(), instead.
    --      f = num[1]
    --      if abs(f) <= COMPRESS_LEAD then
    --              num = num[2..$]
    --              f *= radix
    --              if length(num) then
    --                      num[1] += f
    --              else
    --                      num = {f}
    --              end if
    --              exponent -= 1
    --      end if
    --end if

    -- Round2: num, exponent, targetLength, radix
    roundTargetLength = targetLength
    if isRoundToZero then
        if exponent <= - (targetLength) then
            if targetLength = 1 and exponent = -1 then
                num = {0} & num
                exponent = 0
                roundTargetLength = 1
            else
                roundTargetLength = 0
            end if
            --ret = {{}, exponent, targetLength, radix} --, (num[1] < 0) - (num[1] > 0)} -- "rounded"
            --return ret
        end if
    elsif ROUND_TO_NEAREST_OPTION then -- IntegerMode
        roundTargetLength = exponent + 1 + integerModeFloat
        if roundTargetLength < 0 then
            roundTargetLength = 0
        elsif roundTargetLength = 0 then
            num = {0} & num
            exponent += 1
            roundTargetLength = 1
        end if
        if roundTargetLength > targetLength then
            targetLength = roundTargetLength
        end if
    end if
    if roundTargetLength < length(num) and roundTargetLength >= 0 then
        roundedDigits = {{0} & num[roundTargetLength + 1..$], exponent - roundTargetLength + 1}
        isNeg = num[1] < 0
        if ROUND = ROUND_TRUNCATE then --or roundTargetLength = 0 then
            -- rounded = isNeg - (num[1] > 0) -- give the opposite of the sign
            num = num[1..roundTargetLength]
        elsif roundTargetLength = 0 then
            num = {}
        else
            halfRadix = floor(radix / 2)
            f = num[roundTargetLength + 1]
            if isNeg then
                compareHalfRadix = - (halfRadix)
            else
                compareHalfRadix = halfRadix
            end if
            if integer(radix) and IsIntegerOdd(radix) then
                -- feature: support for odd radixes
                for i = roundTargetLength + 2 to length(num) do
                    if f != compareHalfRadix then
                        exit
                    end if
                    f = num[i]
ifdef not NO_SLEEP_OPTION then
                    sleep(nanoSleep)
end ifdef
                end for
            end if
            if f = compareHalfRadix then
                if length(num) > roundTargetLength then
                    f *= 2
                else
                    if ROUND = ROUND_EVEN then
                        halfRadix -= IsIntegerOdd(num[roundTargetLength])
                    elsif ROUND = ROUND_ODD then
                        halfRadix -= IsIntegerEven(num[roundTargetLength])
                    elsif ROUND = ROUND_ZERO then
                        f = 0
                    end if
                end if
            elsif ROUND = ROUND_INF then -- round towards plus(+) and minus(-) infinity
                halfRadix -= 1
            elsif ROUND = ROUND_POS_INF then -- round towards plus(+) infinity
                f += 1
            elsif ROUND = ROUND_NEG_INF then -- round towards minus(-) infinity
                f -= 1
            end if
            num = num[1..roundTargetLength]
            rounded = (f > halfRadix) - (f < - (halfRadix))
            if rounded then
                roundedDigits[1][1] = - (rounded)
                num[roundTargetLength] += rounded
                if rounded <= 0 then
                    num = Carry(num, radix)
                else
                    num = NegativeCarry(num, radix)
                end if
                --if COMPRESS_LEAD then -- Use function, CompressLeadingDigit(), instead.
                --      f = num[1]
                --      if abs(f) <= COMPRESS_LEAD then
                --              num = num[2..$]
                --              f *= radix
                --              if length(num) then
                --                      num[1] += f
                --              else
                --                      num = {f}
                --              end if
                --              --exponent -= 1
                --      end if
                --end if
                oldlen = length(num) - (roundTargetLength)
                if ROUND_TO_NEAREST_OPTION then
                    targetLength += oldlen -- Under integerMode, targetLength always increases as value increases.
                end if
                exponent += oldlen
            -- else
                -- rounded = isNeg - (num[1] > 0) -- give the opposite of the sign
            end if
        end if
    end if
    if length(num) then
        num = TrimTrailingZeros(num)
        oldlen = length(num)
        num = TrimLeadingZeros(num)
        exponent += (length(num) - (oldlen))
    else
        exponent = 0
    end if
    ret = {num, exponent, targetLength, radix, roundedDigits} -- why do we need "rounded" variable?  Could it be significant digits?
    return ret
end function

