-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/Eun.e
include ../../eunumber/eun/EunMultiplicativeInverse.e

include EunTan.e


global function EunCot(Eun a)
    return EunMultiplicativeInverse(EunTan(a))
end function

