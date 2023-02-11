-- Copyright (c) 2016-2023 James Cook
-- nanosleep.e functions for EuNumber.
-- include eunumber/nanosleep.e

-- NanoSleep support for loops:

namespace nanosleep

ifdef WITHOUT_TRACE then
without trace
end ifdef

-- NanoSleep support:

ifdef LINUX then
    global atom nanoSleep = 2/1000000000
elsedef
    global atom nanoSleep = -1 -- Windows doesn't need to use sleep(nanoSleep)
end ifdef

global procedure SetNanoSleep(atom a)
    nanoSleep = a
end procedure

global function GetNanoSleep()
    return nanoSleep
end function

constant
    M_SLEEP = 64

global procedure sleep(atom t)
-- go to sleep for t seconds
-- allowing other processes to run
    if t >= 0 then
        machine_proc(M_SLEEP, t)
    end if
end procedure
