-- Copyright (c) 2016-2023 James Cook

include ../../eunumber/minieun/nanosleep.e

global function Exponentiation(atom u, integer m)
    atom q, prod, current
    q = m
    prod = 1
    current = u
    if q > 0 then
        while q > 0 do
            if remainder(q, 2) = 1 then
                prod *= current
                q -= 1
            end if
            current *= current
            q /= 2
ifdef not NO_SLEEP_OPTION then
            sleep(nanoSleep)
end ifdef
        end while
    else
        while q < 0 do
            if remainder(q, 2) = -1 then
                prod /= current
                q += 1
            end if
            current *= current
            q /= 2
ifdef not NO_SLEEP_OPTION then
            sleep(nanoSleep)
end ifdef
        end while
    end if
    return prod
end function

-- atom E = 2.7182818284590452353602874713527
-- ? Exponentiation(E, 20) -- answer is 485165195.4
-- ? Exponentiation(E, -21) -- answer is 7.582560428e-10
