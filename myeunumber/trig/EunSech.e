-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/Eun.e
include ../../eunumber/eun/EunMultiplicativeInverse.e

include EunCosh.e


global function EunSech(Eun a)
-- sech(x) = 1 / cosh(x)
    return EunMultiplicativeInverse(EunCosh(a))
end function
