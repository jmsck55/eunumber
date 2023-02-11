-- Copyright (c) 2023 James Cook
-- Test program, testprog.ex

-- At the prompt, type in something like: 0.5 to 0.75 by 0.25, with 1 for imaginary part, and 0 for Complex constant.


include std/get.e
include std/console.e
include std/map.e
include std/io.e
include std/graphics.e


with trace

with define USE_TASK_YIELD
with define DEBUG_TASK

include ../eunumber/my.e

schedule_check_break()

SetRealMode(0) -- turn realMode off and complex mode on.

constant args = {

-- Eun functions:

    {"EunMultiplicativeInverse", {-999, {-999, {}}, {"EunMultiplicativeInverse"}}},
    
    {"EunExp", {eunExpRID, {-999}, {"EunLog"}}},
    {"EunExpA", {eunExpARID, {-999}, {"EunLog"}}},
    {"EunExpB", {-999, {-999}, {"EunLog"}}},
    {"EunExpC", {-999, {-999}, {"EunLog"}}},
    {"EunExp1", {eunExp1RID, {-999}, {"EunLog"}}},
    {"EunExp1A", {-999, {-999}, {"EunLog"}}},
    --{"EunExpFast", {-999, {-999, NewEun({1})}, {"EunLog"}}},
    --{"EunExpFast1", {-999, {-999}, {"EunLog"}}},
    --{"EunExpFastA", {-999, {-999}, {"EunLog"}}},
    {"EunLog", {-999, {-999}, {"EunExp"}, {"ComplexExp"}}},
    {"EunLog1", {-999, {-999}, {"EunExp"}, {"ComplexExp"}}},
    
    {"EunSquared", {-999, {-999}, {"EunSquareRoot"}}},
    {"EunSquareRoot", {-999, {-999, 0}, {"EunSquared"}, {"ComplexSquared"}}},

-- Trig functions:

    {"EunTan", {-999, {-999}, {"EunArcTan"}}},
    {"EunArcTan", {-999, {-999}, {"EunTan"}}},

    {"EunCos", {-999, {-999}, {"EunArcCos"}}},
    {"EunArcCos", {-999, {-999}, {"EunCos"}}},

    {"EunSin", {-999, {-999}, {"EunArcSin"}}},
    {"EunArcSin", {-999, {-999}, {"EunSin"}}},

-- Complex functions:

    {"ComplexMultiplicativeInverse", {-999, {NewComplex()}, {}, {"ComplexMultiplicativeInverse"}}},

    {"ComplexTan", {-999, {NewComplex()}, {}, {"ComplexArcTan", "ComplexArcTanA"}}},
    {"ComplexArcTan", {-999, {NewComplex()}, {}, {"ComplexTan"}}},
    {"ComplexArcTanA", {-999, {NewComplex()}, {}, {"ComplexTan"}}},

    {"ComplexExp", {-999, {NewComplex()}, {}, {"ComplexLog"}}},
    {"ComplexLog", {-999, {NewComplex()}, {}, {"ComplexExp"}}},

    {"ComplexSquared", {-999, {NewComplex()}, {}, {"ComplexSquareRoot", "ComplexSquareRootA"}}},
    {"ComplexSquareRoot", {-999, {NewComplex()}, {}, {"ComplexSquared"}}},
    {"ComplexSquareRootA", {-999, {NewComplex()}, {}, {"ComplexSquared"}}},
    $}

constant dumpfile = "test/testcode.txt"

-- Domain, min, max, increment

atom domainMin, domainMax, domainIncrement
integer isRealFlag
sequence st, complexPart
object ob

puts(1, "Debugging code, enter domain min, max, and increment.\n")
puts(1, "Testing All Functions.\n")
printf(1, "Dump file is \"%s\"\n", {dumpfile})
puts(1, "\n")

domainMin = prompt_number("Domain Min: ", {-1000, 1000})
domainMax = prompt_number("Domain Max: ", {-1000, 1000})
domainIncrement = prompt_number("Domain Increment: ", {-1000, 1000})
isRealFlag = prompt_number("Complex constant: 2 for real part, 1 for imaginary part: ", {1, 2})
isRealFlag -= 1

puts(1, "Enter a number or an Eun to use as the Complex constant part:\n")

st = stdget:get(0)
puts(1, "\n")
if st[1] != GET_SUCCESS then
    puts(1, "Error. Must be a valid Euphoria object.\n")
    abort(1)
end if

ob = st[2]

if not Eun(ob) then
    if atom(ob) then
        ob = sprintf("%.12e", ob)
    end if
    ob = ToEun(ob)
end if

complexPart = ob

st = prompt_string("Do you wish to continue? [yn] ")
puts(1, "\n")
if not equal(st, "y") then
    puts(1, "User declined to continue, exiting.\n")
    abort(0)
