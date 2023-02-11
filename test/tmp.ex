-- Copyright (c) 2016-2023 James Cook

with trace

include ../eunumber/my.e

object a, b, c, d

--trace(1)

-- Used when debugging code.
abort(1)

puts(1, "Waiting.\n")

isRoundToZero = TRUE

defaultTargetLength = 140 -- 35

a = ToEun("3.14")
-- a = GetPI()

constant big1 =
{
  {-9,-9,-9,-9,-9,-8,-7,-3,-1,-7,-2,-7,-5,-3,-9,-5,-4,-5,-2,-8,-5,-1,-1,-4,-3,0,-6,-3,-4,-5,0,-4,
-9,-9,-8,-3,-8,-5,-4,-5,0,-8,-4,-3,-9,-3,-9,-2,-1,-2,0,-9,-3,-2,0,-3,-9,-3,0,0,0,-6,-5,-8,-5,-5,
-6,-5,0,-6},
  -1,
  70,
  10,
  1
}

constant big2 =
{
  {-9,-9,-9,-9,-9,-8,-7,-3,-1,-7,-2,-7,-5,-3,-9,-5,-4,-5,-2,-8,-5,-1,-1,-4,-3,0,-6,-3,-4,-5,0,-4,
-9,-9,-8,-3,-8,-5,-4,-5,0,-8,-4,-3,-9,-3,-9,-2,-1,-2,0,-9,-3,-2,0,-3,-9,-3,0,0,0,-6,-5,-8,-5,-5,
-6,-5,0,-6,-4,-7,-2,0,-1,0,-4,-4,0,-5,-3,-5,-3,-1,-3,-4,0,-9,-1,-6,-8,-1,0,-5,-5,-9,-5,-6,-8,-6},
  -1,
  100,
  10,
  -1
}

b = EunCos(a)
? b

? EunTest(big2, b)



abort(0)

object exp0

SetRand(1, 1)

a = ToEun("1")
a[3] = 4
b = 3

? EunInaccurateSigDigits(a, b, ROUND_POS_INF)

abort(0)


atom t0, t

trace(1)


a = ToEun("1.85")

a[3] = 99
calculationSpeed = 99

b = EunMultiplicativeInverse(a)

-- SetRand(1, 1)
b[1] = InaccurateFill(b[1], 11, b[3], b[4])

? b

ROUND = ROUND_ZERO

? EunMultiplicativeInverse(a)

abort(0)

-- Test ArcTanExpA(sequence n1, integer exp1, TargetLength targetLength, AtomRadix radix)

a = ToEun(1)
b = ToEun(4)

t0 = time()
c = ArcTanExpA(a[1], a[2], a[3], a[4])
t = time() - t0
printf(1, "%g seconds:\n", t)

d = EunMultiply(b, c)

? d

if 0 then
t0 = time()
c = ArcTanExpB(a[1], a[2], a[3], a[4])
t = time() - t0
printf(1, "%g seconds:\n", t)

d = EunMultiply(b, c)

? d
end if

Complex x, y, z

z = NewComplex(ToEun(1), ToEun(1))

t0 = time()
x = ComplexArcTanA(z)
t = time() - t0
printf(1, "ComplexArcTanA() took %g seconds:\n", t)

? x

t0 = time()
y = ComplexArcTan(z)
t = time() - t0
printf(1, "ComplexArcTan() took %g seconds:\n", t)

? y

--abort(0)


a = ToEun("5e-1")

b = EunRoundToInt(a)

? a
? b

--abort(0)

a = ToEun(10)
b = ToEun(100)

c = EunPower(a, b) --, 2) -- the "2" is to make it more accurate.

puts(1, ToString(c, TRUE) & "\n")

d = EunGeneralRoot(c, a) --, 2) -- the "2" is to make it more accurate.

puts(1, ToString(d, TRUE) & "\n")

--abort(0)

object
    n1 = {
       {-7},
       2,
       70,
       10,
       0
     }


trace(1)

useLongDivision = FALSE

? EunMultiplicativeInverse(n1)
? lastIterCount

useLongDivision = TRUE

? EunMultiplicativeInverse(n1)
? lastIterCount

? LongDivision(1, 1, -7, 3, 70, 10)


