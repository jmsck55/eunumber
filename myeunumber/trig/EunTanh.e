-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/Eun.e
include ../../eunumber/eun/EunAdd.e
include ../../eunumber/eun/EunMultiply.e
include ../../eunumber/eun/EunDivide.e

include ../myeun/EunExp.E


global function EunTanh(Eun a)
-- tanh(x) = e^(2*x) => a; (a - 1) / (a + 1)
    sequence tmp, local
    local = NewEun({2}, 0, a[3], a[4])
    tmp = EunExp(EunMultiply(a, local))
    local[1] = {1}
    return EunDivide(EunSubtract(tmp, local), EunAdd(tmp, local))
end function
