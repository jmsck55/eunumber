-- Copyright (c) 2016-2023 James Cook

include ../minieun/Divide.e
include ../minieun/Common.e
include ../minieun/UserMisc.e
include ../minieun/Eun.e

-- EunDivide
global function EunDivide(Eun n1, Eun n2)
    TargetLength targetLength
    if n1[4] != n2[4] then
        printf(1, "Error %d\n", 5)
        abort(1/0)
    end if
    targetLength = max(n1[3], n2[3])
    return DivideExp(n1[1], n1[2], n2[1], n2[2], targetLength, n1[4])
end function
