-- Copyright (c) 2023 James Cook
-- This code tests Exp() and Log() functions of EuNumber.


include std/get.e
include std/console.e

with trace

with define USE_TASK_YIELD
--with define DEBUG_TASK

include ../eunumber/my.e

isRoundToZero = TRUE

schedule_check_break()

constant complexExpId = routine_id("ComplexExp")

function AllExp(object x)
    return x
end function

function AllLog(object x)
    return x
end function

sequence funcs = {
    --{"function", routineId, {-999, NewEun()}},
--    {"EunAdd", -999, {-999, -999}, {"EunSubtract"}},
--    {"EunSubtract", -999, {-999, -999}, {"EunAdd"}},
    {"EunMultiplicativeInverse", -999, {-999, {}}, {"EunMultiplicativeInverse"}},
--    {"EunMultiply", -999, {-999, -999}, {"EunDivide"}},
--    {"EunDivide", -999, {-999, -999}, {"EunMultiply"}},
    {"AllLog", -999, {-999}, {"EunLog", "EunLog1"}},
    {"EunLog", -999, {-999}, {"EunExp"}, "ComplexExp", complexExpId},
    {"EunLog1", -999, {-999}, {"EunExp"}, "ComplexExp", complexExpId},
    {"AllExp", -999, {-999},  {"EunExp", "EunExpA", "EunExpB", "EunExpC", "EunExp1", "EunExp1A"}},
    {"EunExpA", -999, {-999}, {"EunLog"}},
    {"EunExp", -999, {-999}, {"EunLog"}},
    {"EunExp1", -999, {-999}, {"EunLog"}},
    --{"EunExpFast", -999, {-999, NewEun({1})}, {"EunLog"}},
    {"EunExpB", -999, {-999}, {"EunLog"}},
    {"EunExpC", -999, {-999}, {"EunLog"}},
    {"EunExp1A", -999, {-999}, {"EunLog"}},
    --{"EunExpFast1", -999, {-999}, {"EunLog"}},
    --{"EunExpFastA", -999, {-999}, {"EunLog"}},
    {"EunSquared", -999, {-999}, {"EunSquareRoot"}},
    {"EunSquareRoot", -999, {-999, 0}, {"EunSquared"}, "ComplexSquared", routine_id("ComplexSquared")},
    
--    {"EunPower", -999, {-999, -999}, {"EunGeneralRoot"}},
--    {"EunGeneralRoot", -999, {-999}, {"EunPower"}},
    $
}

realMode = FALSE

object a, b, c, d, var, func, arg

for i = 1 to length(funcs) do
    funcs[i][2] = routine_id(funcs[i][1])
end for    

function prompt()
    puts(1, "Enter a number:\n")
    for i = 1 to length(funcs) do
        printf(1, " %d for %s\n", {i, funcs[i][1]})
    end for    
    func = prompt_number("> ", {1, length(funcs)})
    printf(1, "Enter a number to test %s,\n", {funcs[func][1]})
    puts(1, " with or without quotation marks, or as an Eun.\n")
    puts(1, "Or, Enter {} or \"\" or an invalid text, like \"exit\" to quit.\n")
    return func
end function


while 1 do
    func = prompt()

    var = get(0)
    if var[1] != GET_SUCCESS or length(var[2]) = 0 then
        puts(1, "Quiting.\n")
        abort(0)
    end if
    var = var[2]

    if atom(var) then
        var = sprintf("%e", var)
    end if
    if Eun(var) then
        a = var
    else
        a = ToEun(var)
    end if

    puts(1, "Input:\n")
    ? a
    printf(1, "%s\n", {ToString(a)})

    puts(1, "------------\n")
    puts(1, "Calculating:\n")
    puts(1, "------------\n")
    arg = funcs[func][3]
    arg[1] = a
    c = call_func(funcs[func][2], arg)
    ? c
    if length(c) = 3 then
        if c[1] then
            c = NewComplex(NewEun(), c[2])
        else
            c = c[2]
        end if
    end if
    if Complex(c) then
        printf(1, "%s\n", {ToString(c[1])})
        printf(1, "i * %s\n", {ToString(c[2])})
    else
        printf(1, "%s\n", {ToString(c)})
    end if
--trace(1)
    puts(1, "Verifying the validity:\n")
    if Complex(c) then
        d = funcs[func][5]
        printf(1, "%s\n", {d})
        b = call_func(funcs[func][6], {c})
        puts(1, ToString(b[1]) & "\n")
        puts(1, ToString(b[2]) & " * i\n")
        b = {b}
    else
        d = funcs[func][4]
        b = repeat(0, length(d))
        for i = 1 to length(d) do
            for j = 1 to length(funcs) do
                if equal(d[i], funcs[j][1]) then
                    d[i] = funcs[j]
                end if
            end for
            printf(1, "%s\n", {d[i][1]})
            arg = d[i][3]
            arg[1] = c
            var = call_func(d[i][2], arg)
            if length(var) = 3 then
                if var[1] then
                    var = NewComplex(NewEun(), var[2])
                else
                    var = var[2]
                end if
            end if
            puts(1, ToString(var) & "\n")
            b[i] = var
        end for
    end if
    if Complex(b[1]) then
        object z
        printf(1, "%s\n", {ToString(b[1][1])})
        printf(1, "i * %s\n", {ToString(b[1][2])})
        if Complex(a) then
            z = a
        else
            z = NewComplex(a, NewEun())
        end if
        if ComplexCompare(z, b[1]) = 0 then
            printf(1, "z and \"%s\" are equal.\n", {d})
        else
            printf(1, "z and \"%s\" are not equal.\n", {d})
            puts(1, "difference:\n")
            isRoundToZero = FALSE
            c = ComplexSubtract(z, b[1])
            isRoundToZero = TRUE
            ? c
            printf(1, "%s\n", {ToString(c[1])})
            printf(1, "i * %s\n", {ToString(c[2])})
            puts(1, "after rounding:\n")
            c[1] = EunRoundLastDigits(b[1][1], length(c[REAL][1]))
            c[2] = EunRoundLastDigits(b[1][2], length(c[IMAG][1]))
            ? c
            printf(1, "%s\n", {ToString(c[1])})
            printf(1, "i * %s\n", {ToString(c[2])})
            if ComplexCompare(z, c) = 0 then
                puts(1, "a and c are equal.\n")
            else
                puts(1, "a and c are not equal.\n")
            end if
        end if
    else
        for i = 1 to length(b) do
            printf(1, "%s\n", {ToString(b[i])})
            if EunCompare(a, b[i]) = 0 then
                printf(1, "a and \"%s\" are equal.\n", {d[i][1]})
            else
                printf(1, "a and \"%s\" are not equal.\n", {d[i][1]})
                puts(1, "difference:\n")
                isRoundToZero = FALSE
                c = EunSubtract(a, b[i])
                isRoundToZero = TRUE
                ? c
                printf(1, "%s\n", {ToString(c)})
                puts(1, "after rounding:\n")
                c = EunRoundLastDigits(b[i], length(c[1]) + 1)
                ? c
                printf(1, "%s\n", {ToString(c)})
                if EunCompare(a, c) = 0 then
                    puts(1, "a and c are equal.\n")
                else
                    puts(1, "a and c are not equal.\n")
                end if
            end if
        end for
    end if
    
end while

