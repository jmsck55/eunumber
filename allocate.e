
include std/memory.e

constant
	M_A_TO_F64 = 46,
	M_F64_TO_A = 47

type sequence_8(sequence s)
-- an 8-element sequence
    return length(s) = 8
end type

public function atom_to_float64(atom a)
-- Convert an atom to a sequence of 8 bytes in IEEE 64-bit format
    return machine_func(M_A_TO_F64, a)
end function

public function float64_to_atom(sequence_8 ieee64)
-- Convert a sequence of 8 bytes in IEEE 64-bit format to an atom
    return machine_func(M_F64_TO_A, ieee64)
end function

public function allocate_data( memory:positive_int n) --, types:boolean cleanup = 0)
-- allocate memory block and add it to safe list
	memory:machine_addr a
	bordered_address sla
	a = eu:machine_func( memconst:M_ALLOC, n+BORDER_SPACE*2)
	sla = memory:prepare_block(a, n, PAGE_READ_WRITE )
-- 	if cleanup then
-- 		return delete_routine( sla, memconst:FREE_RID )
-- 	else
		return sla
-- 	end if
end function

public procedure free(object addr)
-- 	if types:number_array (addr) then
-- 		if types:ascii_string(addr) then
-- 			error:crash("free(\"%s\") is not a valid address", {addr})
-- 		end if
-- 		
-- 		for i = 1 to length(addr) do
-- 			memory:deallocate( addr[i] )
-- 		end for
-- 		return
-- 	elsif sequence(addr) then
-- 		error:crash("free() called with nested sequence")
-- 	end if
	
	if addr = 0 then
		-- Special case, a zero address is assumed to be an uninitialized pointer,
		-- so it is ignored.
		return
	end if

	memory:deallocate( addr )
end procedure
memconst:FREE_RID = routine_id("free")

public function allocate_string(sequence s)
-- create a C-style null-terminated string in memory
    atom mem
    
    mem = allocate_data(length(s) + 1) -- Thanks to Igor
    if mem then
	poke(mem, s)
	poke(mem+length(s), 0)  -- Thanks to Aku
    end if
    return mem
end function

