-- Copyright (c) 2016-2023 James Cook
-- ToAtom() function of EuNumber.
-- include eunumber/ToAtom.e

namespace toatom

--ifdef SMALL_CODE then
-- Use old value() function to avoid Intel bug:
    include get.e
--elsedef
--    include std/get.e
--end ifdef

include Eun.e
include ToString.e

-- converts to a floating point number
-- takes a string or a "Eun"
global function ToAtom(sequence s)
    if Eun(s) then
        s = ToString(s)
    end if
    s = value(s)
    if s[1] = GET_SUCCESS and atom(s[2]) then
        return s[2]
    end if
    return {} -- return empty sequence on error.
end function
