-- Copyright (c) 2016-2023 James Cook
-- "Return to user" callback functions of EuNumber.
-- include eunumber/returntouser.e

-- NOTE: It has to round, or not.

namespace returntouser

--include Allocate.e
include AdjustRound.e
include CompareFuncs.e

global integer abort_calculating = 0
public integer calculating = 0 -- FALSE

global procedure SetCalculatingStatus(integer falseToStopTrueToContinue)
    calculating = falseToStopTrueToContinue
end procedure

global function GetCalculatingStatus()
    return calculating
end function

global function GetHowCompleteMin(sequence howComplete)
    return howComplete[1]
end function

global function GetHowCompleteMax(sequence howComplete)
    return howComplete[2]
end function

global function GetHowCompleteCompare(sequence howComplete)
    return howComplete[3]
end function

global function HowComplete(sequence n1, integer exp1, sequence n2, integer exp2, integer start = 1, integer stop = -1)
    integer c, clength, cminlength
    c = CompareExp(n1, exp1, n2, exp2, stop, start) -- use default value for 5th (fith) argument.
    --if c = 0 and start > 1 then
    --    c = CompareExp(n1, exp1, n2, exp2)
    --end if
    clength = GetEqualLength()
    cminlength = GetCompareMin()
    return {clength + 1, cminlength, c}
end function

global function DefaultRTU(integer eunFunc, sequence p, integer targetLength, sequence ret, sequence lookat, atom radix)
    integer isDone
    if not abort_calculating and length(p) then
        if atom(p[1]) then -- Eun number:
            isDone = 0 -- not done, continue loop
            ret = AdjustRound(ret[1], ret[2], targetLength + 1, radix, NO_SUBTRACT_ADJUST)
            if length(lookat) >= 2 then
                integer start = p[1]
                p = HowComplete(ret[1], ret[2], lookat[1], lookat[2], start) --, targetLength + 1)
                if p[3] = 0 then
                    p = HowComplete(ret[1], ret[2], lookat[1], lookat[2], 1, start - 1)
                    if p[3] = 0 then --or p[1] > targetLength + 1 then -- p[1] = p[2] then
                        isDone = 1 -- return answer "ret"
                    end if
                end if
            end if
        else -- Complex or multivariable number, such as: ComplexArcTanA()
            sequence s
            isDone = 1 -- uses boolean, conditional "and" below.
            s = repeat(0, length(p))
            for i = 1 to length(p) do
                s[i] = DefaultRTU(eunFunc, p[i], targetLength, ret[i], lookat[i], radix)
                isDone = isDone and s[i][1] -- boolean, conditional "and" operation.
                ret[i] = s[i][2]
                p[i] = s[i][3]
            end for
        end if
    else
        isDone = 1
    end if
    return {isDone, ret, p}
end function

-- To use default method, just set: SetReturnToUserCallBack(-1)
-- Or, use the variable below:
global integer defaultRTU_id = -1 -- routine_id("DefaultRTU")

integer return_to_user_id = -1

global procedure SetReturnToUserCallBack(integer id)
    return_to_user_id = id
end procedure

global function GetReturnToUserCallBack()
    return return_to_user_id
end function

global function ReturnToUserCallBack(integer eunFunc, sequence a, integer targetLength, sequence ret, sequence lookat, atom radix)
    object x
    ifdef USE_TASK_YIELD then
        if useTaskYield then
            task_yield()
        end if
    end ifdef
    if return_to_user_id > -1 then
        -- call_func(argument length==6) return value is {0, ret, a} to continue loop, {1, ret, a} to return answer.
        x = call_func(return_to_user_id, {eunFunc, a, targetLength, ret, lookat, radix}) -- pass 6 variables to the function
    else
    -- default is_equal() code:
        x = DefaultRTU(eunFunc, a, targetLength, ret, lookat, radix)
    end if
    return x
end function
