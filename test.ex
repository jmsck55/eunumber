
with trace

include my.e

object a, b, c, d
integer tmpAdjustRound

trace(1)

a = ToEun(2)
b = EunSqrt(a)
b = b[2]
c = EunMultiply(b,b)
? c
tmpAdjustRound = adjustRound
adjustRound = 0
c = EunRoundToInt(c)
adjustRound = tmpAdjustRound
? c

? EunCompare(c, a)
? GetEqualLength()

? EunCompare(b, b)
? GetEqualLength()

? EunCompare(RemoveLastDigits(b), b)
? GetEqualLength()

--End-of-file.
