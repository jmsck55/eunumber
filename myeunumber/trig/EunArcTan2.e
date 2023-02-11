-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/Eun.e
include ../../eunumber/minieun/comparefuncs.e
include ../../eunumber/eun/EunAdd.e
include ../../eunumber/eun/EunNegate.e
include ../../eunumber/eun/EunDivide.e

include EunArcTan.e
include GetPI.e


global function EunArcTan2(Eun y, Eun x)
-- ArcTan2(y, x) = ArcTan(y/x)
--
-- The comments below use UTF-8
--
-- atan2(y,x) = arctan(y/x) if x > 0,
-- atan2(y,x) = arctan(y/x) + π if x < 0 and y≥0,
-- atan2(y,x) = arctan(y/x) - π if x < 0 and y < 0,
-- atan2(y,x) = +π / 2 if x=0 and y > 0,
-- atan2(y,x) = - π / 2 if x=0 and y < 0,
-- atan2(y,x) = undefined if x=0 and y=0
--
-- Table:
--      x     arctan(x) (°)  arctan(x) (rad.)
--      -∞    -90°   -π/2
--      -√3   -60°   -π/3
--      -1    -45°   -π/4
--      -1/√3 -30°   -π/6
--      0       0°     0
--      1/√3  30°    π/6
--      1     45°    π/4
--      √3    60°    π/3
--      +∞    90°    π/2
--
    integer xcmp, ycmp
    sequence tmp
    xcmp = CompareExp(x[1], x[2], {}, 0)
    ycmp = CompareExp(y[1], y[2], {}, 0)
    if xcmp = 0 then -- x = 0
        if ycmp = 0 then -- y = 0
            puts(2, "Error, EunArcTan2(0, 0) -- undefined.\n")
            abort(1/0)
        end if
        tmp = GetHalfPI(y[3], y[4])
        if ycmp = 1 then -- y > 0
            return tmp
        elsif ycmp = -1 then -- y < 0
            return EunNegate(tmp)
        end if
    end if
    tmp = EunArcTan(EunDivide(y, x))
    if xcmp = 1 then -- x > 0
        return tmp
    end if
    if ycmp = -1 then -- y < 0
        return EunSubtract(tmp, GetPI(x[3], x[4]))
    end if
    return EunAdd(tmp, GetPI(x[3], x[4]))
end function
