-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/Eun.e
include ../../eunumber/minieun/comparefuncs.e
include ../../eunumber/eun/EunAdd.e
include ../../eunumber/eun/EunMultiply.e
include ../../eunumber/eun/EunMultiplicativeInverse.e

include ../myeun/EunSquareRoot.e
include ../myeun/EunLog.e


global function EunArcSech(Eun a)
-- arcsech(x) = 0 < x <= 1; 1 / x => a; ln(a + sqrt(a^2 - 1)) :: ln((1 + sqrt(1 - x^2)) / x)
    sequence tmp, s
    if CompareExp(a[1], a[2], {}, 0) <= 0 or CompareExp(a[1], a[2], {1}, 0) = 1 then
        puts(1, "Error(7):  In MyEuNumber, EunArcSech(): supplied number is out of domain/range\n  See file: ex.err\n")
        abort(1/0)
    end if
    tmp = EunMultiplicativeInverse(a)
    s = EunSquareRoot(EunSubtract(EunMultiply(tmp, tmp), NewEun({1}, 0, a[3], a[4])))
    return EunLog(EunAdd(tmp, s[2]))
end function
