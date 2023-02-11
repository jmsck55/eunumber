-- Copyright (c) 2016-2023 James Cook

-- Test: euroots_test.ex

include ../eunumber/my.e

--with trace

trace(1)

--here.
--FOR BUG FIX: Could be "delta", or could be something else, like "eurootsAdjustRound"
-- Could be Sin() or Cos().

puts(1, "Calculating, please wait.\n")

isRoundToZero = TRUE

defaultTargetLength = 30
calculationSpeed = defaultTargetLength
defaultRadix = 10
-- adjustRound = 0

function Func1Exp(sequence n1, integer exp1, integer targetLength, integer radix, object pass1)
    object x = {n1, exp1, targetLength, radix}
    return EunCos(x)
end function
-- ? Func1Exp({1},-1,100,10)
integer myfunc1 = routine_id("Func1Exp")
sequence ja, jb
ja = {{1},0}
jb = {{2},0}
? FindRootExp(myfunc1, ja[1], ja[2], jb[1], jb[2], defaultTargetLength, defaultRadix)
? GetLastDelta()
puts(1,"Should be: ")
puts(1, "\n")
? GetHalfPI()
? {"15707963267948966192313216916398" - '0', 0}

function Func2Exp(sequence n1, integer exp1, integer targetLength, integer radix, object pass1)
    object x = {n1, exp1, targetLength, radix}
    return EunSin(x)
end function
integer myfunc2 = routine_id("Func2Exp")
--sequence ja, jb
--ja = {{3,1,4},0}
--jb = {{3,1,5},0}
ja = {{2},0,defaultTargetLength,defaultRadix}
jb = {{4},0,defaultTargetLength,defaultRadix}
puts(1, "Calculating...This could take a few minutes...")
puts(1, "\n")
? FindRootExp(myfunc2, ja[1], ja[2], jb[1], jb[2], defaultTargetLength, defaultRadix)
? GetLastDelta()
puts(1,"Should be:\n")

object pi, a
pi = GetPI()
? pi

? EunSin(ja)
? EunSin(jb)

a = EunSin(pi)
? a
? EunAdjustRound(a, 4) -- round by 4, to get rid of infinitesimal

--? EunArcSin(pi)

-- end of file.
