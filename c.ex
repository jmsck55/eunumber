

with trace

include eunumber/my.e

Eun x, y

object a, b, c, d, tmp

object num = {
    {4},
    -70,
    70,
    10,
    0
  }

a = EunExpA(num)

? num
? a

abort(0)


y = EunLog(ToEun("1e100"))
? y
y = EunLog(EunMultiplicativeInverse( ToEun("1e100") ))
? y


trace(1)

x = ToEun(-100)

y = EunExpId(eunExp1RID, x)

? x

? y

trace(1)
x = EunLog(y)

? x
