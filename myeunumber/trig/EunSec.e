-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/Eun.e
include ../../eunumber/eun/EunMultiplicativeInverse.e

include EunCos.e


global function EunSec(Eun a)
    return EunMultiplicativeInverse(EunCos(a))
end function
