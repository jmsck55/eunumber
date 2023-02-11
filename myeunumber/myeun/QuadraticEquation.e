-- Copyright (c) 2016-2023 James Cook
-- QuadraticEquation.e

include ../../eunumber/minieun/Eun.e
include ../../eunumber/eun/EunAdd.e
include ../../eunumber/eun/EunNegate.e
include ../../eunumber/eun/EunMultiply.e
include ../../eunumber/eun/EunMultiplicativeInverse.e

include ../myeun/EunSquareRoot.e

include ../complex/complex.e
include ../complex/ComplexMultiply.e

-- The Quadratic Equation
--
-- ax^2 + bx + c = 0
--
-- x = (-b +-sqrt(b^2 - 4ac)) / (2a)
--
-- x1 = (-b + sqrt(b^2 - 4ac)) / (2a)
-- x2 = (-b - sqrt(b^2 - 4ac)) / (2a)
--
-- 4*a*c
-- Negate
-- b*b
-- Subtract
-- sqrt
-- b
-- Negate
-- Add/Subtract
-- 2a
-- divide
--
-- two answers

global function EunQuadraticEquation(Eun a, Eun b, Eun c)
    Eun n1, n2, n3, ans, tmp
    Complex c1, c2, c3
    sequence s
    if a[4] != b[4] or a[4] != c[4] then
        return 0
    end if
    if a[3] != b[3] or a[3] != c[3] then
        return 0
    end if
    ans = EunMultiply(a, c)
    ans = EunMultiply({{4}, 0, a[3], a[4]}, ans)
    ans = EunNegate(ans)
    tmp = EunMultiply(b, b)
    ans = EunAdd(tmp, ans)
    s = EunSquareRoot(ans)
    tmp = EunNegate(b)
    if s[1] then -- isImaginary, treat is as a Complex number
        -- Complex
        c1 = NewComplex(tmp, s[2]) -- (-b) + ans * i
        c2 = NewComplex(tmp, s[3]) -- (-b) - ans * i
        tmp = EunMultiply({{2}, 0, a[3], a[4]}, a)
        n3 = EunMultiplicativeInverse(tmp)
        c3 = NewComplex(n3, {{}, 0, a[3], a[4]})
        c1 = ComplexMultiply(c1, c3)
        c2 = ComplexMultiply(c2, c3)
        return {c1, c2}
    else
        n1 = EunAdd(tmp, s[2])
        n2 = EunAdd(tmp, s[3])
        tmp = EunMultiply({{2}, 0, a[3], a[4]}, a)
        tmp = EunMultiplicativeInverse(tmp)
        n1 = EunMultiply(n1, tmp)
        n2 = EunMultiply(n2, tmp)
        return {n1, n2}
    end if
end function

