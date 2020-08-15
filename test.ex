
with trace

include my.e

object a, b, c, d

trace(1)

a = ToEun(2)
b = EunSqrt(a)
b = b[2]
c = EunMultiply(b,b)
? c
adjustRound = 0
c = EunRoundToInt(c)
? c


--End-of-file.
