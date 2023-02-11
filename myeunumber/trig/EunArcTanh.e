-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/Eun.e
include ../../eunumber/minieun/comparefuncs.e
include ../../eunumber/array/negate.e
include ../../eunumber/eun/EunAdd.e
include ../../eunumber/eun/EunDivide.e

include ../myeun/EunLog.e


global function EunArcTanh(Eun a)
-- arctanh(x) = abs(x) < 1; ln((1 + x)/(1 - x)) / 2
    sequence tmp, local
    if CompareExp(AbsoluteValue(a[1]), a[2], {1}, 0) >= 0 then
        puts(1, "Error(7):  In MyEuNumber, EunArcTanh(): supplied number is out of domain/range\n  See file: ex.err\n")
        abort(1/0)
    end if
    local = NewEun({1}, 0, a[3], a[4])
    tmp = EunDivide(EunAdd(local, a), EunSubtract(local, a))
    local[1] = {2}
    return EunDivide(EunLog(tmp), local)
end function
