-- Copyright (c) 2023 James Cook
-- convertfiles.ex

-- Find and Replace All replacements, in order to All Files in one Folder with or without subdirectories.

-- It can:
-- Convert all spaces to tabs in files in all subdirectories.
-- Changes line endings to system default.
-- Replace multiple search parameters, in order from first to last.
-- Show replacement statistics.

-- Replacement happens immediately, without prompting the user.

include std/filesys.e
include std/io.e
include std/pretty.e
--include std/search.e

constant TRUE = 1, FALSE = 0

---- User modifiable variables:

constant directory = "." -- "eunumber"
constant doSubdirectories = TRUE

constant fileExts = {"e", "ex"}

constant tabsize = 4 -- could be 2, 4, or 8
constant tabs = repeat(' ', tabsize)
constant tab = "\t"

constant myfind_replace = {
    -- In the format:
    -- {find what, replace with}
    {tab, tabs},
    --{"public ", "global "},
    --{"global include", "public include"}

    --{"addexp.e", "AddExp.e"},
    --{"adjustround.e", "AdjustRound.e"},
    --{"convertexp.e", "ConvertExp.e"},
    --{"divide.e", "Divide.e"},
    --{"eun.e", "Eun.e"},
    --{"eunrnd.e", "eunrandom.e"},
    --{"multiplicativeinverse.e", "MultiplicativeInverse.e"},
    --{"multiply.e", "Multiply.e"},
    --{"prettyprint.e", "pretty_print.e"},
    --{"toatom.e", "ToAtom.e"},
    --{"toeun.e", "ToEun.e"},
    --{"tostring.e", "ToString.e"},
    --{"tostringdecimal.e", "ToStringDecimal.e"},
    --{"toEun.e", "ToEun.e"},
    $
}


printf(1, "Directory: %s\n", {directory})
printf(1, "Include Subdirectories (0 for no, 1 for yes): %d\n", doSubdirectories)
puts(1, "Find, and Replace All:\n")

pretty_print(1, myfind_replace, {2})
puts(1, "\n\n")

---- End User modifiable variables.

integer oldchars = 0, nchars = 0, nlines = 0, nfiles = 0, ndirectories = 0
sequence nums, nreplacements = repeat(0, length(myfind_replace))

-- Begin custom "match_replace()"
public function match_replace_n(object needle, sequence haystack, object replacement, 
            integer max=0)
    integer posn
    integer needle_len
    integer replacement_len
    integer scan_from
    integer cnt
    integer jc = 0
    
    if max < 0 then
        return {haystack, jc}
    end if
    
    cnt = length(haystack)
    if max != 0 then
        cnt = max
    end if
    
    if atom(needle) then
        needle = {needle}
    end if
    if atom(replacement) then
        replacement = {replacement}
    end if

    needle_len = length(needle) - 1
    replacement_len = length(replacement)

    scan_from = 1
    while posn with entry do
        haystack = replace(haystack, replacement, posn, posn + needle_len)
        jc += 1
        cnt -= 1
        if cnt = 0 then
            exit
        end if
        scan_from = posn + replacement_len
    entry
        posn = match(needle, haystack, scan_from)
    end while

    return {haystack, jc}
end function

-- End custom "match_replace()"

----------------
-- convertline()
----------------

integer file_unchanged -- flag for unchanged file.

function convertline(sequence line)
    object needle, replacement

    oldchars += length(line)
    
    for i = 1 to length(myfind_replace) do

        needle = myfind_replace[i][1]
        replacement = myfind_replace[i][2]
        line = match_replace_n(needle, line, replacement)
        if file_unchanged then
            if line[2] then
                file_unchanged = 0
            end if
        end if
        nums[i] += line[2]
        line = line[1]

    end for
    
    nchars += length(line)
    
    return line
end function

----------------
-- convertfile()
----------------

function convertfile(sequence path_name, sequence item)
    sequence line, filename = path_name & SLASH & item[D_NAME]
    object lines
    
    file_unchanged = 1

    if find('d', item[D_ATTRIBUTES]) then
        if find('s', item[D_ATTRIBUTES]) then
            return W_SKIP_DIRECTORY -- skip system directories
        else
            ndirectories += 1
            return 0 -- keep going
        end if
    end if
    if not find(fileext(item[D_NAME]), fileExts) then
        return 0 -- ignore non-Euphoria files
    end if

    nfiles += 1
    printf(1, "\"%s\"", {filename})
    
    lines = read_lines(filename)
    if atom(lines) then
        puts(1, " -- couldn't read file\n")
        return 0
    end if
    
    -- process lines in file
    
    nums = repeat(0, length(myfind_replace))
    for i = 1 to length(lines) do
        line = lines[i]
        
        nlines += 1
        line = convertline(line)
        
        lines[i] = line
    end for
    
    if not file_unchanged then
        lines = write_lines(filename, lines)
        if lines = -1 then
            puts(1, " -- couldn't write file\n")
            return 0
        end if
    end if
    
    puts(1, " ")
    ? nums
    nreplacements += nums
    return 0
end function

---------------
-- Code begins:
---------------

puts(1, "Processing files.\n\n")

printf(1, "\nwalk_dir returned: %d\n",
    walk_dir(directory, routine_id("convertfile"), doSubdirectories) -- TRUE to process subdirectories
    )

printf(1, "number of directories: %d\n", ndirectories)
printf(1, "number of files: %d\n", nfiles)
printf(1, "number of lines: %d\n", nlines)
printf(1, "old char count: %d\n", oldchars)
printf(1, "new char count: %d\n", nchars)
puts(1, "totals or numbers of replacements:\n")
? nreplacements

puts(1, "\n")

