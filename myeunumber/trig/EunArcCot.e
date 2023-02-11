-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/Eun.e
include ../../eunumber/minieun/comparefuncs.e
include ../../eunumber/eun/EunAdd.e
include ../../eunumber/eun/EunMultiplicativeInverse.e

include EunArcTan.e
include GetPI.e


global function EunArcCot(Eun a)
    integer f
    sequence tmp
    f = CompareExp(a[1], a[2], {}, 0)
    if f = 0 then
        return GetHalfPI(a[3], a[4])
    end if
    tmp = EunArcTan(EunMultiplicativeInverse(a))
    if f < 0 then
        tmp = EunAdd(tmp, GetPI(a[3], a[4]))
    end if
    return tmp
end function
