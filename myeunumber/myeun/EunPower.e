-- Copyright (c) 2016-2023 James Cook

include ../../eunumber/minieun/Eun.e
include ../../eunumber/eun/EunMultiply.e
include EunExp.e
include EunLog.e

-- Powers: a number (base), raised to the power of another number (raisedTo)

global function EunPower(Eun base, Eun raisedTo) --, integer round = adjustPrecision)
-- b^x = e^(x * ln(b))
    object tmp = EunExp(EunMultiply(EunLog(base), raisedTo))
    -- if round > 0 then
    --     tmp = EunAdjustRound(tmp, round + 1) -- + adjustRound
    -- end if
    return tmp
end function
