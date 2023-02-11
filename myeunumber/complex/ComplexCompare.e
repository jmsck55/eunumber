-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/eun/EunCompare.e
include Complex.e


global function ComplexCompare(Complex c1, Complex c2)
    integer ret
    ret = EunCompare(c1[REAL], c2[REAL])
    if ret then
        return ret
    end if
    ret = EunCompare(c1[IMAG], c2[IMAG])
    return ret
end function
