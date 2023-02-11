
with define USE_TASK_YIELD
with define DEBUG_TASK

include eunumber/my.e

with trace

trace(1)

object a, b, c, d

a = ToEun("230")

b = EunExp1(a)

? b

c = EunLog(b)

? c

c = EunRoundSignificantDigits(c, 60)

? c
? a

? EunCompare(a, c)
