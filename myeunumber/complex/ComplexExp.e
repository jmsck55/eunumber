-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/eun/EunMultiply.e

include ../myeun/EunExp.e

include ../trig/EunCos.e
include ../trig/EunSin.e

include Complex.e


global function ComplexExp(Complex z)
-- ComplexExponent()
    sequence a, real, imag
    a = EunExp(z[1])
    real = EunMultiply(a, EunCos(z[2]))
    imag = EunMultiply(a, EunSin(z[2]))
    return {real, imag}
end function
