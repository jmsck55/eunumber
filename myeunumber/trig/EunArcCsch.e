-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/Eun.e
include ../../eunumber/eun/EunAdd.e
include ../../eunumber/eun/EunMultiply.e
include ../../eunumber/eun/EunMultiplicativeInverse.e

include ../myeun/EunSquareRoot.e
include ../myeun/EunLog.e


global function EunArcCsch(Eun a)
-- arccsch(x) = x != 0; 1 / x => a; ln(a + sqrt(a^2 + 1))
    sequence tmp, s
    if not length(a[1]) then
        puts(1, "Error(7):  In MyEuNumber, EunArcCsch(): supplied number is out of domain/range\n  See file: ex.err\n")
        abort(1/0)
    end if
    tmp = EunMultiplicativeInverse(a)
    s = EunSquareRoot(EunAdd(EunMultiply(tmp, tmp), NewEun({1}, 0, a[3], a[4])))
    return EunLog(EunAdd(tmp, s[2]))
end function

