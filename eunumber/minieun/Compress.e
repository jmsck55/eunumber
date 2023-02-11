-- Copyright (c) 2016-2023 James Cook
-- CompressLeadingDigit functions of EuNumber.
-- include eunumber/compress.e

-- These functions are useful for compressing lots of small number arrays to save memory space.

namespace compressleading

include Eun.e
include UserMisc.e

global function EunCompressLeadingDigit(Eun n1, integer compressLead = floor(n1[4] / 2))
    sequence num = n1[1]
    atom f
    if length(num) then
        f = num[1]
        if abs(f) <= compressLead then
            f *= n1[4]
            num = num[2..$]
            if length(num) then
                num[1] += f
            else
                num = {f}
            end if
            n1[1] = num
            n1[2] -= 1
        end if
    end if
    return n1
end function

global function EunUnCompressLeadingDigit(Eun n1)
    sequence num = n1[1]
    atom f, a, radix = n1[4]
    if length(num) then
        f = num[1]
        a = abs(f)
        if a >= radix then
            num[1] = remainder(f, radix)
            a = floor(a / radix)
            if f < 0 then
                a = - (a)
            end if
            num = {a} & num
            n1[1] = num
            n1[2] += 1
        end if
    end if
    return n1
end function
