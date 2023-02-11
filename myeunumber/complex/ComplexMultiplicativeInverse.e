-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/eun/EunNegate.e
include ../../eunumber/eun/EunAdd.e
include ../../eunumber/eun/EunMultiply.e
include ../../eunumber/eun/EunMultiplicativeInverse.e

include Complex.e


global function ComplexMultiplicativeInverse(Complex n2)
-- Reciprocal
    -- Eun a, b, c
    -- (a+bi)(a-bi) <=> a*a + b*b
    -- n2 = (a+bi)
    -- a = n2[1]
    -- b = n2[2]
    -- 1 / n2 <=> (a-bi) / (a*a + b*b)
    -- <=> (a / (a*a + b*b)) - (b / (a*a + b*b))i
    -- c = (a*a + b*b)
    -- <=> (a / c) - (b / c)i
    sequence a, b, c, real, imag
    a = n2[1]
    b = n2[2]
    c = EunMultiplicativeInverse(EunAdd(EunSquared(a), EunSquared(b)))
    real = EunMultiply(a, c)
    imag = EunNegate(EunMultiply(b, c))
    return {real, imag}
end function
