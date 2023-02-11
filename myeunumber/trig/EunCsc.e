-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/Eun.e
include ../../eunumber/eun/EunMultiplicativeInverse.e

include EunSin.e


global function EunCsc(Eun a)
    return EunMultiplicativeInverse(EunSin(a))
end function
