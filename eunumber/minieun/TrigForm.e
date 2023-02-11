-- Copyright (c) 2016-2023 James Cook
-- trig formulas for EuNumber.
-- include eunumber/trigform.e

namespace trigform

-- trig formulas provided by Larry Gregg

global constant PI = 3.141592653589793238

constant PI_HALF =  PI / 2.0  -- this is pi/2

type trig_range(object x)
--  values passed to arccos and arcsin must be [-1,+1]
    if atom(x) then
        return x >= -1 and x <= 1
    else
        for i = 1 to length(x) do
            if not trig_range(x[i]) then
                return 0
            end if
        end for
        return 1
    end if
end type

global function arccos(trig_range x)
--  returns angle in radians
    return PI_HALF - 2 * arctan(x / (1.0 + sqrt(1.0 - x * x)))
end function

global function arcsin(trig_range x)
--  returns angle in radians
    return 2 * arctan(x / (1.0 + sqrt(1.0 - x * x)))
end function
