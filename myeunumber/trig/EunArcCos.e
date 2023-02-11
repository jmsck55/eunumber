-- Copyright (c) 2016-2023 James Cook


include ../../eunumber/minieun/Eun.e
include ../../eunumber/minieun/AddExp.e
include ../../eunumber/minieun/Multiply.e
include ../../eunumber/eun/EunDivide.e

include ../myeun/EunSquareRoot.e

include EunArcTan.e
include GetPI.e


-- arcsin(x) = arctan( x / sqrt(1 - x^2) )
-- arccos(x) = arctan( sqrt(1 - x^2) / x )

global function EunArcCos(Eun a)
-- arccos(x) = arctan( sqrt(1 - x^2) / x )
-- Limited domain: -1 to 1
-- Also:
--   arccos(x) = arcsin(1) - arcsin(x)
--   arccos(x) = (EunPi / 2) - arcsin(x)
    object ob1
    if not length(a[1]) then
        return GetHalfPI(a[3], a[4])
    end if
    ob1 = SquaredExp(a[1], a[2], a[3], a[4])
    ob1 = SubtractExp({1}, 0, ob1[1], ob1[2], a[3], a[4])
    ob1 = EunSquareRoot(ob1)
    if ob1[1] then
        puts(2, "Error: -- Trig error.\n")
        abort(1/0)
    end if
    ob1 = EunDivide(ob1[2], a)
    ob1 = EunArcTan(ob1)
    return ob1
    --return EunSubtract(GetHalfPI(a[3], a[4]), EunArcSin(a))
end function
