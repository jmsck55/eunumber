-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/eun/EunAdd.e
include ../../eunumber/eun/EunMultiply.e

include ../myeun/EunSquareRoot.e

include Complex.e


global function ComplexAbsoluteValue(Complex z)
-- same as: ComplexModulus or ComplexMagnitude

-- Abs[z] == Sqrt[z Conjugate[z]]

-- abs(z) = sqrt(z * conj(z))
-- abs(x + iy) = sqrt((x + iy)(x - iy))

-- (x + iy)(x - iy) = x*x -x*iy +x*iy -iy*iy
-- x^2 - (iy)^2
-- x^2 + y^2

-- abs(x + iy) = sqrt(x^2 + y^2)

    sequence s
    s = EunAdd(EunSquared(z[complex:REAL]), EunSquared(z[complex:IMAG]))
    s = EunSquareRoot(s)
    return s[2] -- return the positive real part
end function
