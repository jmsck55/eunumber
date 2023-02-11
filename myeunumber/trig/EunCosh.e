-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/Eun.e
include ../../eunumber/eun/EunAdd.e
include ../../eunumber/eun/EunNegate.e
include ../../eunumber/eun/EunDivide.e

include ../myeun/EunExp.e


global function EunCosh(Eun a)
-- cosh(x) = (e^(x) + e^(-x)) / 2
    return EunDivide(EunAdd(EunExp(a), EunExp(EunNegate(a))), NewEun({2}, 0, a[3], a[4]))
end function
