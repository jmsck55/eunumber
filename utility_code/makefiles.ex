-- Copyright (c) 2016-2023 James Cook

with trace
trace(1)

constant infile = "makefiles.txt"

constant format = "-- Copyright (c) 2016-2023 James Cook\n\n\n"

integer fn, outfn, num

fn = open(infile, "r")

object line

puts(1, "Processing:\n")

num = 0

while 1 do
    line = gets(fn)
    if atom(line) then
        exit
    end if
    if length(line) and line[$] = '\n' then
        line = line[1..$-1]
    end if
    if length(line) = 0 then
        continue
    end if
    if 1 != match("--", line) then
        num += 1
        printf(1, "%d: %s\n", {num, line})
        outfn = open(line & ".e", "w")
        puts(outfn, format)
        close(outfn)
    end if
end while

close(fn)

