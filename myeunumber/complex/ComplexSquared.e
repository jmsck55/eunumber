-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/eun/EunAdd.e
include ../../eunumber/eun/EunMultiply.e

include Complex.e


global function ComplexSquared(Complex z)
    sequence real, imag
    real = EunSubtract(EunSquared(z[1]), EunSquared(z[2]))
    imag = EunMultiply(z[1], z[2])
    imag = EunAdd(imag, imag)
    return {real, imag}
end function
