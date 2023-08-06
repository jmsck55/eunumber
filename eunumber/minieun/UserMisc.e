-- Copyright (c) 2016-2023 James Cook
-- Miscellaneous functions of EuNumber.
-- include eunumber/usermisc.e

namespace usermisc

global function iff(integer condition, object iftrue, object iffalse)
    if condition then
        return iftrue
    else
        return iffalse
    end if
end function

global function min(atom iftrue, atom iffalse)
    if iftrue < iffalse then
        return iftrue
    else
        return iffalse
    end if
end function

global function max(atom iftrue, atom iffalse)
    if iftrue > iffalse then
        return iftrue
    else
        return iffalse
    end if
end function

global function abs(atom a)
    if a >= 0 then
        return a
    else
        return - (a)
    end if
end function

global function Ceil(atom a)
    return -(floor(-(a)))
end function

global function RoundTowardsZero(atom x)
    if x < 0 then
        return Ceil(x)
    else
        return floor(x)
    end if
end function

global function RoundAwayFromZero(atom x)
    if x > 0 then
        return Ceil(x)
    else
        return floor(x)
    end if
end function

global function Round(object a, object precision = 1)
    return floor(0.5 + (a * precision )) / precision
end function
