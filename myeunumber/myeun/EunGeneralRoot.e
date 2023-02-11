-- Copyright (c) 2016-2023 James Cook

include ../../eunumber/minieun/Eun.e
include ../../eunumber/eun/EunMultiplicativeInverse.e
include EunPower.e

global function EunGeneralRoot(Eun rooted, Eun anyNumber) --, integer round = adjustPrecision)
    return EunPower(rooted, EunMultiplicativeInverse(anyNumber)) --, round)
end function
