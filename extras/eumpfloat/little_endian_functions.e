-- Copyright (c) 2022 James Cook

-- Little-endian functions: (based on scinot.e)
-- NOTE: Avoids floating_point bug.

-- Part of "eumpfloat" software library.

namespace little_endian

--include std/convert.e

public function ceil(object x)
    return -(floor(-(x)))
end function

--****
-- === Floating Point Types

public enum type floating_point
--**
-- NATIVE
-- Description:
-- Use whatever is the appropriate format based upon the version of
-- euphoria being used (DOUBLE for 32-bit, EXTENDED for 64-bit)
    NATIVE,
--**
-- DOUBLE:
-- Description
-- IEEE 754 double (64-bit) floating point format.
-- The native 32-bit euphoria floating point representation.
    DOUBLE,
--** EXTENDED: 80-bit floating point format.
-- The native 64-bit euphoria floating point reprepresentation.
    EXTENDED
end type

integer NATIVE_FORMAT

ifdef EU4_0 then
    NATIVE_FORMAT = DOUBLE
elsedef
    if sizeof( C_POINTER ) = 4 then
        NATIVE_FORMAT = DOUBLE
    else
        NATIVE_FORMAT = EXTENDED
    end if
end ifdef

-- taken from misc.e to avoid including
public function reverse(sequence s)
-- reverse the top-level elements of a sequence.
-- Thanks to Hawke' for helping to make this run faster.
    integer lower, n, n2
    sequence t
    
    n = length(s)
    n2 = floor(n/2)+1
    t = repeat(0, n)
    lower = 1
    for upper = n to n2 by -1 do
        t[upper] = s[lower]
        t[lower] = s[upper]
        lower += 1
    end for
    return t
end function


public function carry( sequence a, integer radix )
    atom q, r, b, rmax, i
    rmax = radix - 1
    i = 1
    while i <= length(a) do
        b = a[i]
        if b > rmax then
            q = floor( b / radix )
            r = remainder( b, radix )
            a[i] = r
            if i = length(a) then
                a &= 0
            end if
            a[i+1] += q
        end if
        i += 1
    end while
    
    return a
end function

public function add( sequence a, sequence b )
    
    if length(a) < length(b) then
        a &= repeat( 0, length(b) - length(a) )
    elsif length(b) < length(a) then
        b &= repeat( 0, length(a) - length(b) )
    end if
    
    return a + b
    
end function

public function borrow( sequence a, integer radix )
-- "actual" little-endian borrow(), thanks to jmsck55
    for i = 1 to length(a) - 1 do
        if a[i] < 0 then
            a[i] += radix
            a[i+1] -= 1
        end if
    end for
    return a
end function


public function bytes_to_bits(sequence bytes, integer nbits = 8)
-- Thanks to jmsck55 for making this not dependent on standard library.
    sequence bits
    integer mask, x, c
    bits = repeat(0, length(bytes) * nbits)
    c = 1
    for i = 1 to length(bytes) do
        x = bytes[i]
        mask = 1
        for j = 1 to nbits do
            bits[c] = and_bits(x, mask) and 1
            mask *= 2
            c += 1
        end for
    end for
    return bits
end function

public function bits_to_bytes(sequence bits, integer nbits = 8)
-- Thanks to jmsck55 for making this not dependent on standard library.
    sequence bytes
    integer value, p, c
    bytes = repeat(0, ceil(length(bits) / nbits))
    c = 1
    for i = 1 to length(bytes) do
        value = 0
        p = 1
        for j = 1 to nbits do
            if bits[c] then
                value += p
            end if
            p += p
            c += 1
        end for
        bytes[i] = value
    end for
    return bytes
end function


public function convert_radix(sequence number, integer from_radix, integer to_radix)
-- Thanks to jmsck55 for making this easier to trace.
    sequence target, base, a
    integer digit
    target = {0}
    if length(number) then
        base = {1}
        for i = 1 to length(number) do
            a = base
            digit = number[i]
            for j = 1 to length(a) do
                a[j] *= digit
            end for
            a = add( a, target )
            target = carry( a, to_radix )
            for j = 1 to length(base) do
                base[j] *= from_radix
            end for
            base = carry( base, to_radix )
        end for
    end if
    return target
end function


function half( sequence decimal )
    sequence quotient
    atom q, Q
    
    quotient = repeat( 0, length(decimal) )
    for i = 1 to length( decimal ) do
        q = decimal[i] / 2
        Q = floor( q )
        quotient[i] +=  Q
        
        if q != Q then
            if length(quotient) = i then
                quotient &= 0
            end if
            quotient[i+1] += 5
        end if
    end for
    return reverse( carry( reverse( quotient ), 10 ) )
end function