end if

--trace(1)

map p = new_from_kvpairs(args)

function make_routine_ids(object k, object v, object d, integer pc)
    if v[1] = -999 then
        v[1] = routine_id(k)
        put(p, k, v)
    end if
    return 0
end function

object errorCode

errorCode = for_each(p, routine_id("make_routine_ids"))

if not equal(errorCode, 0) then
    puts(1, "Error. In make_routine_ids().\n")
    abort(1)
end if

integer fn

function evaluate_calculation(object k, object v, object d, integer pc)
    atom x
    sequence s, param
    object a, b, c, r, key, val, difference, len
    integer t
    printf(1, "%s\n", {k})
    -- pos1 = {}
    -- pos2 = {}
    x = domainMin
    while x <= domainMax do
        flush(fn)
        s = sprintf("%.12e", x)
        a = ToEun(s)
        param = v[2]
        if Complex(param[1]) then
            if isRealFlag then
                param[1][REAL] = complexPart
                param[1][IMAG] = a
            else
                param[1][REAL] = a
                param[1][IMAG] = complexPart
            end if
        else
            param[1] = a
        end if
        b = call_func(v[1], param)
        if length(b) = 3 then
            if b[1] then
                b = NewComplex(NewEun(), b[2])
            else
                b = b[2]
            end if
        elsif length(b) = 2 and Complex(b[1]) and Complex(b[2]) then
            b = b[1]
        end if
        if Complex(b) then
            t = 4
        else
            t = 3
        end if
        for i = 1 to length(v[t]) do
            key = v[t][i]
            puts(1, key & ", ")
            val = map:get(p, key)
            param = val[2]
            param[1] = b
            c = call_func(val[1], param)
            if length(c) = 3 then
                if c[1] then
                    c = NewComplex(NewEun(), c[2])
                else
                    c = c[2]
                end if
            elsif length(c) = 2 and Complex(c[1]) and Complex(c[2]) then
                c = c[1]
            end if
            if Complex(c) then
                if not Complex(a) then
                    a = NewComplex(a, NewEun())
                end if
                if ComplexCompare(a, c) then
                    -- write to file
                    puts(fn, "Warning: Values are not equal.\n")
                    difference = ComplexSubtract(a, c)
                    printf(fn, "diff=[REAL]%s, [IMAG]%s,\n", {ToString(difference[REAL]), ToString(difference[IMAG])})
                    len = {length(difference[REAL][1]), length(difference[IMAG][1])} + 1
                    r = {
                        EunAdjustRound(c[1], len[1]),
                        EunAdjustRound(c[2], len[2])
                    }
                    printf(fn, "after rounding %d and %d:\n", {difference[REAL][2], difference[IMAG][2]})
                    printf(fn, " r:[REAL]%s,\n r:[IMAG]%s,\n", {ToString(r[REAL]), ToString(r[IMAG])})
                    if ComplexCompare(a, r) then
                        puts(fn, "Warning: Values are not equal after rounding.\n")
                    else
                        puts(fn, "Rounding worked: Values are equal after rounding.\n")
                    end if
                end if
                printf(fn, "%s(\n x:[REAL]%s,\n x:[IMAG]%s\n) =\n y:[REAL]%s,\n y:[IMAG]%s,\n %s(y)=\n c:[REAL]%s,\n c:[IMAG]%s\n", {k, ToString(a[1]), ToString(a[2]), ToString(b[1]), ToString(b[2]), key, ToString(c[1]), ToString(c[2])})
            else
                if EunCompare(a, c) then
                    -- write to file
                    puts(fn, "Warning: Values are not equal.\n")
                    difference = EunSubtract(a, c)
                    printf(fn, "diff=%s,\n", {ToString(difference)})
                    len = length(difference[1]) + 1
                    r = EunAdjustRound(c, len)
                    printf(fn, "after rounding %d:\n", {difference[2]})
                    printf(fn, " r:%s,\n", {ToString(r)})
                    if EunCompare(a, r) then
                        puts(fn, "Warning: Values are not equal after rounding.\n")
                    else
                        puts(fn, "Rounding worked: Values are equal after rounding.\n")
                    end if
                end if
                printf(fn, "%s(\n x:%s\n) =\n y:%s,\n %s(y)=\n c:%s\n", {k, s, ToString(b), key, ToString(c)})
            end if
            puts(fn, "\n")
        end for
        printf(1, "%s\n", {s})
        x += domainIncrement
    end while
    puts(1, "\n\n")
    return 0
end function

fn = open(dumpfile, "w")

errorCode = for_each(p, routine_id("evaluate_calculation"), 0, 1)

if not equal(errorCode, 0) then
    puts(1, "Error. In evaluate_calculation().\n")
    abort(1)
end if

close(fn)

puts(1, "\n\n")
