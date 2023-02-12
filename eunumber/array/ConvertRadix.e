-- Copyright (c) 2016-2023 James Cook


ifdef WITHOUT_TRACE then
without trace
end ifdef

include ../minieun/NanoSleep.e
include ../minieun/Common.e
include Carry.e
include Add.e

global function MultiplyByDigit(sequence n1, atom digit)
ifdef OLD_PROCESSOR_MODE then
        return n1 * digit
elsedef
        for j = 1 to length(n1) do
            n1[j] *= digit
    ifdef not NO_SLEEP_OPTION then
            sleep(nanoSleep)
    end ifdef
        end for
        return n1
end ifdef
end function

global function ConvertRadix(sequence number, AtomRadix fromRadix, AtomRadix toRadix)
    sequence target, base --, tmp
    -- atom digit
    integer isNeg
    target = {} -- same as: {0}
    if length(number) then
        base = {1}
        isNeg = number[1] < 0
        for i = length(number) to 1 by -1 do
            target = Add(target, MultiplyByDigit(base, number[i]))
--                      tmp = base
--                      digit = number[i]
--                      for j = 1 to length(tmp) do
--                              tmp[j] *= digit
-- ifdef not NO_SLEEP_OPTION then
--                              sleep(nanoSleep)
-- end ifdef
--                      end for
--                      target = Add(target, tmp)
            if isNeg then
                target = NegativeCarry(target, toRadix)
            else
                target = Carry(target, toRadix)
            end if
            base = Carry(MultiplyByDigit(base, fromRadix), toRadix)
--                      for j = 1 to length(base) do
--                              base[j] *= fromRadix
-- ifdef not NO_SLEEP_OPTION then
--                              sleep(nanoSleep)
-- end ifdef
--                      end for
--                      base = Carry(base, toRadix)
ifdef not NO_SLEEP_OPTION then
            sleep(nanoSleep)
end ifdef
        end for
    end if
    return target
end function
