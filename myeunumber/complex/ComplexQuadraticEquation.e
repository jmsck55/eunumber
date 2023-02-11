-- Copyright (c) 2016-2023 James Cook


include Complex.e
include ComplexAdd.e
include ComplexSubtract.e
include ComplexNegate.e
include ComplexMultiply.e
include ComplexMultiplicativeInverse.e
include ComplexSquareRoot.e


global function ComplexQuadraticEquation(Complex a, Complex b, Complex c)
    --done.
    -- About the Quadratic Equation:
    --
    -- The quadratic equation produces two answers (the answers may be the same)
    -- ax^2 + bx + c
    -- f(a,b,c) = (-b +-sqrt(b*b - 4*a*c)) / (2*a)
    -- answer[0] = ((-b + sqrt(b*b - 4*a*c)) / (2*a))
    -- answer[1] = ((-b - sqrt(b*b - 4*a*c)) / (2*a))
    --
    -- The "Complex" quadratic equation produces about 2 results
    --
    Complex ans, tmp
    sequence s
    ans = ComplexMultiply(a, c) -- a * c
    tmp = NewComplex({{4}, 0, a[1][3], a[1][4]}, {{}, 0, a[2][3], a[2][4]}) -- {real: 4, imag: 0}
    ans = ComplexMultiply(tmp, ans) -- 4 * a * c
    tmp = ComplexMultiply(b, b) -- b * b
    ans = ComplexSubtract(tmp, ans) -- b * b - 4 * a * c
    s = ComplexSquareRoot(ans) -- sqrt(b * b - 4 * a * c)
    tmp = ComplexNegate(b)
    s[1] = ComplexAdd(s[1], tmp) -- (-b + sqrt(b * b - 4 * a * c))
    s[2] = ComplexAdd(s[2], tmp) -- s[2] is already negative
    ans = ComplexAdd(a, a) -- 2 * a
    ans = ComplexMultiplicativeInverse(ans) -- (1 / (2 * a))
    s[1] = ComplexMultiply(s[1], ans)
    s[2] = ComplexMultiply(s[2], ans)
    return s
end function
