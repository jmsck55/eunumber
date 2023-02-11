-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/eun/EunNegate.e
include ../../eunumber/eun/EunMultiply.e

include ../trig/EunCos.e
include ../trig/EunCosh.e
include ../trig/EunSin.e
include ../trig/EunSinh.e

include Complex.e


global function ComplexSinh(Complex z)
-- Sinus hyperbolic (sinh)
-- sinh(z) = (sinh(x) * cos(y)) - (cosh(x) * sin(y))i
    sequence real, imag
    real = EunMultiply(EunSinh(z[1]), EunCos(z[2]))
    imag = EunNegate(EunMultiply(EunCosh(z[1]), EunSin(z[2])))
    return {real, imag}
end function
