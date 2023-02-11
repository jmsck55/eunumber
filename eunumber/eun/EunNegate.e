-- Copyright (c) 2016-2023 James Cook


include ../minieun/Eun.e
include ../array/Negate.e


-- EunNegate
global function EunNegate(Eun n1)
    n1[1] = Negate(n1[1])
    return n1
end function


-- EunAbsoluteValue
global function EunAbsoluteValue(Eun n1)
    n1[1] = AbsoluteValue(n1[1])
    return n1
end function
