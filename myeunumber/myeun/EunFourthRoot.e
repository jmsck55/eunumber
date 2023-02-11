-- Copyright (c) 2016-2023 James Cook

include ../../eunumber/minieun/Eun.e
include EunNthRoot.e

global function EunFourthRoot(Eun n1, object guess = 0)
    return EunNthRoot(4, n1, guess)
end function
