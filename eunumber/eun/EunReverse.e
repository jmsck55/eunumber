-- Copyright (c) 2016-2023 James Cook

include ../minieun/Eun.e
include ../minieun/Reverse.e

-- EunReverse
global function EunReverse(Eun n1) -- reverse endian
    n1[1] = reverse(n1[1])
    return n1
end function
