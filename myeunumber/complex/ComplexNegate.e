-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/eun/EunNegate.e

include Complex.e


global function ComplexNegate(Complex b)
    return {EunNegate(b[1]), EunNegate(b[2])}
end function
