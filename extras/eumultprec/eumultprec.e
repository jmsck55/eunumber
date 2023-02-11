-- Copyright (c) 2022 James Cook
-- EuMultPrec, Euphoria Multiple Precision Library
-- Goal: Use 30-bit or 62-bit integers as limbs in a library similar to GMP.

namespace mp

include std/get.e

function iff(integer condition, object a, object b)
    if condition then
        return a
    else
        return b
    end if
end function

function min(integer a, integer b)
    return iff(a < b, a, b)
end function

function max(integer a, integer b)
    return iff(a > b, a, b)
end function

------------------------------------------
-- Begin: Constants Section, don't modify:
------------------------------------------

public function Version()
    return 0 -- not release quite yet, not fully tested.
end function

ifdef BITS64 then
constant INTEGER_MAX = #3FFFFFFFFFFFFFFF
elsedef
constant INTEGER_MAX = #3FFFFFFF
end ifdef

--ifdef USE_DECIMAL then
integer myBASE = 10
integer myPREC = 100 -- default precision, of limbs
ifdef BITS64 then
integer myPREC_LIMB = 18
integer myMAX_LIMB = 1000000000000000000 - 1
integer myHALF_LIMB = 1000000000
elsedef
integer myPREC_LIMB = 8
integer myMAX_LIMB = 100000000 - 1
integer myHALF_LIMB = 10000
end ifdef
--elsedef
--integer myBASE = 2
--ifdef BITS64 then
--integer myPREC_LIMB = 60
--integer myMAX_LIMB = #0FFFFFFFFFFFFFFF
--integer myHALF_LIMB = #40000000
--elsedef
--integer myPREC_LIMB = 28
--integer myMAX_LIMB = #0FFFFFFF
--integer myHALF_LIMB = #4000
--end ifdef
--end ifdef

public enum BASE, PREC, PREC_LIMB, MAX_LIMB, HALF_LIMB

sequence CONFIG = {myBASE, myPREC, myPREC_LIMB, myMAX_LIMB, myHALF_LIMB}

-------------------------------------------
-- End of: Constants Section, don't modify.
-------------------------------------------

-- get_config():

public function get_config()
    return CONFIG
end function

-- set_prec(prec):

public procedure set_prec(integer prec)
    myPREC = prec
    CONFIG[PREC] = prec
end procedure

-- set_base(base):

-- Something small for base, such as: 2, 10, 100, 256

public procedure set_base(integer base)
    -- prec <==> (log(HALF_LIMB ^ n) / log(BASE)) * 2
    -- prec <==> log(HALF_LIMB ^ (n * 2)) / log(BASE)
    -- prec <==> log(FULL_LIMB ^ n) / log(BASE)
    -- prec <==> (log(FULL_LIMB ^ (n / n)) / log(BASE)) * n
    -- n <==> prec / (log(FULL_LIMB ^ 1) / log(BASE))
    -- n <==> prec / ((log(FULL_LIMB ^ (1 / 2)) / log(BASE)) * 2)
    -- n <==> prec / ((log(HALF_LIMB ^ 1) / log(BASE)) * 2)
    -- number_of_limbs <==> prec / PREC_LIMB
    -- how_many_limbs <==> floor(prec / PREC_LIMB) + 1
    integer half_prec
    myBASE = base
    myPREC_LIMB = floor(log(floor(INTEGER_MAX / 2)) / log(myBASE))
    half_prec = floor(myPREC_LIMB / 2)
    myPREC_LIMB = half_prec * 2 -- round down to be evenly divided by two.
    myHALF_LIMB = power(myBASE, half_prec)
    myMAX_LIMB = myHALF_LIMB * myHALF_LIMB - 1
    CONFIG = {myBASE, myPREC, myPREC_LIMB, myMAX_LIMB, myHALF_LIMB}
end procedure

-- Add and Subtract, primative functions:

public function add_limbs(sequence a, sequence b, sequence config = CONFIG)
-- little endian
    sequence ret
    integer base = config[MAX_LIMB] + 1
    if length(a) = length(b) then
        ret = a + b
        -- len = length(ret)
    elsif length(a) < length(b) then
        ret = b
        ret[1..length(a)] += a
    else
        ret = a
        ret[1..length(b)] += b
    end if
    for pos = 1 to length(ret) do
        if ret[pos] >= base then
            ret[pos] -= base
            if pos = length(ret) then
                ret = ret & {1}
            else
                ret[pos + 1] += 1
            end if
        end if
    end for
    return ret
