-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/Eun.e
include ../../eunumber/minieun/comparefuncs.e
include ../../eunumber/eun/EunMultiplicativeInverse.e

include EunSinh.e


global function EunCsch(Eun a)
-- csch(x) = x != 0; 1 / sinh(x)
    if not CompareExp(a[1], a[2], {}, 0) then
        puts(1, "Error(7):  In MyEuNumber, trig functions: Invalid number passed to\n \"EunCsch()\", cannot be zero (0).\n  See file: ex.err\n")
        abort(1/0)
    end if
    return EunMultiplicativeInverse(EunSinh(a))
end function

