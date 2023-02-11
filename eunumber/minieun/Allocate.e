-- Copyright (c) 2016-2023 James Cook
-- allocate.e contains low-level functions for EuNumber.
-- include eunumber/allocate.e

namespace allocate

public include std/memory.e
public include std/error.e

-- allocate:

constant
    M_A_TO_F64 = 46,
    M_F64_TO_A = 47,
    M_A_TO_F32 = 48,
    M_F32_TO_A = 49

ifdef BITS64 then
constant
    M_F80_TO_A = 101,
    M_A_TO_F80 = 105
end ifdef

type sequence_8(sequence s)
-- an 8-element sequence
    return length(s) = 8
end type

type sequence_4(sequence s)
-- a 4-element sequence
    return length(s) = 4
end type

-- Float32, single precision floating point format (float)

global function atom_to_float32(atom a)
    return machine_func(M_A_TO_F32, a)
end function

global function float32_to_atom(sequence_4 ieee32)
    return machine_func(M_F32_TO_A, ieee32)
end function

-- Float64, double precision floating point format (double)

global function atom_to_float64(atom a)
-- Convert an atom to a sequence of 8 bytes in IEEE 64-bit format
    return machine_func(M_A_TO_F64, a)
end function

global function float64_to_atom(sequence_8 ieee64)
-- Convert a sequence of 8 bytes in IEEE 64-bit format to an atom
    return machine_func(M_F64_TO_A, ieee64)
end function

-- Float80, extended precision floating point format (long double, or __float80)

ifdef BITS64 then
global function atom_to_float80(atom a)
    return machine_func(M_A_TO_F80, a)
end function

global function float80_to_atom( sequence bytes )
    return machine_func(M_F80_TO_A, bytes )
end function
end ifdef

-- allocate_data:

global function allocate_data( memory:positive_int n) --, types:boolean cleanup = 0)
-- allocate memory block and add it to safe list
    memory:machine_addr a
    bordered_address sla
    a = eu:machine_func( memconst:M_ALLOC, n+BORDER_SPACE*2)
    sla = memory:prepare_block(a, n, PAGE_READ_WRITE )
--     if cleanup then
--         return delete_routine( sla, memconst:FREE_RID )
--     else
        return sla
--     end if
end function

global type number_array( object x )
    if not sequence(x) then
        return 0
    end if

    for i = 1 to length(x) do
        if not atom(x[i]) then
            return 0
        end if
    end for
    return 1
end type

global type ascii_string( object x )
    if not sequence(x) then
        return 0
    end if

    for i = 1 to length(x) do
        if not integer(x[i]) then
            return 0
        end if
        if x[i] < 0 then
            return 0
        end if
        if x[i] > 127 then
            return 0
        end if
    end for
    return 1
end type

global procedure free(object addr)
    if number_array (addr) then
        if ascii_string(addr) then
            error:crash("free(\"%s\") is not a valid address", {addr})
        end if

        for i = 1 to length(addr) do
            memory:deallocate( addr[i] )
        end for
        return
    elsif sequence(addr) then
        error:crash("free() called with nested sequence")
    end if

    if addr = 0 then
        -- Special case, a zero address is assumed to be an uninitialized pointer,
        -- so it is ignored.
        return
    end if

    memory:deallocate( addr )
end procedure
memconst:FREE_RID = routine_id("free")

global function allocate_string(sequence s)
-- create a C-style null-terminated string in memory
    atom mem

    mem = allocate_data(length(s) + 1) -- Thanks to Igor
    if mem then
        poke(mem, s)
        poke(mem+length(s), 0)  -- Thanks to Aku
    end if
    return mem
end function

