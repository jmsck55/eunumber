-- Copyright (c) 2016-2023 James Cook


ifdef WITHOUT_TRACE then
without trace
end ifdef

include ../minieun/Common.e
include Borrow.e
include Carry.e

global function Subtract(sequence numArray, AtomBase base, Bool isMixed = TRUE)
    if length(numArray) then
        if numArray[1] < 0 then
            numArray = NegativeCarry(numArray, base)
            if isMixed then
                numArray = NegativeBorrow(numArray, base)
            end if
        else
            numArray = Carry(numArray, base)
            if isMixed then
                numArray = Borrow(numArray, base)
            end if
        end if
    end if
    return numArray
end function
