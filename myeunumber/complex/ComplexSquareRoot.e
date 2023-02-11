-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/array/negate.e
include ../../eunumber/minieun/common.e
include ../../eunumber/minieun/defaults.e
include ../../eunumber/minieun/Eun.e
include ../../eunumber/minieun/usermisc.e
include ../../eunumber/eun/EunAdd.e
include ../../eunumber/eun/EunMultiply.e
include ../../eunumber/eun/EunDivide.e
include ../../eunumber/eun/EunAdjustRound.e

include ../myeun/EunSquareRoot.e

include Complex.e


global PositiveOption complexSquareRootMoreAccuracy = -1 -- 6

global procedure SetComplexSquareRootMoreAccuracy(integer i)
    complexSquareRootMoreAccuracy = i
end procedure

global function GetComplexSquareRootMoreAccuracy()
    return complexSquareRootMoreAccuracy
end function

global function ComplexSquareRoot(Complex a)
    --
    -- This equation takes REAL numbers as input to "x" and "y"
    -- So, they use the NON-complex functions to calculate them.
    -- sqrt(x + iy) <=> (1/2) * sqrt(2) * [ sqrt( sqrt(x*x + y*y) + x )  +  i*sign(y) * sqrt( sqrt(x*x + y*y) - x ) ]
    --
    -- NOTE: results are both positive and negative. Remember i (the imaginary part) is always both positive and negative in mathematics.
    -- NOTE: So, you will need to factor that information into your equations.
    Eun x, y, n1, n2, tmp, tmptwo
    sequence t, s = a
    integer protoMoreAccuracy
    -- use calculationSpeed.
    if complexSquareRootMoreAccuracy >= 0 then
        protoMoreAccuracy = complexSquareRootMoreAccuracy
    elsif calculationSpeed then
        protoMoreAccuracy = Ceil(a[complex:REAL][3] / calculationSpeed)
    else
        protoMoreAccuracy = 0 -- changed to 0
    end if
    protoMoreAccuracy += 1
    for i = 1 to length(s) do
        s[i][3] += protoMoreAccuracy
    end for
    x = s[1]
    y = s[2]
    for i = 1 to 2 do
        s[i] = EunSquared(s[i])
    end for
    tmp = EunAdd(s[1], s[2]) -- x^2 + y^2
    t = EunSquareRoot(tmp) -- should not return an imaginary number
    tmp = t[2] -- data member, get the postive answer
    s[1] = EunAdd(tmp, x) -- a.real, (sqrt(x^2 + y^2) + x)
    s[2] = EunSubtract(tmp, x) -- a.real, (sqrt(x^2 + y^2) - x), round down
    for i = 1 to 2 do
        t = EunSquareRoot(s[1]) -- could check "isImaginaryFlag", but will always return real number
        if t[1] then
            printf(1, "Error %d\n", 6)
            abort(1/0)
        end if
        s[i] = t[2]
    end for
    if IsNegative(y[1]) then -- a.imag
        s[2][1] = Negate(s[2][1])
    end if
    tmptwo = NewEun({2}, 0, x[3], x[4])
    t = EunSquareRoot(tmptwo) -- {isImag, val1, val2}
    tmp = t[2] -- positive value, --here, are there more answers to this equation if "s" is negative?
    tmp = EunDivide(tmp, tmptwo)
    for i = 1 to length(s) do
        s[i] = EunMultiply(s[i], tmp)
        s[i][3] -= protoMoreAccuracy
        s[i] = EunAdjustRound(s[i])
    end for
    return s
end function
