-- Copyright (c) 2016-2023 James Cook


ifdef WITHOUT_TRACE then
without trace
end ifdef

include ../minieun/NanoSleep.e
include ../minieun/Common.e
include ../minieun/MathConst.e

ifdef USE_OLD_CARRY then

global function Carry(sequence numArray, AtomRadix radix)
    ifdef USE_ATOM_RADIX then
        atom emax = DOUBLE_INT_MAX
    elsedef
        atom emax = INT_MAX
    end ifdef
    atom q, r, b
    integer i
    i = length(numArray)
    while i > 0 do
        b = numArray[i]
        if b >= radix then
            -- round function? for atoms --here
            q = floor(b / radix)
            r = remainder(b, radix)
            numArray[i] = r
            if i = 1 then
                numArray = prepend(numArray, q)
            else
                i -= 1
                -- q += numArray[i] -- test for integer overflow
                numArray[i] += q
                if numArray[i] > emax then -- test for atom overflow
                    puts(1, "Error, overflow in Carry() function.\n")
                    abort(1/0)
                end if
            end if
        else
            i -= 1
        end if
ifdef not NO_SLEEP_OPTION then
        sleep(nanoSleep)
end ifdef
    end while
    return numArray
end function

global function NegativeCarry(sequence numArray, AtomRadix radix)
    ifdef USE_ATOM_RADIX then
        atom emin = DOUBLE_INT_MIN
    elsedef
        atom emin = INT_MIN
    end ifdef
    atom q, r, b, negativeRadix
    integer i
    negativeRadix = -radix
    i = length(numArray)
    while i > 0 do
        b = numArray[i]
        if b <= negativeRadix then
            q = -(floor(b / negativeRadix)) -- bug fix
            r = remainder(b, radix)
            numArray[i] = r
            if i = 1 then
                numArray = prepend(numArray, q)
            else
                i -= 1
                -- q += numArray[i] -- test for integer overflow
                numArray[i] += q
                if numArray[i] < emin then -- test for atom overflow
                    puts(1, "Error, overflow in NegativeCarry() function.\n")
                    abort(1/0)
                end if
            end if
        else
            i -= 1
        end if
ifdef not NO_SLEEP_OPTION then
        sleep(nanoSleep)
end ifdef
    end while
    return numArray
end function

elsedef

------------------------
-- New Carry() function:
------------------------

global function Carry(sequence numArray, AtomRadix radix)
    integer i, sign
    ifdef USE_ATOM_RADIX then
        atom q, r, b, emax = DOUBLE_INT_MAX, emin = DOUBLE_INT_MIN
    elsedef
        integer q, r, b, emax = INT_MAX, emin = INT_MIN
    end ifdef
    i = length(numArray)
    if i then
        sign = numArray[1] < 0
    end if
    while 1 do
        while 1 do
            if i < 1 then
                return numArray
            end if
            b = numArray[i]
            if sign then
                b = -(b)
            end if
            if b >= radix then
                exit
            end if
            i -= 1
            ifdef not NO_SLEEP_OPTION then
                sleep(nanoSleep)
            end ifdef
        end while
        -- b >= radix
        -- round function? for atoms --here
        q = floor(b / radix)
        r = remainder(b, radix)
        if sign then
            q = -(q)
            r = -(r)
        end if
        numArray[i] = r
        if i = 1 then
            ifdef SMALL_CODE then
                numArray = q & numArray
            elsedef
                numArray = prepend(numArray, q)
            end ifdef
        else
            i -= 1
            q += numArray[i] -- test for integer overflow
            if q > emax or q < emin then -- test for atom overflow
                puts(1, "Error, overflow in Carry() function.\n")
                abort(1/0)
            end if
            numArray[i] = q
        end if
        ifdef not NO_SLEEP_OPTION then
            sleep(nanoSleep)
        end ifdef
    end while
    -- return numArray
end function

global function NegativeCarry(sequence numArray, atom radix)
    return Carry(numArray, radix)
end function

end ifdef

--global function NegativeCarry(sequence numArray, AtomRadix radix)
--    atom q, r, b, negativeRadix
--    integer i
--    negativeRadix = -radix
--    i = length(numArray)
--    while 1 do
--        while 1 do
--            if i < 1 then
--                return numArray
--            end if
--            b = numArray[i]
--            if b <= negativeRadix then
--                exit
--            end if
--            i -= 1
--            ifdef not NO_SLEEP_OPTION then
--                sleep(nanoSleep)
--            end ifdef
--        end while
--        -- b <= negativeRadix
--        -- round function? for atoms --here
--        q = -(floor(b / negativeRadix)) -- bug fix
--        r = remainder(b, radix)
--        numArray[i] = r
--        if i = 1 then
--            ifdef SMALL_CODE then
--                numArray = q & numArray
--            elsedef
--                numArray = prepend(numArray, q)
--            end ifdef
--            continue
--        end if
--        i -= 1
--        numArray[i] += q
--        if numArray[i] <= ATOM_INT_MIN then -- test for atom overflow
--            puts(1, "Error, overflow in NegativeCarry() function.\n")
--            abort(1/0)
--        end if
--        ifdef not NO_SLEEP_OPTION then
--            sleep(nanoSleep)
--        end ifdef
--    end while
--    return numArray
--end function
