-- Copyright (c) 2016-2023 James Cook


include ../minieun/Eun.e
include ../minieun/Defaults.e
include ../minieun/WholeFracParts.e
include ../minieun/AdjustRound.e


-- EunIntPart
global function EunIntPart(Eun n1, integer intModeFloat = integerModeFloat)
    sequence s
    s = WholeFracParts(n1[1], n1[2], WF_WHOLE_PART, intModeFloat)
    s = s[WF_WHOLE_PART]
    s = AdjustRound(s[1], s[2], n1[3], n1[4], NO_SUBTRACT_ADJUST)
    return s
end function

-- global function EunIntPart(Eun n1, integer intModeFloat = integerModeFloat)
--     integer len
--     len = n1[2] + 1
-- if ROUND_TO_NEAREST_OPTION then
--     len += intModeFloat
-- end if
--     if len < length(n1[1]) then
--         if n1[2] < 0 then
--             n1[1] = {}
--             n1[2] = 0
--         else
--             n1[1] = n1[1][1..len]
--             n1 = EunAdjustRound(n1)
--         end if
--     end if
--     return n1
-- end function
