
with trace

include my.e

object a, b, c, d
integer tmpAdjustRound
sequence s

trace(1)

defaultTargetLength = 68

a = ToEun("2")
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

function myfunc(Eun n1)
	sequence s
	s = EunSqrt(n1)
	trace(1)
	return EunLog(s[2])
end function

trace(1)

a[3] += 10
? myfunc(a)
a[3] -= 10

? myfunc(a)
trace(1)
? GetMoreAccurateFunc(routine_id("myfunc"), {a})

--End-of-file.
