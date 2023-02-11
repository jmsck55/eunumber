-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/eun/EunAdd.e

include Complex.e


global function ComplexAdd(Complex a, Complex b)
    return {EunAdd(a[1], b[1]), EunAdd(a[2], b[2])}
end function
