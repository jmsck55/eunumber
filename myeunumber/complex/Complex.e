-- Copyright (c) 2016-2023 James Cook

-- Complex number functions

-- What are complex number?  Follow the links below:
-- https://www.purplemath.com/modules/complex.htm
-- https://www.purplemath.com/modules/complex2.htm
-- https://www.purplemath.com/modules/complex3.htm


namespace complex


include ../../eunumber/minieun/Eun.e
include ../../eunumber/minieun/common.e


global constant REAL = 1, IMAG = 2

global type Complex(object x)
    if sequence(x) then
        if length(x) = 2 then
            if Eun(x[1]) then
                if Eun(x[2]) then
                    return 1
                end if
            end if
        end if
    end if
    return 0
end type

global function NewComplex(Eun real = NewEun(), Eun imag = NewEun())
    return {real, imag}
end function

global function ComplexRealPart(Complex z)
    return z[REAL]
end function

global function ComplexImaginaryPart(Complex z)
    return z[IMAG]
end function

global function MakeComplex(Eun a, Bool isImag = FALSE)
    Complex z
    if isImag then
        z = NewComplex(, a)
    else
        z = NewComplex(a, )
    end if
    return z
end function

global function MakeComplexFromList(sequence ret)
    integer isImag = ret[1]
    sequence z = repeat(0, length(ret) - 1)
    for i = 1 to length(z) do
        z[i] = MakeComplex(ret[i + 1], isImag)
    end for
    return z
end function