function first_non_zero( sequence s )
    for i = 1 to length(s) do
        if  s[i] then
            return i
        end if
    end for
    return 0
end function

function decimals_to_bits( sequence decimals, integer size )
    sequence sub, bits
    integer bit, assigned
    sub = {5}
    bits = repeat( 0, size )
    bit = 1
    assigned = 0

    -- Check for the simple case of zero. It must be guaranteed that no element of decimals
    -- is itself negative when this function is called and that its length is less than size+2.
    if compare(decimals, bits) > 0 then 

        while (not assigned) or (bit < find( 1, bits ) + size + 1)  do
            if compare( sub, decimals ) <= 0 then
                assigned = 1
                if length( bits ) < bit then
                    bits &= repeat( 0, bit - length(bits)) 
                end if
                
                bits[bit] += 1
                decimals = borrow( add( decimals, -sub ), 10 )
            end if
            sub = half( sub )
            
            bit += 1
        end while

    end if    
    return reverse(bits)
end function

function string_to_int( sequence s )
    integer int
    int = 0
    for i = 1 to length(s) do
        int *= 10
        int += s[i] - '0'
    end for
    return int
end function

function trim_bits( sequence bits )
        while length(bits) and not bits[$] do
            bits = remove( bits, length( bits ) )
        end while
        return bits
end function

public constant
    DOUBLE_SIGNIFICAND   =    52,
    DOUBLE_EXPONENT      =    11,
    DOUBLE_MIN_EXP       = -1023,
    DOUBLE_EXP_BIAS      =  1023,
    
    EXTENDED_SIGNIFICAND =     64,
    EXTENDED_EXPONENT    =     15,
    EXTENDED_MIN_EXP     = -16383,
    EXTENDED_EXP_BIAS    =  16383,
    $


