-- Copyright (c) 2016-2023 James Cook

-- NOTE: Includes a file from the "trig" folder.

include ../../eunumber/minieun/Eun.e
include ../../eunumber/minieun/common.e
include ../../eunumber/eun/EunAdd.e
include ../../eunumber/eun/EunMultiply.e
include ../../eunumber/eun/EunDivide.e

include ../myeun/EunNthRoot.e
include ../myeun/EunSquareRoot.e

include ../trig/EunSin.e

--triangulation.e

-- Triangulation using two (2) points

-- Given: angle A, angle B, distance D (distance between angles A and B)
-- Find distance E and F, (from angle A and B), to intersect point.
-- C is a temporary value.

-- Proof:
-- NOTE: uses all positive numbers
--
-- define:
-- observer at point A, angle A from distance D
-- observer at point B, angle B from distance D
-- distance D between point A and point B
-- distance E coming from angle A
-- distance F coming from angle B
-- height G at right angles (tangent) to distance D
-- X^2 <=> X*X
--
-- G <=> E * sin(A) <=> F * sin(B)
-- divide one by the other, equalling value of one (1)
-- ratio: F / E == sin(A) / sin(B)
-- F == E * sin(A) / sin(B)
-- Pythagorean Theorem:
-- D^2 = E^2 + F^2
-- F == sqrt(D^2 - E^2)
-- D^2 == E^2 + (E * sin(A) / sin(B))^2
-- D^2 == E^2 + E^2 * (sin(A) / sin(B))^2
-- D^2 == E^2 * (1 + (sin(A) / sin(B))^2)
-- E == sqrt(D^2 / (1 + (sin(A) / sin(B))^2))
-- ratio inverted for "F":
-- F == sqrt(D^2 / (1 + (sin(B) / sin(A))^2))
--
-- End of Proof

global function EunTriangulation(Eun angleA, Eun angleB, Eun distance, WhichOnes whichOnes = 3)
    Eun dsquared, sa, sb
    sequence s, tmp
    integer mode
    if IsNegative(angleA[1]) or IsNegative(angleB[1]) or IsNegative(distance[1]) then
        printf(1, "Error %d\n", 6)
        abort(1/0)
    end if
    mode = realMode
    realMode = TRUE
    sa = EunSin(angleA)
    sb = EunSin(angleB)
    dsquared = EunSquared(distance)
    s = {0, 0}
    if and_bits(whichOnes, 1) then
        tmp = EunSquareRoot(
            EunDivide(
                dsquared,
                EunAdd({{1}, 0, angleA[3], angleA[4]}, EunSquared(EunDivide(sa, sb)))
            )
        )
        s[1] = tmp[2]
    end if
    if and_bits(whichOnes, 2) then
        tmp = EunSquareRoot(
            EunDivide(
                dsquared,
                EunAdd({{1}, 0, angleA[3], angleA[4]}, EunSquared(EunDivide(sb, sa)))
            )
        )
        s[2] = tmp[2]
    end if
    realMode = mode
    return s -- {n1, n2}
end function

