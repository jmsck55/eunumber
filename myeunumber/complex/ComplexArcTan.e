-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/eun/EunAdd.e
include ../../eunumber/eun/EunNegate.e
include ../../eunumber/eun/EunMultiplicativeInverse.e

include Complex.e
include ComplexSubtract.e
include ComplexMultiply.e
include ComplexLog.e


global function ComplexArcTan(Complex z)
-- Given: arctan(x + iy), z = x + iy
-- (1/2) * i * log(1 - i(x + iy)) - (1/2) * i * log(1 + i(x + iy))
-- (1/2) * i * (log(-ix + y + 1) - log(ix - y + 1))
-- (1/2) * i * (log(1 - i * z) - log(1 + i * z))
    sequence x, y, a, b, tmp
    x = z[complex:REAL]
    y = z[complex:IMAG]
    tmp = {{1}, 0, y[3], y[4]}
    a = ComplexLog({EunAdd(tmp, y), EunNegate(x)})
    b = ComplexLog({EunSubtract(tmp, y), x})
    tmp[1][1] = 2
    tmp = EunMultiplicativeInverse(tmp)
    tmp = ComplexMultiply({{{}, 0, y[3], y[4]}, tmp}, ComplexSubtract(a, b))
    return tmp
end function