--**
-- Description:
-- Takes a string reprepresentation of a number in scientific notation and
-- the requested precision (DOUBLE or EXTENDED) and returns a sequence of 
-- bytes in the raw format of an IEEE 754 double or extended
-- precision floating point number.  This value can be passed to the euphoria
-- library function, ##[[:float64_to_atom]]## or ##[[:float80_to_atom]]##, respectively.
--
-- Parameters:
--    # ##s## : string representation of a number, e.g., "1.23E4"
--    # ##fp## : the required precision for the ultimate representation
--    ## ##DOUBLE## Use IEEE 754, the euphoria representation used in 32-bit euphoria
--    ## ##EXTENDED## Use Extended Floating Point, the euphoria representation in 64-bit euphoria
--
-- Returns:
-- Sequence of bytes that represents the physical form of the converted floating point number.
--
-- Note: 
-- Does not check if the string exceeds IEEE 754 double precision limits.
--
public  function scientific_to_eumpfloat( sequence s, object custom = NATIVE )
    floating_point fp
    integer dp, e, exp, sbit
    sequence int_bits, frac_bits, mbits, ebits
    
    integer significand, exponent, min_exp, exp_bias
    if atom(custom) then
        fp = custom
        if fp = NATIVE then
            fp = NATIVE_FORMAT
        end if
        if fp = DOUBLE then
            significand = DOUBLE_SIGNIFICAND
            exponent    = DOUBLE_EXPONENT
            min_exp     = DOUBLE_MIN_EXP
            exp_bias    = DOUBLE_EXP_BIAS
            
        elsif fp = EXTENDED then
            significand = EXTENDED_SIGNIFICAND
            exponent    = EXTENDED_EXPONENT
            min_exp     = EXTENDED_MIN_EXP
            exp_bias    = EXTENDED_EXP_BIAS
        else
            return -1
        end if
    else
        fp = custom[1]
        significand = custom[2]
        exponent    = custom[3]
        min_exp     = custom[4]
        exp_bias    = custom[5]
    end if
    
    -- Determine if negative or positive
    if s[1] = '-' then
        sbit = 1
        s = remove( s, 1 )
    else
        sbit = 0
        if s[1] = '+' then
            s = remove( s, 1 )
        end if
    end if
    
    -- find the decimal point (if exists) and the exponent
    dp = find('.', s)
    e = find( 'e', s )
    if not e then
        e = find('E', s )
    end if
    
    -- calculate the exponent
    exp = 0
    if s[e+1] = '-' then
        exp -= string_to_int( s[e+2..$] )
    else

        if s[e+1] = '+' then
            exp += string_to_int( s[e+2..$] )
        else
            exp += string_to_int( s[e+1..$] )
        end if
    end if
    
    if dp then
        -- remove the decimal point
        s = remove( s, dp )
        e -= 1
        
        -- Adjust the exponent, because we moved the decimal point:
        exp -= e - dp
    end if
    
    -- We split the integral and fractional parts, because they have to be
    -- calculated differently.
    s = s[1..e-1] - '0'
    
    -- If LHS only consists of zeros, then return zero.
    if not find(0, s = 0) then
        -- TODO: finish this part, for zero:
        
        custom = {fp, significand, exponent, min_exp, exp_bias}
        
        return {sbit, custom, exp, repeat( 0, significand )} -- represents the value, zero (0).
    end if
    
    if exp >= 0 then
        -- We have a large exponent, so it's all integral.  Pad it to account for 
        -- the positive exponent.
        int_bits = trim_bits( bytes_to_bits( convert_radix( repeat( 0, exp ) & reverse( s ), 10, #100 ) ) )
        frac_bits = {}
    else
        if -exp > length(s) then
            -- all fractional
            int_bits = {}
            frac_bits = decimals_to_bits( repeat( 0, -exp-length(s) ) & s, significand ) 
        
        else
            -- some int, some frac
            int_bits = trim_bits( bytes_to_bits( convert_radix( reverse( s[1..$+exp] ), 10, #100 ) ) )
            frac_bits =  decimals_to_bits( s[$+exp+1..$], significand )
        end if
    end if
    
    if length(int_bits) > significand then
        -- Can disregard the fractional component, because the integral 
        -- component takes up all of the precision for which we have room.
        if fp = DOUBLE then
            -- the first 1 is implicit in a double
            mbits = int_bits[$-significand..$-1]
        else
            -- EXTENDED precision floats don't have an implicit bit
            mbits = int_bits[$-significand+1..$]
        end if
        
        if length(int_bits) > significand + 1 and int_bits[$-(significand+1)] then
            -- If the first bit that missed the precision is '1', then round up
            mbits[1] += 1
            mbits = carry( mbits, 2 )
        end if
        exp = length(int_bits)-1
            
    else
        if length(int_bits) then
            -- both fractional and integral
            exp = length(int_bits)-1
            
        else
            -- fractional only
            exp = - find( 1, reverse( frac_bits ) )
            if exp < min_exp then
                -- min_exp is the smallest exponent possible, so we may have to lose
                -- some precision.
                exp = min_exp
            end if
            
            if exp then
                -- Truncate it based on the exponent.\
                frac_bits = remove( frac_bits, length(frac_bits) + exp + 2, length( frac_bits ) )
            end if
            
        end if
        
        -- Now we combine the integral and fracional parts, and pad them
        -- just to make the slice easier.
        mbits = frac_bits & int_bits
        mbits = repeat( 0, significand + 1 ) & mbits
            
        if exp > min_exp then
            -- normalized
            if mbits[$-(significand+1)] then
                -- If the first bit that missed the precision is '1', then round up
                mbits[$-significand] += 1
                mbits = carry( mbits, 2 )
            end if
            if fp = DOUBLE then
                -- the first 1 is implicit in a double
                mbits = mbits[$-significand..$-1]
            else
                -- EXTENDED precision floats don't have an implicit bit
                mbits = remove( mbits, 1, length(mbits) - significand )
            end if
        else
            -- denormalized
            if mbits[$-significand] then
                -- If the first bit that missed the precision is '1', then round up
                mbits[$-significand] += 1
                mbits = carry( mbits, 2 )
            end if
            mbits = remove( mbits, 1, length(mbits) - significand )
        end if
            
    end if
    
    custom = {fp, significand, exponent, min_exp, exp_bias}
    
    return {sbit, custom, exp, mbits}
    
    -- -- Add the IEEE 784 specified exponent bias and turn it into bits
    -- ebits = int_to_bits( exp + custom[5], exponent ) -- custom[5] = exp_bias
    -- 
    -- -- Combine everything and convert to bytes (float64)
    -- return bits_to_bytes( mbits & ebits & sbit )
end function

--**
-- Description:
-- Takes a string reprepresentation of a number in scientific notation and returns
-- an atom.
--
-- Parameters:
--    # ##s## : string representation of a number (such as "1.23E4" ).
--    # ##fp## : the required precision for the ultimate representation.
--    ## ##DOUBLE## Use IEEE 754, the euphoria representation used in 32-bit Euphoria.
--    ## ##EXTENDED## Use Extended Floating Point, the euphoria representation in 64-bit Euphoria.
-- 
-- Returns:
-- Euphoria atom floating point number.

public  function scientific_to_float( sequence s, object custom = NATIVE )
    object eump
    
    eump = scientific_to_eumpfloat(s, custom)
    
    -- Add the IEEE 784 specified exponent bias and turn it into bits
    ebits = int_to_bits( eump[3] + custom[5], custom[3] ) -- custom[5] = exp_bias
    
    -- Combine everything and convert to bytes (float64)
    return { bits_to_bytes( eump[4] & ebits & eump[1] ), custom }
end function


