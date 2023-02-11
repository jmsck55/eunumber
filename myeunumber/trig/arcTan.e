-- Copyright (c) 2016-2023 James Cook



include ../../eunumber/minieun/common.e

global constant ID_ArcTan = 9

global PositiveOption arcTanMoreAccuracy = -1 -- if -1, then use calculationSpeed

global procedure SetArcTanMoreAccuracy(PositiveOption i)
    arcTanMoreAccuracy = i
end procedure
global function GetArcTanMoreAccuracy()
    return arcTanMoreAccuracy
end function

global integer arcTanIter = 1000000000
global integer arcTanCount = 0

global sequence arcTanHowComplete = {1, 0}

global function GetArcTanHowCompleteMin()
    return arcTanHowComplete[1]
end function

global function GetArcTanHowCompleteMax()
    return arcTanHowComplete[2]
end function

-- !!! Remember to use Radians (Rad) on these functions !!!

--https://en.wikipedia.org/wiki/Inverse_trigonometric_functions

--INCOMPLETE: arcSin and arcTan are experimental for now.

-- Begin ArcTan():

-- Calculating:
--
-- Given: [z is a complex number], [abs(z) is the absolute value of z], [ x! is x factorial, 3! == 1*2*3 ]
--
-- arctan(z) = z - (z^3)/3 + (z^5)/5 - (z^7)/7 + ....
-- arctan(z) == Sumation of (n=0 to +inf), (((-1)^n) * z^(2*n + 1))/(2*n + 1); abs(z) <= 1, z != i, -i
--
--
-- Leonhard Euler found a series for the arctangent that converges more quickly than its Taylor series:
-- {\displaystyle \arctan(z)={\frac {z}{1+z^{2}}}\sum _{n=0}^{\infty }\prod _{k=1}^{n}{\frac {2kz^{2}}{(2k+1)(1+z^{2})}}.}{\displaystyle \arctan(z)={\frac {z}{1+z^{2}}}\sum _{n=0}^{\infty }\prod _{k=1}^{n}{\frac {2kz^{2}}{(2k+1)(1+z^{2})}}.}
--
--                z        +inf         n             2kz^2
-- arctan(z) = ------- * Sumation of Product of --------------------
--             1 + z^2     n=0         k=1      (2k + 1) * (1 + z^2)
--
-- (The term in the sum for n = 0 is the empty product, so is 1.)
--
-- Alternatively, this can be expressed as:
-- arctan(z) == Sumation of (n=0 to +inf), ((2^(2*n) * (n!)^2)/((2*n + 1)!)) * ((z^(2*n + 1))/((1 + z^2)^(n + 1)))
--
--
-- Another series for the arctangent function is given by:
--
-- Given: [ i == sqrt(-1), the imaginary unit ]
--
-- arctan(z) = i * Sumation of (n=1 to +inf), (1 / (2*n - 1)) * ( (1 / ((1 + 2i/z)^(2*n - 1))) - (1 / ((1 - 2i/z)^(2*n - 1))) )
--
-- end of Calculating.


-- EunArcTan, function is coded above.

-- Method 1:
--
--             +inf      (-1)^n * z^(2*n+1)
-- arctan(z) = sumation( ------------------- )
--             n=0       (2*n+1)
--
-- for: [abs(z) <= 1, z != i, z != -i]

--HERE, code method 1, TODO!

--
--
-- ArctanExp funtion: (Method 2)
--
--             +inf      (2^(2*n)) * ((n!)^2) * (z^(2*n+1))
-- arctan(z) = sumation( ---------------------------------- )
--             n=0       ((2*n+1)!) * ((1+z^2)^(n+1))
--
-- function Myfactorial(integer f)
--      atom y
--      y = 1
--      --for i = 1 to f do
--      for i = 2 to f do
--              y *= i
--      end for
--      return y
-- end function
-- integer MyarctanIter = 80
-- function Myarctan(atom x)
--      atom sum, a, b, c, d, e, f
--      sum = x / (1 + x*x)
--      for n = 1 to MyarctanIter do
--              --a = power(2,2*n) -- [0]=1, [1]=4, [2]=16, [3]=64, [4]=256, [5]=1024, [6]=4096, [7]=16384, [8]=65536, [9]=262144, [10]=1048576,
--              a = power(4,n)
--              b = Myfactorial(n)
--              b *= b
--              c = Myfactorial(2*n + 1) -- [0]=1, [1]=6, [2]=120, [3]=5040, [4]=362880, [5]=39916800,
--              d = power(x, 2*n + 1) -- equals: x * power(x,2*n)
--              e = power(1 + x*x, n + 1) -- precalculate: (1 + x*x)
--              f = a * b
--              f = f / c
--              f = f * d
--              f = f / e
--              sum += f
--      end for
--      return sum
-- end function

-- Comments: Slow, and inaccurate.

--Next one to work on:

-- ArcTanExp, using continued fractions:

-- Status: Not done yet.

-- This method for arctan function is Too slow:

-- global integer arctanIter = 1000000000 -- 500
-- global integer lastIterCountArctan = 0
--
-- global function ArctanExp(sequence n1, integer exp1, TargetLength targetLength, integer radix)
-- -- works best with small numbers.
-- -- arctan(x) = x - ((x^3)/3) + ((x^5)/5) - ((x^7)/7) + ..., where abs(x) < 1
-- -- sine(x) = x - ((x^3)/(3!)) + ((x^5)/(5!)) - ((x^7)/(7!)) + ((x^9)/(9!)) - ...
--      sequence ans, a, b, tmp, xSquared, lookat
--      --integer step
--      --step = 1 -- SinExp() uses 1
--      xSquared = SquaredExp(n1, exp1, targetLength, radix)
--
--      a = {n1, exp1} -- a is the numerator, SinExp() starts with x.
--      b = {{1}, 0} -- b is the denominator.
--
--      -- copy x to ans:
--      ans = a -- in SinExp(), ans starts with x.
--      for i = 1 to arctanIter do -- start at 1 for all computer languages.
--              lookat = ans
--              -- first step is 3, for SinExp()
--              --step += 2
--              --tmp = MultiplyExp({step-1}, 0, {step}, 0, targetLength, radix)
--              --b = MultiplyExp(b[1], b[2], tmp[1], tmp[2], targetLength, radix)
--              b = AddExp(b[1], b[2], {2}, 0, targetLength, radix)
--              --b = {{step}, 0} -- "b" is "step" in arctan()
--
--              a = MultiplyExp(a[1], a[2], xSquared[1], xSquared[2], targetLength, radix)
--              tmp = DivideExp(a[1], a[2], b[1], b[2], targetLength, radix)
--
--              if IsPositiveOdd(i) then
--                      -- Subtract
--                      tmp[1] = Negate(tmp[1])
--              end if
--
--              ans = AddExp(ans[1], ans[2], tmp[1], tmp[2], targetLength, radix)
--              if length(ans[1]) > targetLength then
--                      ans[1] = ans[1][1..targetLength]
--              end if
--              if equal(ans, lookat) then
--                      lastIterCountArctan = i
--                      exit -- break
--              end if
--      end for
--
--      return ans
-- end function

-- End ArcTan().
