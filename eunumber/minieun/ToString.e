-- Copyright (c) 2016-2023 James Cook
-- ToString() function of EuNumber.
-- include eunumber/ToString.e

namespace tostring

include NanoSleep.e
include Eun.e
include MathConst.e
include ConvertExp.e
include UserMisc.e

global function ToString(object d, integer padWithZeros = 0)
-- converts an Eun or an atom to a string.
    if integer( d ) then
        -- dont change these:
--ifdef BITS64 then
--        if remainder( d, 1 ) or d >= 1e18 or d <= -1e18 then
--            if padWithZeros then
--                return sprintf( "%+0.17e", d ) -- 1e18, 17 is one less
--            else
--                return sprintf( "%+.17e", d ) -- 1e18, 17 is one less
--            end if
--        else
--            return sprintf( "%+d", d ) -- can only do 18 decimal places for 80-bit, or 15 for 64-bit doubles
--        end if
--elsedef
        --if remainder( d, 1 ) or d >= 1e15 or d <= -1e15 then
        --    if padWithZeros then
        --        return sprintf( "%+0.14e", d ) -- 1e15, 14 is one less
        --    else
        --        return sprintf( "%+.14e", d ) -- 1e15, 14 is one less
        --    end if
        --else
        if padWithZeros then
            return sprintf( "%+d", d ) -- can only do 18 decimal places for 80-bit, or 15 for 64-bit doubles
        else
            return sprintf( "%d", d ) -- can only do 18 decimal places for 80-bit, or 15 for 64-bit doubles
        end if
--end ifdef
    --elsif not Eun(d) then
    --    puts(1, "Error.\n")
    --    abort(1/0)
    --    -- return 1 -- not an Eun.
    elsif atom( d ) then
        puts(1, "Error, use sprintf() instead.\n")
        abort(1/0)
    else
        sequence st
        integer f, len
        if sequence( d[1] ) then
            if d[4] != 10 then
                d = EunConvert( d, 10, Ceil((log(d[4]) / logTen) * d[3]) )
            end if
            st = d[1]
            len = length( st )
            if len = 0 then
                if padWithZeros then
                    return "+0." & repeat('0', d[3] - 1) & "e+0"
                else
                    return "0"
                end if
            end if
            f = (st[1] < 0)
            if f then
                -- st = -st
                for i = 1 to len do
                    st[i] = - (st[i])
ifdef not NO_SLEEP_OPTION then
                    sleep(nanoSleep)
end ifdef
                end for
            end if
            -- st += '0'
            for i = 1 to len do
                st[i] += '0'
ifdef not NO_SLEEP_OPTION then
                sleep(nanoSleep)
end ifdef
            end for
            if padWithZeros then
                --if ROUND_TO_NEAREST_OPTION then
                    st = st & repeat('0', d[3] - (len))
                --else
                --      st = st & repeat('0', (d[3] - adjustRound) - (len))
                --end if
            end if
            if f then
                st = "-" & st
            elsif padWithZeros then
                st = "+" & st
                f = 1
            end if
        else
            if d[1] = 1 then -- (+infinity)
                return "inf"
            elsif d[1] = -1 then -- (-infinity)
                return "-inf"
            end if
        end if
        -- f = (st[1] = '-')
        f += 1 -- f is now 1 or 2
        if length( st ) > f then
            st = st[1..f] & "." & st[f + 1..length(st)]
        end if
        st = st & "e" & ToString( d[2] )
        return st
    end if
end function
