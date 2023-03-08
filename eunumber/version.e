-- Copyright (c) 2016-2023 James Cook

-- Update this version number whenever changing the library:

global function GetVersion() -- revision number
    return 259 -- completely type checked version, integer if development version.
    -- return 1.1 -- if release version.
end function

-- Tested on Win32, and OSX.

-- To do: Test all functions.

-- Try increasing the protoTargetLength when caught in an infinite loop.

--here: Make two versions, one for speed, one for accuracy.
-- work on MultiplicativeInverse.e
