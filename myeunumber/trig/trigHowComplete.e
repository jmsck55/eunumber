-- Copyright (c) 2016-2023 James Cook


-- More Trig functions:

-- sine = opp/hyp
-- cos = adj/hyp
-- tan = opp/adj
--
-- csc = hyp/opp
-- sec = hyp/adj
-- cot = adj/opp


-- Hyperbolic functions:

-- See also:
-- https://en.wikipedia.org/wiki/Inverse_hyperbolic_functions


global sequence trigHowComplete = {1, 0} -- for sin() and cos()

global function GetTrigHowCompleteMin()
    return trigHowComplete[1]
end function

global function GetTrigHowCompleteMax()
    return trigHowComplete[2]
end function
