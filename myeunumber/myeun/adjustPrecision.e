-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/common.e


global PositiveInteger adjustPrecision = 4 -- should be a positive integer

global function GetAdjustPrecision()
    return adjustPrecision
end function

global procedure SetAdjustPrecision(PositiveInteger i)
    adjustPrecision = i
end procedure
