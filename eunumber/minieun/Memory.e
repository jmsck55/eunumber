-- Copyright (c) 2016-2023 James Cook
-- Memory functions of EuNumber.
-- include eunumber/memoryfuncs.e

namespace memory

include Allocate.e

include ../array/Negate.e
include Eun.e
include UserMisc.e
include ConvertExp.e
include ToEun.e

constant TRUE = 1, FALSE = 0

-- Compression functions to store an "Eun" in memory:

global function ToMemory(sequence n1, integer windows = TRUE, integer degrade = FALSE)
    integer offset, size, flag
    atom ma
    sequence n2
    if not Eun(n1) then
        n1 = ToEun(n1)
    end if
    n2 = ConvertExp(n1[1], n1[2], 1 + Ceil(n1[3] * (log(n1[4]) / log(256))), n1[4], 256)
    n1[1] = length(n2[1])
    n1[2] = n2[2]
    n2 = n2[1]
    if length(n2) then
        if n2[1] < 0 then
            n1[3] = -n1[3] -- store sign information
            n2 = Negate(n2)
        end if
    end if
    flag = 1
ifdef BITS64 then
    if not degrade then
        flag = 0
        -- if windows then
            offset = 4 * 8 + 8
            size = offset + length(n2)
            ma = allocate_data(size)
            if ma = 0 then
                return 0 -- couldn't allocate data
            end if
            poke(ma, "eun" & 64 & "w" & repeat(' ', 3)) -- padded to 8-byte boundary
            poke8(ma + 8, n1[1..3])
            poke(ma + 4 * 8, atom_to_float64(n1[4]))
            poke(ma + offset, n2)
        -- else
        --     offset = 4 * 8 + 10
        --     size = offset + length(n2)
        --     ma = allocate_data(size)
        --     if ma = 0 then
        --         return 0 -- couldn't allocate data
        --     end if
        --     poke(ma, "eun" & 64 & "    ") -- padded to 8-byte boundary
        --     poke8(ma + 8, n1[1..3])
        --     poke(ma + 4 * 8, atom_to_float80(n1[4]))
        --     poke(ma + offset, n2)
        -- end if
    end if
end ifdef
    if flag then
        offset = 4 * 4 + 8
        size = offset + length(n2)
        ma = allocate_data(size)
        if ma = 0 then
            return 0 -- couldn't allocate data
        end if
        poke(ma, "eun" & 32)
        poke4(ma + 4, n1[1..3])
        poke(ma + 4 * 4, atom_to_float64(n1[4]))
        poke(ma + offset, n2)
    end if
    return {ma, size}
end function

global function FromMemoryToEun(atom ma)
    sequence n1, n2
    n1 = peek({ma, 4})
    if equal(n1, "eun" & 32) then
        n1 = peek4s({ma + 4, 3}) & float64_to_atom(peek({ma + 4 * 4, 8}))
        n2 = peek({ma + 4 * 4 + 8, n1[1]})
    else
ifdef BITS64 then
        n1 = peek({ma, 8})
        if equal(n1, "eun" & 64 & repeat(' ', 4)) then
            n1 = peek8s({ma + 8, 3}) & float80_to_atom(peek({ma + 4 * 8, 10}))
            n2 = peek({ma + 4 * 8 + 10, n1[1]})
        elsif equal(n1, "eun" & 64 & "w" & repeat(' ', 3)) then
            n1 = peek8s({ma + 8, 3}) & float64_to_atom(peek({ma + 4 * 8, 8}))
            n2 = peek({ma + 4 * 8 + 8, n1[1]})
        else
            return 0 -- unsupported format
        end if
        -- end if
end ifdef
    end if
    if n1[3] < 0 then
        -- signed
        n1[3] = -n1[3]
        n2 = Negate(n2)
    end if
    n2 = NewEun(n2, n1[2], 1 + Ceil(n1[3] * (log(n1[4]) / log(256))), 256)
    n1 = ConvertExp(n2[1], n2[2], n1[3], n2[4], n1[4])
    return n1
end function

global procedure FreeMemory(atom ma)
    free(ma)
end procedure

-- atom ma
--
-- ma = ToMemory("-0.01234")
-- puts(1, ToString(FromMemoryToEun(ma)))
--
-- FreeMemory(ma)
