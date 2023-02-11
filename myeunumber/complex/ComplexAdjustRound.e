-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/eun/EunAdjustRound.e

include Complex.e


global function ComplexAdjustRound(Complex c1, integer adjustBy = 0)
    sequence ret = repeat(0, length(c1))
    for i = 1 to length(ret) do
        ret[i] = EunAdjustRound(c1[i], adjustBy)
    end for
    return ret
end function
