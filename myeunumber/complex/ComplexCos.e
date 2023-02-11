-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/eun/EunNegate.e
include ../../eunumber/eun/EunMultiply.e

include ../trig/EunCos.e
include ../trig/EunCosh.e
include ../trig/EunSin.e
include ../trig/EunSinh.e

include Complex.e


global function ComplexCos(Complex z)
-- cos(z) = (cos(x) * cosh(y)) - (sin(x) * sinh(y))i
    sequence real, imag
    real = EunMultiply(EunCos(z[1]), EunCosh(z[2]))
    imag = EunNegate(EunMultiply(EunSin(z[1]), EunSinh(z[2])))
    return {real, imag}
end function
