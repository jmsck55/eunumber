-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/Eun.e
include ../../eunumber/minieun/common.e
include ../../eunumber/minieun/defaults.e
include ../../eunumber/minieun/usermisc.e
include ../../eunumber/eun/EunAdd.e
include ../../eunumber/eun/EunMultiply.e
include ../../eunumber/eun/EunMultiplicativeInverse.e

include ../myeun/EunSquareRoot.e

include Complex.e
include ComplexAbsoluteValue.e
include ComplexAdjustRound.e


global PositiveOption complexSquareRootMoreAccuracyA = -1 -- 6

global procedure SetComplexSquareRootMoreAccuracyA(integer i)
    complexSquareRootMoreAccuracyA = i
end procedure

global function GetComplexSquareRootMoreAccuracyA()
    return complexSquareRootMoreAccuracyA
end function


global function ComplexSquareRootA(Complex z)
    -- abs(z) = sqrt(x^2 + y^2)
    -- sqrt(z) = sqrt(x + yi) = +-(sqrt((abs(z) + x)/2) + sqrt((abs(z) - x)/2)i)
    sequence tmp, half, s = z
    integer protoMoreAccuracy
    -- use calculationSpeed.
    if complexSquareRootMoreAccuracyA >= 0 then
        protoMoreAccuracy = complexSquareRootMoreAccuracyA
    elsif calculationSpeed then
        protoMoreAccuracy = Ceil(s[complex:REAL][3] / calculationSpeed)
    else
        protoMoreAccuracy = 0 -- changed to 0
    end if
    protoMoreAccuracy += 1
    for i = 1 to 2 do
        s[i][3] += protoMoreAccuracy
    end for
    tmp = ComplexAbsoluteValue(s) -- returns an Eun
    s = {EunAdd(tmp, s[complex:REAL]), EunSubtract(tmp, s[complex:REAL])}
    half = EunMultiplicativeInverse(NewEun({2}, 0, tmp[3], tmp[4]))
    for i = 1 to 2 do
        tmp = EunSquareRoot(EunMultiply(s[i], half))
        --if tmp[1] then
            -- numbers in "tmp" are imaginary, this should never happen.
            -- if it does happen, then it's a coding error.
        --end if
        s[i] = tmp[2..3]
    end for
    s = {ComplexAdjustRound({s[REAL][1], s[IMAG][1]}, protoMoreAccuracy),
            ComplexAdjustRound({s[REAL][2], s[IMAG][2]}, protoMoreAccuracy)}
    return s
end function
