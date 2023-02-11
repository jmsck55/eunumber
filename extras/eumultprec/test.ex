-- Copyright (c) 2023 James Cook

-- Test EuMultPrec.e

with trace

--with define USE_DECIMAL

include EuMultPrec.e

trace(1)

sequence a, b, c, d
sequence config

-- set_base(10)
set_prec(1024)
config = get_config()

constant numerator = config[MAX_LIMB]
constant divide_by = 23

a = {0, repeat(numerator, 1)}
b = {0, {divide_by}}
--b[1] = -1

-- c = add_limb_exp(a, 2, b, 3)

c = divide_exp(a, 0, b, 0, {0, {floor(config[MAX_LIMB] / divide_by)}})

? a
? b
? c
? mi_count

d = c[2][2]

for i = length(d) to 1 by -1 do
    printf(1, "%08d", {d[i]})
end for

puts(1, "\n\n")

? mi_count
printf(1, "%.15g\n", {numerator / divide_by})

-- puts(1, "Put test code here...\n")
