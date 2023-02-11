-- Copyright (c) 2016-2023 James Cook

include ../../eunumber/minieun/Eun.e
include ../../eunumber/minieun/ToAtom.e
include ../../eunumber/eun/EunAdd.e
include ../../eunumber/eun/EunDivide.e
include EunLog.e

-- Get precision:

global function GetPrecision(Eun n1)
    -- precision2 = ToAtom( Divide( Log( Add(n1, 1) ), Log(base) ) )
    atom prec
    object tmp, logbase
    tmp = EunAdd(n1, NewEun({1}, 0, n1[3], n1[4]))
    tmp = EunLog(tmp)
    logbase = EunLog(NewEun({2}, 0, n1[3], n1[4]))
    tmp = EunDivide(tmp, logbase)
    prec = ToAtom(tmp)
    return prec -- NOTE: floor() or Ceil() it
end function
