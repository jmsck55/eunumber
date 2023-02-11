-- Copyright (c) 2016-2023 James Cook
-- sprint function for EuNumber.
-- include eunumber/trigform.e

namespace sprint

-- misc functions:

global function sprint(object x)
-- Return the string representation of any Euphoria data object.
-- This is the same as the output from print(1, x) or '?', but it's
-- returned as a string sequence rather than printed.
    sequence s

    if atom(x) then
        return sprintf("%.10g", x)
    else
        s = "{"
        for i = 1 to length(x) do
            s &= sprint(x[i])
            if i < length(x) then
                s &= ','
            end if
        end for
        s &= "}"
        return s
    end if
end function