end function

public function subtract_limbs(sequence a, sequence b, sequence config = CONFIG)
-- little endian
    sequence ret
    integer isneg, base = config[MAX_LIMB] + 1
    if length(a) = length(b) then
        ret = a - b
    elsif length(a) < length(b) then
        ret = (- b)
        ret[1..length(a)] += a
    else
        ret = a
        ret[1..length(b)] -= b
    end if
    while length(ret) and ret[$] = 0 do
        ret = ret[1..$-1]
    end while
    if length(ret) = 0 then
        return {0, {}}
    end if
    isneg = - (ret[$] < 0)
    if isneg then
        ret = (- ret)
    end if
    for pos = 1 to length(ret) do
        if ret[pos] < 0 then
            ret[pos] += base
            if pos = length(ret) then
                ret = ret & {-1} -- never called, but leave it in there for now.
            else
                ret[pos + 1] -= 1
            end if
        end if
    end for
    while length(ret) and ret[$] = 0 do
        ret = ret[1..$-1]
    end while
    if length(ret) = 0 then
        return {0, {}}
    end if
    return {isneg, ret}
end function

public function add(sequence n1, sequence n2, sequence config = CONFIG)
    if n1[1] xor n2[1] then
        -- limbs will be subtracted
        if n1[1] then
            return subtract_limbs(n2[2], n1[2], config) -- already has isneg flag
        else
            return subtract_limbs(n1[2], n2[2], config) -- already has isneg flag
        end if
    else -- both are positive, or negative
        return {n1[1], add_limbs(n1[2], n2[2], config)}
    end if
end function

public function negate(sequence n1)
    n1[1] = - (not n1[1])
    return n1
end function

public function subtract(sequence n1, sequence n2, sequence config = CONFIG)
    return add(n1, negate(n2), config)
end function

public function add_limb_exp(sequence n1, integer exp1, sequence n2, integer exp2, sequence config = CONFIG)
    sequence a, b, ret
    integer exponent
    a = n1[2]
    b = n2[2]
    exponent = (length(a) - (exp1)) - (length(b) - (exp2))
    if exponent < 0 then
        a = repeat(0, - (exponent)) & a
    elsif exponent > 0 then
        b = repeat(0, exponent) & b
    end if
    exponent = max(exp1, exp2)
    exponent -= max(length(a), length(b))
    n1[2] = a
    n2[2] = b
    ret = add(n1, n2, config)
    exponent += length(ret[2])
    return {exponent, ret}
end function

public function subtract_limb_exp(sequence n1, integer exp1, sequence n2, integer exp2, sequence config = CONFIG)
    return add_limb_exp(n1, exp1, negate(n2), exp2, config) --, prec)
end function

-- Multiplication:

public function expand(sequence a, sequence config = CONFIG)
    integer pos, half_limb = config[HALF_LIMB]
    sequence ret
    ret = repeat(0, length(a) * 2)
    pos = 1
    for i = 2 to length(ret) by 2 do
        ret[i] = floor(a[pos] / half_limb)
        ret[i - 1] = a[pos] - (ret[i] * half_limb)
        pos += 1
    end for
    return ret
end function

public function contract(sequence b, sequence config = CONFIG)
    -- takes an expanded sequence
    integer pos, half_limb = config[HALF_LIMB]
    sequence ret
    ret = repeat(0, floor((length(b) + 1) / 2))
    pos = 1
    for i = 1 to length(ret) do
        ret[i] = b[pos]
        pos += 1
        if pos > length(b) then
            exit
        end if
        ret[i] += b[pos] * half_limb
        pos += 1
    end for
    return ret
end function

