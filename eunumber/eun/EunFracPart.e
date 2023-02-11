-- Copyright (c) 2016-2023 James Cook


include ../minieun/Eun.e
include ../minieun/Defaults.e
include ../minieun/WholeFracParts.e
include ../minieun/AdjustRound.e


-- EunFracPart
global function EunFracPart(Eun n1, integer intModeFloat = integerModeFloat)
    sequence s
    s = WholeFracParts(n1[1], n1[2], WF_FRAC_PART, intModeFloat)
    s = s[WF_FRAC_PART]
    s = AdjustRound(s[1], s[2], n1[3], n1[4], NO_SUBTRACT_ADJUST)
    return s
end function

-- global function EunFracPart(Eun n1, integer intModeFloat = integerModeFloat)
--     integer len
--     if n1[2] >= 0 then
--         len = n1[2] + 1
-- if ROUND_TO_NEAREST_OPTION then
--         len += intModeFloat
-- end if
--         if len >= length(n1[1]) then
--             n1[1] = {}
--             n1[2] = 0
--         else
--             n1[1] = n1[1][len + 1..$]
--             n1[2] = -1
-- if ROUND_TO_NEAREST_OPTION then
--             n1[2] -= (intModeFloat)
-- end if
--             n1 = EunAdjustRound(n1)
--         end if
--     end if
--     return n1
-- end function
