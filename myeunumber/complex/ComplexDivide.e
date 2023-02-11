-- Copyright (c) 2016-2023 James Cook


include Complex.e
include ComplexMultiply.e
include ComplexMultiplicativeInverse.e

global function ComplexDivide(Complex n1, Complex n2)
-- correct!
    return ComplexMultiply(n1, ComplexMultiplicativeInverse(n2))
end function