public function multiply_limbs(sequence a, sequence b, integer len = -1, sequence config = CONFIG)
-- optional argument "len" is ignored for now.
    integer f, j, g, k, half_limb = config[HALF_LIMB]
    sequence ret, temp
    a = expand(a, config)
    b = expand(b, config)
    -- len *= 2 -- NOTE: Not needed.
    len = length(a) + length(b) - 1 -- this way always works, but may be slower.
    ret = repeat(0, len)
    f = length(b)
    for i = 1 to length(a) do
        g = a[i]
        j = 1
        for h = i to min(len, f) do
            temp = {g * b[j]}
            if temp[1] >= half_limb then
                temp = temp & {floor(temp[1] / half_limb)}
                temp[1] -= temp[2] * half_limb
            end if
            for pos = 1 to length(temp) do -- length(temp) is 1 or 2
                k = h + pos - 1
                ret[k] += temp[pos]
                if ret[k] >= half_limb then
                    ret[k] -= half_limb
                    if k = length(ret) then
                        ret = append(ret, 1)
                    else
                        ret[k + 1] += 1
                    end if
                end if
            end for
            j += 1
        end for
        f += 1
    end for
    ret = contract(ret, config)
    while length(ret) and ret[$] = 0 do
        ret = ret[1..$-1]
    end while
    return ret
end function

public function multiply(sequence n1, sequence n2, sequence config = CONFIG)
    sequence a, b, c, ret
    integer how_many_limbs, prec = config[PREC], prec_limb = config[PREC_LIMB]
    how_many_limbs = floor(prec / prec_limb) + 1
    a = n1[2]
    b = n2[2]
    c = multiply_limbs(a, b, how_many_limbs, config)
    if length(c) > how_many_limbs then
        c = c[$ - how_many_limbs + 1..$]
    end if
    ret = {-(n1[1] xor n2[1]), c}
    return ret
end function

public function multiply_limb_exp(sequence n1, integer exp1, sequence n2, integer exp2, sequence config = CONFIG)
    sequence ret
    ret = multiply(n1, n2, config)
    return {exp1 + exp2, ret}
end function

-- Division:

integer iter = 1000000000
public integer mi_count = -1

public function proto_multiplicative_inverse_exp(sequence guess, integer exp0, sequence den1, integer exp1, sequence config = CONFIG)
    -- f(a) = a * (2 - n1 * a)
    sequence ret
    ret = multiply_limb_exp(guess, exp0, den1, exp1, config)
    -- trace(1)
    ret = subtract_limb_exp({0, {2}}, 0, ret[2], ret[1], config)
    -- trace(1)
    ret = multiply_limb_exp(guess, exp0, ret[2], ret[1], config)
    return ret
end function

public function multiplicative_inverse_exp(sequence den1, integer exp1, sequence guess = {0, {1}}, sequence config = CONFIG)
    sequence ret, lookat
    integer exp0
    exp0 = - (exp1) - 1
    ret = {exp0, guess}
    mi_count = 0 -- for debugging
    for i = 1 to iter do
        lookat = ret
        ret = proto_multiplicative_inverse_exp(guess, exp0, den1, exp1, config)
        exp0 = ret[1]
        guess = ret[2]
        if equal(ret, lookat) then
            mi_count = i -- for debugging
            exit
        end if
    end for
    return ret
end function

public function divide_exp(sequence num0, integer exp0, sequence den1, integer exp1, sequence mi_guess = {0, {1}}, sequence config = CONFIG)
    sequence ret
    ret = multiplicative_inverse_exp(den1, exp1, mi_guess, config)
    ret = multiply_limb_exp(num0, exp0, ret[2], ret[1], config)
    return ret
end function

-- Data Type:

constant zero =
{
    CONFIG, -- config data structure
    {
        0, -- exponent
        {
            0, -- sign flag (0, 1, or -1)
            {} -- number data
        }
    }
}

constant one =
{
    CONFIG, -- config data structure
    {
        0, -- exponent
        {
            0, -- sign flag (0, 1, or -1)
            {1} -- number data
        }
    }
}

constant neg_one =
{
    CONFIG, -- config data structure
    {
        0, -- exponent
        {
            -1, -- sign flag (0, 1, or -1)
            {1} -- number data
        }
    }
}

public type mpvar(sequence s)
    if length(s) = 0 then
        return 0
    end if
    if not sequence(s[1]) or length(s[1]) != length(CONFIG) then
        return 0
    end if
    for i = 1 to length(s[1]) do
        if not integer(s[1][i]) then
            return 0
        end if
    end for
    for i = 2 to length(s) do
        if not sequence(s[i]) or length(s[i]) != 2 then
            return 0
        end if
        if not integer(s[i][1]) then
            return 0
        end if
        if not sequence(s[i][2]) or length(s[i][2]) != 2 then
            return 0
        end if
        if not integer(s[i][2][1]) then
            return 0
        end if
        if not sequence(s[i][2][2]) then
            return 0
        end if
    end for
    return 1
