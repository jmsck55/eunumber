-- Copyright (c) 2016-2023 James Cook

include ../../eunumber/minieun/Eun.e
include ../../eunumber/minieun/comparefuncs.e
include ../../eunumber/eun/EunAdd.e
include ../../eunumber/eun/EunMultiply.e

include ../myeun/EunSquareRoot.e
include ../myeun/EunLog.e


global function EunArcCosh(Eun a)
-- arccosh(x) = x >= 1; ln(x + sqrt(x^2 - 1))
    sequence tmp
    if CompareExp(a[1], a[2], {1}, 0) = -1 then
        puts(1, "Error(7):  In MyEuNumber, trig functions: Invalid number passed to\n \"EunArcCosh()\", cannot be zero (0).\n  See file: ex.err\n")
        abort(1/0)
    end if
    tmp = EunSquareRoot(EunSubtract(EunMultiply(a, NewEun({2}, 0, a[3], a[4])), NewEun({1}, 0, a[3], a[4])))
    if tmp[1] then
        puts(1, "Error(7):  In MyEuNumber, EunArcCosh(): error, encountered imaginary number,\n something went wrong internally.\n  See file: ex.err\n")
        abort(1/0)
    end if
    return EunLog(EunAdd(a, tmp[2]))
end function
