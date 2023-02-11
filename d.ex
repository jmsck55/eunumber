
--with trace

include eunumber/my.e

object a, b, c, d

a = ToEun("-0.55555")

trace(1)

b = AdjustRound(a[1], a[2], 0, a[4], NO_SUBTRACT_ADJUST)
? b
b = AdjustRound(a[1], a[2], 1, a[4], NO_SUBTRACT_ADJUST)
? b
b = AdjustRound(a[1], a[2], 2, a[4], NO_SUBTRACT_ADJUST)
? b
c = AdjustRound(a[1], a[2], 3, a[4], NO_SUBTRACT_ADJUST)
? c
b = AdjustRound(a[1], a[2], 4, a[4], NO_SUBTRACT_ADJUST)
? b
b = AdjustRound(a[1], a[2], 5, a[4], NO_SUBTRACT_ADJUST)
? b

d = AddExp(c[1], c[2], c[5][1], c[5][2], 4, defaultRadix)
? d
d = AddExp(c[1], c[2], c[5][1], c[5][2], 5, defaultRadix)
? d
d = AddExp(c[1], c[2], c[5][1], c[5][2], 10, defaultRadix)
? d
