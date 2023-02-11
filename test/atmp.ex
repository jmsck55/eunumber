-- Copyright (c) 2016-2023 James Cook

include ../eunumber/my.e

--with trace
--trace(1)

object a, b, c, d

while 1 do
    puts(1, "Enter a number, or press enter to continue: ")
    a = gets(0)
    puts(1, "\n")
    if equal(a, "\n") then
        exit
    end if
    a = a[1..$-1]
    b = ToEun(a)
    c = ToString(b, 1)
    printf(1, "Scientific: %s\n", {c})
    d = ToStringDecimal(c)
    printf(1, "Decimal: %s\n", {d})
end while

puts(1, "\n\n")

--ifdef BIT64 then
--constant prec = 64
--elsedef
constant prec = 53 -- 53 - 3
--end ifdef

a = 1 + (1 / power(2, prec - 1))
b = 1 - (1 / power(2, prec - 1))

? a
? b

printf(1, "%.60f\n", a)
printf(1, "%.60f\n", b)

puts(1, "\n")

for i = -1 to 55 do -- "i" should be 3 or 4

c = RoundFloat(a, i)
d = RoundFloat(b, i)

printf(1, "%02d %.60f\n", {i, c})
printf(1, "%02d %.60f\n", {i, d})

end for

puts(1, "\nDone.\n")
