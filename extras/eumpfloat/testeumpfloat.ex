-- Copyright (c) 2022 James Cook

include std/console.e

with trace

trace(1)

include eumpfloat.e

constant config_float64 = get_float_config()

eumpfloat fa, fb

object a, b, c, d
sequence tdouble, rdouble -- strings
sequence tbytes, rbytes

tdouble = 1.0

while tdouble != 0.0 do

    tdouble = prompt_string("Enter a double floating point number, or zero (0) to exit:\n")
    
    --tbytes = atom_to_float64(tdouble) --here
    fa = StringToFloat(tdouble, config_float64)
    --fa = BytesToFloat(tbytes, config_float64)
    
    ? fa
    
    rdouble = FloatToString(fa)
    --rbytes = FloatToBytes(fa)
    
    --if equal(rbytes, tbytes) then
    --    puts(1, "Success, results are equal.\n")
    --end if
    
    --rdouble = float64_to_atom(rbytes)
    
    printf(1, "%s\n", tdouble)
    printf(1, "%s\n", rdouble)
    --printf(1, "%.22e\n", tdouble)
    --printf(1, "%.22e\n", rdouble)

end while

puts(1, "End of Test.\nDone.\n")

