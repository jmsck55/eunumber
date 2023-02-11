

include eunumber/eun/minieun/FindIter.e

include std/rand.e

set_rand(1)


with trace

object iter, half, confidence, isExit

iter = 4
half = 0
confidence = 0

sequence s

constant target = rand(repeat(100, 50)) + 4

--trace(1)

s = {iter, half, confidence}

for i = 1 to 50 do
    while 1 do
        isExit = s[1] >= target[i]
        printf(1, "%d, ", isExit)
        printf(1, "%d,", target[i])
        ? s
        --trace(1)
        s = FindIter(isExit, s, 4, 1024)
        if isExit then
            exit
        end if
    end while
end for

puts(1, "The End.\n")
