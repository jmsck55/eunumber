-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/eun/EunAdd.e
include ../../eunumber/eun/EunMultiply.e

include Complex.e


global function ComplexMultiply(Complex n1, Complex n2)
    -- n1 = (a+bi)
    -- n2 = (c+di)
    -- (a+bi)(c+di) <=> ac + adi + bci + bdii
    -- <=> (ac - bd) + (ad + bc)i
    sequence real, imag
    real = EunSubtract(EunMultiply(n1[1], n2[1]), EunMultiply(n1[2], n2[2]))
    imag = EunAdd(EunMultiply(n1[1], n2[2]), EunMultiply(n1[2], n2[1]))
    return {real, imag}
end function