end type

public function NewMP(sequence s, sequence config = CONFIG)
    mpvar ret = {config} & s
    return ret
end function

-- Input / Output:

public function mp_to_string(mpvar s)
-- done.
    sequence st, st_format, limbs, decimal
    integer exp1
    if s[1][BASE] != 10 then
        return ""
    end if
    st_format = "%0" & sprintf("%d", {s[1][PREC_LIMB]}) & "d"
    st = ""
    for i = 2 to length(s) do
        --if s[i][2][1] then
        --      st = st & "-"
        --else
        --      st = st & "+"
        --end if
        limbs = s[i][2][2]
        decimal = {}
        for j = length(limbs) to 1 by -1 do
            decimal = decimal & sprintf(st_format, {limbs[j]})
        end for
        exp1 = ((s[i][1] + 1) * s[1][PREC_LIMB]) - 1
        while length(decimal) and decimal[1] = '0' do
            exp1 -= 1
            decimal = decimal[2..$]
        end while
        st = st & iff(s[i][2][1], "-", "+") & decimal[1] & "." & decimal[2..$] & sprintf("e%+d\n", {exp1})
    end for
    return st
end function

public function string_to_mp(sequence st, sequence config = CONFIG)
    mpvar mp
    sequence s, data
    integer f, ch, exp, part, p
    s = {
        config, -- config data structure
        {
            0, -- exponent
            {
                0, -- sign flag (0, 1, or -1)
                {} -- number data
            }
        }
    }
    if st[1] = '-' then
        s[2][2][1] = -1
        st = st[2..$]
    elsif st[1] = '+' then
        st = st[2..$]
    end if
    f = find('e', st)
    if not f then
        f = find('E', st)
    end if
    if f then
        -- process exponent
        data = value(st, f + 1)
        if data[1] != GET_SUCCESS then
            return {}
        end if
        exp = data[2]
        st = st[1..f - 1]
    else
        exp = 0
    end if
    f = find('.', st)
    if f then
        st = st[1..f - 1] & st[f + 1..$]
        f -= 1
    else
        f = length(st)
    end if
    exp += f - 1
    -- first one done separately
    
    -- f==1
    
    
    data = ","
    trace(1)
    for i = f to 1 by - config[PREC_LIMB] do
        data = data & st[f - config[PREC_LIMB] + 1..f] & ","
    end for
    data = "{0" & data & "0}"
    data = value(data)
    if data[1] = GET_SUCCESS then
        ? data[2]
    end if
    
    
    --here, do something with leading zeros
    
    mp = s
    return mp
end function

--  mp = {
--         3,
--         {
--           0,
--           {67896789,67896789,67896789,67896789,67896789,67896789,67896789,
-- 67896789,67896789,67896789,67896789,67896789,67896789,4,3,2,1}
--         }
--       }
--  st = {43'+',49'1',46'.',48'0',48'0',48'0',48'0',48'0',48'0',48'0',50'2',
-- 48'0',48'0',48'0',48'0',48'0',48'0',48'0',51'3',48'0',48'0',48'0',48'0',
-- 48'0',48'0',48'0',52'4',54'6',55'7',56'8',57'9',54'6',55'7',56'8',57'9',
-- 54'6',55'7',56'8',57'9',54'6',55'7',56'8',57'9',54'6',55'7',56'8',57'9',
-- 54'6',55'7',56'8',57'9',54'6',55'7',56'8',57'9',54'6',55'7',56'8',57'9',
-- 54'6',55'7',56'8',57'9',54'6',55'7',56'8',57'9',54'6',55'7',56'8',57'9',
-- 54'6',55'7',56'8',57'9',54'6',55'7',56'8',57'9',54'6',55'7',56'8',57'9',
-- 54'6',55'7',56'8',57'9',54'6',55'7',56'8',57'9',54'6',55'7',56'8',57'9',
-- 54'6',55'7',56'8',57'9',54'6',55'7',56'8',57'9',54'6',55'7',56'8',57'9',
-- 54'6',55'7',56'8',57'9',54'6',55'7',56'8',57'9',54'6',55'7',56'8',57'9',
-- 54'6',55'7',56'8',57'9',54'6',55'7',56'8',57'9',54'6',55'7',56'8',57'9',
-- 101'e',43'+',50'2',52'4',10}


-- end of file.
