-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/Eun.e
include ../../eunumber/eun/EunAdd.e
include ../../eunumber/eun/EunMultiply.e

include ../myeun/EunSquareRoot.e
include ../myeun/EunLog.e


global function EunArcSinh(Eun a)
-- arcsinh(x) = ln(x + sqrt(x^2 + 1))
    sequence tmp
    tmp = EunSquareRoot(EunAdd(EunMultiply(a, NewEun({2}, 0, a[3], a[4])), NewEun({1}, 0, a[3], a[4])))
    if tmp[1] then
        puts(1, "Error(7):  In MyEuNumber, EunArcSinh(): error, encountered imaginary number,\n something went wrong internally.\n  See file: ex.err\n")
        abort(1/0)
    end if
    return EunLog(EunAdd(a, tmp[2]))
end function
