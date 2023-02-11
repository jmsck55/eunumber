-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/Eun.e
include ../../eunumber/eun/EunMultiplicativeInverse.e

include EunArcSin.e


global function EunArcCsc(Eun a)
    return EunArcSin(EunMultiplicativeInverse(a))
end function
