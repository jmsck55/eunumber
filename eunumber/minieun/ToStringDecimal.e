-- Copyright (c) 2016-2023 James Cook
-- ToStringDecimal() function of EuNumber.
-- include eunumber/ToStringDecimal.e

namespace tostringdecimal

include MathConst.e
include ConvertExp.e
include ToEun.e
include UserMisc.e

global function ToStringDecimal(object s)
-- Takes an Eun(), a character string (returned from ToString()), or an atom.
-- Returns the value in Decimal notation.
    sequence ret
    integer exp, rep
    if Eun(s) then
        s = EunConvert(s, 10, Ceil((log(s[4]) / logTen) * s[3]))
    else
        s = ToEun(s) -- requires an Eun
    end if
    if integer(s[1]) then
        if s[1] = -1 then
            return "-inf"
        end if
        if s[1] = 1 then
            return "inf"
        end if
        return -1 -- error
    end if
    exp = s[2]
    s = s[1]
    if length(s) = 0 then
        return "0"
    end if
    if s[1] < 0 then
        s = (- s)
        ret = "-"
    else
        ret = ""
        -- st = "+"
    end if
    s += '0'
    if exp < 0 then
        -- 0.01234
        rep = (- exp)
        ret = ret & "0." & repeat('0', rep - 1) & s
    else
        integer pos
        pos = exp + 1
        if pos >= length(s) then
            -- 123400
            rep = pos - length(s)
            ret = ret & s & repeat('0', rep)
        else
            -- 12.34
            ret = ret & s[1..pos] & "." & s[pos + 1..$]
        end if
    end if
    return ret
end function
