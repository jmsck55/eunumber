-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/eun/EunAdd.e
include ../../eunumber/eun/EunMultiply.e
include ../../eunumber/eun/EunDivide.e

include ../myeun/EunLog.e

include ../trig/EunArcTan2.e

include Complex.e


global function ComplexLog(Complex z)
-- Natural Logarithm
-- ln(z) = (ln(x^2 + y^2)/2) + arctan(y/x)i
    sequence real, imag
    real = EunLog(EunAdd(EunSquared(z[1]), EunSquared(z[2])))
    real = EunDivide(real, {{2}, 0, z[1][3], z[1][4]})
    imag = EunArcTan2(z[2], z[1])
    return {real, imag}
end function
