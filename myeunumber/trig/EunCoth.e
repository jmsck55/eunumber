-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/Eun.e
include ../../eunumber/minieun/comparefuncs.e
include ../../eunumber/eun/EunMultiplicativeInverse.e

include EunTanh.e


global function EunCoth(Eun a)
-- coth(x) = x != 0; 1 / tanh(x)
    if not CompareExp(a[1], a[2], {}, 0) then
        puts(1, "Error(7):  In MyEuNumber, trig functions: Invalid number passed to\n \"EunCoth()\", cannot be zero (0).\n  See file: ex.err\n")
        abort(1/0)
    end if
    return EunMultiplicativeInverse(EunTanh(a))
end function
