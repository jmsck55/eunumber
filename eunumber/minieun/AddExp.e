-- Copyright (c) 2016-2023 James Cook
-- AddExp and SubtractExp functions of EuNumber.
-- include eunumber/AddExp.e

namespace addexp

include ../array/Add.e
include UserMisc.e
include AdjustRound.e

global function AddExp(sequence n1, integer exp1, sequence n2, integer exp2, TargetLength targetLength, AtomRadix radix)
    sequence ret, numArray
    integer size, flag, exponent
    if length(n1) then
        if length(n2) then
            flag = (n1[1] >= 0) xor (n2[1] >= 0)
            exponent = max(exp1, exp2)
            size = (length(n1) - (exp1)) - (length(n2) - (exp2))
            if size < 0 then
                n1 = n1 & repeat(0, - (size))
            elsif size > 0 then
                n2 = n2 & repeat(0, size)
            end if
            numArray = Add(n1, n2)
        else
            flag = NO_SUBTRACT_ADJUST
            numArray = n1
            exponent = exp1
        end if
    else
        if length(n2) then
            flag = NO_SUBTRACT_ADJUST
            numArray = n2
            exponent = exp2
        else
            return {{}, max(exp1, exp2), targetLength, radix}
        end if
    end if
    ret = AdjustRound(numArray, exponent, targetLength, radix, flag)
    return ret
end function

ifdef USE_OLD_SUBTR then

include array/negate.e

global function SubtractExp(sequence n1, integer exp1, sequence n2, integer exp2, TargetLength targetLength, AtomRadix radix)
    return AddExp(n1, exp1, Negate(n2), exp2, targetLength, radix)
end function

elsedef

------------------------------
-- New SubtractExp() function:
------------------------------

global function SubtractExp(sequence n1, integer exp1, sequence n2, integer exp2, TargetLength targetLength, AtomRadix radix)
    sequence ret, numArray
    integer size, flag, exponent
    if length(n2) then
        if length(n1) then
            flag = (n1[1] >= 0) xor (n2[1] < 0)
            exponent = max(exp1, exp2)
        else
            flag = NO_SUBTRACT_ADJUST
            exponent = exp2
        end if
        size = (length(n1) - (exp1)) - (length(n2) - (exp2))
        if size < 0 then
            n1 = n1 & repeat(0, - (size))
        elsif size > 0 then
            n2 = n2 & repeat(0, size)
        end if
        numArray = Subtr(n1, n2)
    else
        flag = NO_SUBTRACT_ADJUST
        numArray = n1
        exponent = exp1
    end if
    ret = AdjustRound(numArray, exponent, targetLength, radix, flag)
    return ret
end function

end ifdef
