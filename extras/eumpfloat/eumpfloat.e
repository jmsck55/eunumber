-- Copyright (c) 2022 James Cook
-- Make a datatype like floating point, for scientific calculations.

-- See: quadmath.h from GCC, for functions on float128

-- Uses Double floating point precision:
-- https://en.wikipedia.org/wiki/Double-precision_floating-point_format

namespace eumpfloat

without trace
-- public include std/convert.e
public include std/machine.e
with trace

public include little_endian_functions.e

-- Little endian, like x86_64 (64bit) or i386 (32bit)

-- public function int_to_bits(atom x, integer nbits = 32)
--      sequence bits
--      atom mask
-- 
--      if nbits < 1 then
--              return {}
--      end if
--      bits = repeat(0, nbits)
--      if nbits <= 32 then
--              -- faster method
--              mask = 1
--              for i = 1 to nbits do
--                      bits[i] = and_bits(x, mask) and 1
--                      mask *= 2
--              end for
--      else
--              -- slower, but works for large x and large nbits
--              if x < 0 then
--                      x += power(2, nbits) -- for 2's complement bit pattern
--              end if
--              for i = 1 to nbits do
--                      bits[i] = remainder(x, 2)
--                      x = floor(x / 2)
--              end for
--      end if
--      return bits
-- end function
-- 
-- public function bits_to_int(sequence bits)
-- -- get the (positive or two's compliment) value of a sequence of "bits"
-- --for signed_int(), uncomment below in this function.
-- -- -- if highest order bit is true, get the two's compliment.
--      atom value, p
-- --      integer sign
-- --      sign = bits[$]
-- --      if sign then
-- --              bits = not bits
-- --      end if
--      value = 0
--      p = 1
--      for i = 1 to length(bits) - 1 do
--              if bits[i] then
--                      value += p
--              end if
--              p += p
--      end for
-- --      if sign then
-- --              value = - (value)
-- --              value -= 1
-- --      end if
--      return value
-- end function


-- C/C++ double datatype has 11bits for the exponent, and 52bits for the fraction
global constant double_config = {
        DOUBLE,
        DOUBLE_SIGNIFICAND,
        DOUBLE_EXPONENT,
        DOUBLE_MIN_EXP,
        DOUBLE_EXP_BIAS
    }

global sequence default_config = double_config

-- custom = {fp, significand, exponent, min_exp, exp_bias}

-- {
-- integer cexponentbits -- 11
-- integer cfractionbits -- 52
-- integer csizeinbits -- cexponentbits + cfractionbits + 1
-- integer csizeinbytes -- ceil(csizeinbits / 8)
-- integer cbias -- power(2, cexponentbits - 1) - 1
-- }

public function new_float_config(integer fractionbits = 52, integer exponentbits = 11, integer dtype = DOUBLE)
    --integer sizeinbits = exponentbits + fractionbits + 1
    --integer sizeinbytes = ceil(sizeinbits / 8)
    integer bias = power(2, exponentbits - 1) - 1
    return {
        dtype,
        fractionbits,
        exponentbits,
        -bias,
        bias
    }
end function
-- 
-- change_float_config()

-- public function get_float_config()
--     return default_config
-- end function

public type eumpfloat(object x)
    if sequence(x) then
        if length(x) = 4 then
            if integer(x[1]) then
                if sequence(x[2]) then
                    if length(x[2]) = 5 then
                        if integer(x[3]) then
                            if sequence(x[4]) then
                                return 1
                            end if
                        end if
                    end if
                end if
            end if
        end if
    end if
    return 0
end type

public function new_eumpfloat(
                integer signbit = 0,
                sequence config = default_config,
                integer exponent = config[4],
                sequence fraction = repeat(0, config[2])
                )

    eumpfloat n = {signbit, config, exponent, fraction}
    return n
end function


public function StringToFloat(sequence tdouble, object custom)
    
    return scientific_to_eumpfloat(tdouble, custom)
end function

public function FloatToString(eumpfloat d)
-- converts a Float to a string.
    sequence st
    integer f, len
    
    --here
    
    if 1 then --here, handle infinities (inf) and not a number (NAN)
        st = d[4]
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
end function

-- memory functions:

-- Remember to free() data allocated with "allocate_data()" functions, before program finishes.

public function MemoryToBytes(atom ma, integer size)
    sequence bytes
    bytes = peek({ma, size})
    return bytes
end function

public function BytesToMemory(sequence bytes)
-- Remember to use free() when done with the data.
    atom ma
    ma = allocate_data(length(bytes))
    poke(ma, bytes)
    return ma
end function

public function FloatToBytes(eumpfloat a)
    sequence b
    integer signbit = a[1]
    sequence config = a[2]
    integer exponent = a[3]
    sequence fraction = a[4]
    integer fractionbits = config[2]
    integer exponentbits = config[3]
    integer sizeinbits = fractionbits + exponentbits + 1
    integer sizeinbytes = ceil(sizeinbits / 8)
    integer bias = config[5]
    --if 1 then
        exponent += bias
    --end if
    b = fraction & int_to_bits(exponent, exponentbits) & {signbit} -- {signbit and 1}
    b = bits_to_bytes(b)
    if length(b) != sizeinbytes then
        abort(1/0)
    end if
    return b
end function

public function BytesToFloat(sequence bytes, sequence config = get_float_config())
    integer exponent, signbit
    sequence bits, fraction
    integer fractionbits = config[2]
    integer exponentbits = config[3]
    integer sizeinbits = fractionbits + exponentbits + 1
    integer sizeinbytes = ceil(sizeinbits / 8)
    integer bias = config[5]
    bits = bytes_to_bits(bytes)
    
    fraction = bits[1..fractionbits]
    bits = bits[fractionbits + 1..$]
    exponent = bits_to_int(bits[1..exponentbits])
    --if exponent != 0 then
        exponent -= bias
    --end if
    signbit = bits[exponentbits + 1]
    
    return new_eumpfloat(signbit, config, exponent, fraction)
end function

-- negate, add, subtract, multiply, divide:

public function Negate(eumpfloat s)
    s[1] = s[1] xor 1 -- toggles s[1]'s on/off bit (1 becomes 0, 0 becomes 1)
    return s
end function

-- Convert an "eumpfloat" to an "eun" and back again.

public function add()
    
    return 0
end function

public function subtract()
    
    return 0
end function

public function multiply()
    
    return 0
end function

public function divide()
    
    return 0
end function

puts(1, "DEBUG: eumpfloat.e: ok, done.\n")
-- end of file.
