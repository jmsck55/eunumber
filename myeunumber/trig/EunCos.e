-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/array/negate.e
include ../../eunumber/minieun/AdjustRound.e
include ../../eunumber/minieun/Eun.e
include ../../eunumber/eun/Remainder.e
include ../../eunumber/eun/EunCompare.e
include ../../eunumber/eun/EunAdd.e
include ../../eunumber/eun/EunNegate.e

include ../myeun/adjustPrecision.e

include SinExp.e
include CosExp.e

include GetPI.e


--BEGIN TRIG FUNCTIONS:

-- !!! Remember to use Radians (Rad) on these functions !!!

-- Using Newton's method:
--
-- "sin"
-- sine(x) = x - ((x^3)/(3!)) + ((x^5)/(5!)) - ((x^7)/(7!)) + ((x^9)/(9!)) - ...
--
-- cos(x)  = 1 - ((x^2)/(2!)) + ((x^4)/(4!)) - ((x^6)/(6!)) + ((x^8)/(8!)) - ...
--
-- tan(x) = sine(x) / cos(x)
--
-- csc(x) = 1 / sine(x)
-- sec(x) = 1 / cos(x)
-- cot(x) = cos(x) / sine(x) = 1 / tan(x)
--
-- "atan"
-- arctan(x) = x - ((x^3)/3) + ((x^5)/5) - ((x^7)/7) + ..., where abs(x) < 1
--
--
-- End comments.


-- EunCos:

global constant ID_Cos1 = 12
global constant ID_Cos2 = 13
global constant ID_Cos3 = 14
global constant ID_Cos4 = 15
global constant ID_Cos5 = 16

global function EunCos(Eun x)
-- Use EunCos() in EunSin()
-- Range: -PI/2 to PI/2, exclusive
-- it goes: cos(-2pi),-sin(-3pi/2),-cos(-pi),sin(-pi/2),cos(0),-sin(pi/2),-cos(pi),sin(3pi/2),cos(2pi)
-- 
-- To find cos(x):
-- y = abs(x) mod (2*PI)
-- if y < PI/4 then
--  r = cos(y)
-- elsif y < 3*PI/4 then
--  r = -sin(y -2*PI/4)
-- elsif y < 5*PI/4 then
--  r = -cos(y -4*PI/4)
-- elsif y < 7*PI/4 then
--  r = sin(y -6*PI/4)
-- else
--  r = cos(y -8*PI/4)
-- end if
-- return r
    sequence y --, quarter_pi, half_pi
-- To find cos(x):
    y = x
    y[3] += adjustPrecision
    y[1] = AbsoluteValue(y[1])
    y = EunfMod(y, GetQuarterPI(y[3], y[4], 8)) -- y = abs(x) mod (2*PI)
    if EunCompare(y, GetQuarterPI(y[3], y[4])) < 0 then -- if y < PI/4 then
        --  r = cos(y)
        y = CosExp(y[1], y[2], y[3], y[4], ID_Cos1)
    elsif EunCompare(y, GetQuarterPI(y[3], y[4], 3)) < 0 then -- elsif y < 3*PI/4 then
        --  r = -sin(y -2*PI/4)
        y = EunSubtract(y, GetQuarterPI(y[3], y[4], 2))
        y = SinExp(y[1], y[2], y[3], y[4], ID_Cos2)
        y = EunNegate(y)
    elsif EunCompare(y, GetQuarterPI(y[3], y[4], 5)) < 0 then -- elsif y < 5*PI/4 then
        --  r = -cos(y -4*PI/4)
        y = EunSubtract(y, GetQuarterPI(y[3], y[4], 4))
        y = CosExp(y[1], y[2], y[3], y[4], ID_Cos3)
        y = EunNegate(y)
    elsif EunCompare(y, GetQuarterPI(y[3], y[4], 7)) < 0 then -- elsif y < 7*PI/4 then
        --  r = sin(y -6*PI/4)
        y = EunSubtract(y, GetQuarterPI(y[3], y[4], 6))
        y = SinExp(y[1], y[2], y[3], y[4], ID_Cos4)
    else
        --  r = cos(y -8*PI/4)
        y = EunSubtract(y, GetQuarterPI(y[3], y[4], 8))
        y = CosExp(y[1], y[2], y[3], y[4], ID_Cos5)
    end if
    -- return r
    y[3] -= adjustPrecision
    y = AdjustRound(y[1], y[2], y[3], y[4], NO_SUBTRACT_ADJUST)
    return y
end function
