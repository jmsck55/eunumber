-- Copyright (c) 2016-2023 James Cook


ifdef WITHOUT_TRACE then
without trace
end ifdef

include ../minieun/NanoSleep.e
include ../minieun/Common.e

global function Borrow(sequence numArray, AtomRadix radix)
    for i = length(numArray) to 2 by -1 do
        if numArray[i] < 0 then
            numArray[i] += radix
            numArray[i - 1] -= 1
        end if
ifdef not NO_SLEEP_OPTION then
        sleep(nanoSleep)
end ifdef
    end for
    return numArray
end function

global function NegativeBorrow(sequence numArray, AtomRadix radix)
    for i = length(numArray) to 2 by -1 do
        if numArray[i] > 0 then
            numArray[i] -= radix
            numArray[i - 1] += 1
        end if
ifdef not NO_SLEEP_OPTION then
        sleep(nanoSleep)
end ifdef
    end for
    return numArray
end function
