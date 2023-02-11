-- Copyright (c) 2016-2023 James Cook
-- wholefracparts.e functions of EuNumber.
-- include eunumber/wholefracparts.e

namespace wholefrac

include Common.e
include Defaults.e

global constant WF_WHOLE_PART = 1, WF_FRAC_PART = 2 -- these can be added together to get both whole and frac parts.
global constant WF_FLOOR = 1, WF_CEIL = 2

global function WholeFracParts(sequence n1, integer exp, WhichOnes whichOnes = 3, integer intModeFloat = integerModeFloat, integer isFloor = 0)
    sequence whole, frac
    integer size = exp
    whole = n1
    if whichOnes != WF_WHOLE_PART then
        frac = n1
        if whichOnes = WF_FRAC_PART then
            whole = {}
            exp = 0
        end if
    else
        frac = {}
    end if
    if ROUND_TO_NEAREST_OPTION then
        size += intModeFloat
    end if
    if size >= 0 then -- there is a whole number part.
        size += 1
        if size < length(n1) then
            if whichOnes != WF_FRAC_PART then
                integer isNeg
                if isFloor then
                    isNeg = n1[1] < 0
                end if
                whole = n1[1..size]
                if isFloor then
                    if isNeg then
                        if isFloor != WF_CEIL then
                        --if isFloor = WF_FLOOR then
                            whole[size] -= 1
                        end if
                    else
                        if isFloor != WF_FLOOR then
                        --if isFloor = WF_CEIL then
                            whole[size] += 1
                        end if
                    end if
                end if
            end if
            if whichOnes != WF_WHOLE_PART then
                frac = n1[size + 1..$]
                size = -1
                if ROUND_TO_NEAREST_OPTION then
                    size -= intModeFloat
                end if
            else
                size = 0
            end if
        else
            frac = {}
            size = 0
        end if
    else
        whole = {}
        exp = 0
    end if
    return {{whole, exp}, {frac, size}} -- needs an AdjstRound()
end function
