-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/eun/EunMultiply.e
include ../../eunumber/eun/EunNegate.e

include ../trig/EunCos.e
include ../trig/EunCosh.e
include ../trig/EunSin.e
include ../trig/EunSinh.e

include Complex.e


global function ComplexCosh(Complex z)
-- Cosine hyperbolic (cosh)
-- cosh(z) = (cosh(x) * cos(y)) - (sinh(x) * sin(y))i
    sequence real, imag
    real = EunMultiply(EunCosh(z[1]), EunCos(z[2]))
    imag = EunNegate(EunMultiply(EunSinh(z[1]), EunSin(z[2])))
    return {real, imag}
end function
