-- Copyright (c) 2016-2023 James Cook


ifdef WITHOUT_TRACE then
without trace
end ifdef

include ../minieun/NanoSleep.e

global function Add(sequence n1, sequence n2)
    integer c, len
    sequence numArray, tmp
    if length(n1) >= length(n2) then
        len = length(n2)
        c = length(n1) - (len)
        -- copy n1 to numArray:
        numArray = n1
        tmp = n2
    else
        len = length(n1)
        c = length(n2) - (len)
        -- copy n2 to numArray:
        numArray = n2
        tmp = n1
    end if
    for i = 1 to len do
        c += 1
        numArray[c] += tmp[i]
ifdef not NO_SLEEP_OPTION then
        sleep(nanoSleep)
end ifdef
    end for
    return numArray
end function

global function Sum(sequence dst, sequence srcs)
    for i = 1 to length(srcs) do
        dst = Add(dst, srcs[i])
ifdef not NO_SLEEP_OPTION then
        sleep(nanoSleep)
end ifdef
    end for
    return dst
end function

ifdef USE_OLD_SUBTR then

include Negate.e

global function Subtr(sequence n1, sequence n2)
    return Add(n1, Negate(n2))
end function

elsedef

------------------------
-- New Subtr() function:
------------------------

global function Subtr(sequence n1, sequence n2)
    integer c, len
    len = length(n2)
    if length(n1) < len then
        c = len - length(n1)
        n1 = repeat(0, c) & n1
    end if
    c = length(n1) - (len)
    for i = 1 to len do
        c += 1
        n1[c] -= n2[i]
ifdef not NO_SLEEP_OPTION then
        sleep(nanoSleep)
end ifdef
    end for
    return n1
end function

end ifdef
