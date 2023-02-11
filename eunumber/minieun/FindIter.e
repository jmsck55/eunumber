-- Copyright (c) 2016-2023 James Cook


include Common.e


global Bool findIterHalf = 1
global Bool findIterZero = 0

global function FindIter(Bool isExit, sequence s, PositiveScalar minvalue, PositiveScalar maxvalue)
    integer iter, half, confidence
    ifdef USE_TASK_YIELD then
        if useTaskYield then
            task_yield()
        end if
    end ifdef
    iter = s[1] -- starts at minvalue
    half = s[2] -- starts at 0
    confidence = s[3]
    if isExit then -- will exit
        confidence += 1
        if half > 1 then -- ok.
            half = floor(half / 2)
            iter -= half
        elsif findIterHalf then
            iter -= 1 -- iter = floor(iter / 2)
        end if
    -- will continue calculating
    elsif confidence <= 0 then
        confidence = 0
        half = iter
        iter *= 2
    elsif half > 1 then
        confidence -= 1
        half = floor(half / 2)
        iter += half
    else
        if confidence > 0 then
            confidence = 0
        end if
        if findIterZero then
            iter *= 2
            half = iter
        else
            half = iter -- floor(iter / 2)
            iter *= 2
        end if
    end if
    if iter < minvalue then -- min value, defaults to 4
        half = 0 -- reset to initial
        iter = minvalue -- reset to initial
        confidence = 0
    elsif iter > maxvalue then
        iter = maxvalue
        half = iter -- floor(iter / 2)
        confidence = 1
    end if
    s = {iter, half, confidence}
    return s
end function
