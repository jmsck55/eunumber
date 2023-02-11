-- Copyright (c) 2016-2023 James Cook

include ../minieun/MultiplicativeInverse.e
include ../minieun/Eun.e

-- EunMultiplicativeInverse
global function EunMultiplicativeInverse(Eun n1, sequence guess = {})
    return MultiplicativeInverseExp(n1[1], n1[2], n1[3], n1[4], guess)
end function
