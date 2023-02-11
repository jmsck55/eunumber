-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/Eun.e

include EunArcTanA.e
--include EunArcTanB.e


global function ArcTanExp(sequence n1, integer exp1, integer targetLength, atom radix)
-- Use the faster, newer method: ArcTanExpA()
    return ArcTanExpA(n1, exp1, targetLength, radix)
end function

global function EunArcTan(Eun a)
    return ArcTanExp(a[1], a[2], a[3], a[4])
end function
