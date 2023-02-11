-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/eun/EunAdd.e
include ../../eunumber/eun/EunDivide.e

include ../trig/EunCos.e
include ../trig/EunCosh.e
include ../trig/EunSin.e
include ../trig/EunSinh.e

include Complex.e


global function ComplexTan(Complex z)
-- z = Real(x) + Imaginary(y)
-- f(x,y) = cos(2x) + cosh(2y)
-- tan(z) = (sin(2x)/f(x,y)) + (sin(2y)/f(x,y))i
    sequence x2, y2, a, real, imag
    x2 = EunAdd(z[complex:REAL], z[complex:REAL])
    y2 = EunAdd(z[complex:IMAG], z[complex:IMAG])
    a = EunAdd(EunCos(x2), EunCosh(y2))
    real = EunDivide(EunSin(x2), a)
    imag = EunDivide(EunSin(y2), a)
    return {real, imag}
end function
