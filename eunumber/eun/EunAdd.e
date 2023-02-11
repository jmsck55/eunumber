-- Copyright (c) 2016-2023 James Cook

include ../minieun/Eun.e
include ../minieun/AddExp.e
include ../minieun/Common.e
include ../minieun/UserMisc.e
include ../minieun/NanoSleep.e

-- EunAdd
global function EunAdd(Eun n1, Eun n2)
    TargetLength targetLength
    if n1[4] != n2[4] then
        printf(1, "Error %d\n", 5)
        abort(1/0)
    end if
    targetLength = max(n1[3], n2[3])
    return AddExp(n1[1], n1[2], n2[1], n2[2], targetLength, n1[4])
end function

-- EunSubtract
global function EunSubtract(Eun n1, Eun n2)
    TargetLength targetLength
    if n1[4] != n2[4] then
        printf(1, "Error %d\n", 5)
        abort(1/0)
    end if
    targetLength = max(n1[3], n2[3])
    return SubtractExp(n1[1], n1[2], n2[1], n2[2], targetLength, n1[4])
end function

-- EunSum
global function EunSum(sequence data)
    Eun sum
    sum = NewEun()
    for i = 1 to length(data) do
        sum = EunAdd(sum, data[i])
ifdef not NO_SLEEP_OPTION then
        sleep(nanoSleep)
end ifdef
    end for
    return sum
end function
