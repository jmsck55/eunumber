-- Copyright (c) 2016-2023 James Cook
-- reverse function for EuNumber.
-- include eunumber/reverse.e

namespace reverse

global function reverse(sequence s)
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
