-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/eun/EunAdd.e

include Complex.e


global function ComplexSubtract(Complex a, Complex b)
    return {EunSubtract(a[1], b[1]), EunSubtract(a[2], b[2])}
end function
