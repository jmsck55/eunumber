-- Copyright (c) 2016-2023 James Cook


ifdef WITHOUT_TRACE then
without trace
end ifdef

include ../minieun/NanoSleep.e

global function Negate(sequence numArray)
ifdef OLD_PROCESSOR_MODE then
        return - numArray
elsedef
        for i = 1 to length(numArray) do
            numArray[i] = - (numArray[i])
    ifdef not NO_SLEEP_OPTION then
            sleep(nanoSleep)
    end ifdef
        end for
        return numArray
end ifdef
end function

global function AbsoluteValue(sequence numArray)
    if length(numArray) then
        if numArray[1] < 0 then
            numArray = Negate(numArray)
        end if
    end if
    return numArray
end function
