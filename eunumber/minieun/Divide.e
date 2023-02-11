-- Copyright (c) 2016-2023 James Cook
-- Divide function of EuNumber.
-- include eunumber/Divide.e

namespace divide

include Common.e
include MultiplicativeInverse.e
include Multiply.e

-- Divide:

global Bool zeroDividedByZero = TRUE -- if true, zero divided by zero returns one (0/0 = 1)

global function GetZeroDividedByZero()
    return zeroDividedByZero
end function

global procedure SetZeroDividedByZero(Bool i)
    zeroDividedByZero = i
end procedure

global function DivideExp(sequence num1, integer exp1, sequence den2, integer exp2, TargetLength targetLength, AtomRadix radix)
    sequence tmp
    if zeroDividedByZero and length(num1) = 0 and length(den2) = 0 then
        return {{1}, 0, targetLength, radix}
    end if
    tmp = MultiplicativeInverseExp(den2, exp2, targetLength, radix)
    if length(tmp) then
        tmp = MultiplyExp(num1, exp1, tmp[1], tmp[2], targetLength, radix)
        return tmp
    else
        return {}
    end if
end function

