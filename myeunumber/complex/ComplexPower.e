-- Copyright (c) 2016-2023 James Cook


include Complex.e
include ComplexMultiply.e
include ComplexLog.e
include ComplexExp.e


-- Complex Power function:

global function ComplexPower(Complex z, Complex raisedTo)
    return ComplexExp(ComplexMultiply(raisedTo, ComplexLog(z)))
end function
