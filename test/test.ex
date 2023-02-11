-- Copyright (c) 2016-2023 James Cook
-- Eunumber, using tasks.

-- You can debug better using "USE_TASK_YIELD" like in the example below.
-- That is the only supported way to exit out of a calculation before it is done calculating.

with define USE_TASK_YIELD

-- This statement makes it run a little bit better under WINDOWS, but should only be used when benchmarking,
-- becuase it is harder to debug without sleep() statements.

ifdef LINUX then
elsedef
--with define NO_SLEEP_OPTION
end ifdef

--with define USE_OLD_CARRY

-- with trace

atom t, t0

-- include std/pretty.e
include ../eunumber/my.e

--defaultRadix = 10

-- trace(1)

useTaskYield = TRUE
--useExtraAdjustRound = FALSE -- Usually TRUE if you want to make sure you have accurate results.

defaultRadix = 1000 -- NOTE: If you change this, also change "%03d", below, as well.

type boolean(integer x)
    return Bool(x)
end type

boolean calc_running


procedure checkHowComplete()
    while 1 do
        printf(1, "expHowComplete: %d out of %d\n", expHowComplete)
        task_yield()
    end while
end procedure

object a
integer fn

procedure calc(integer len) --, integer method)
    
    task_yield()

    -- SetMultiplyMethod(method)

    -- len -= GetAdjustPrecision()
    calculationSpeed = len
    -- adjustRound = floor(len / 10)
    
    a = GetE(len)
    
    task_yield()
    
    calc_running = FALSE
end procedure

constant size = 120

puts(1, "main task: start, press \"q\" to force stop\n")

atom t1, t2, t3, t4

t1 = task_create(routine_id("checkHowComplete"), {})

sequence args = {}

for i = 100 to size by 1 do
    args = append(args, task_create(routine_id("calc"), {i})) --, MULTIPLY_METHOD_LOW_POWER_MODE}))
    --args = append(args, task_create(routine_id("calc"), {i, MULTIPLY_METHOD_OLDER_PROCESSOR_MODE}))
    --args = append(args, task_create(routine_id("calc"), {i, MULTIPLY_METHOD_POWER_HUNGRY_MODE}))
end for

integer len1, m0
atom m1 = 0 --, m2 = 0, m3 = 0

fn = open("test.txt", "w")
puts(fn, "Calculating 'E' using EuNumber's \"BigNum\" sequence calculation library:\n\n")
close(fn)

for i = 1 to length(args) do

    -- a = GetE(1, 2)
    
    t0 = time()

    task_schedule(t1, {1, 2})
    task_schedule(args[i], 1)
    
    calc_running = TRUE
    
    while calc_running do
        if get_key() = 'q' then
            abort(1/0)
        end if
        task_yield()
    end while
    
    task_suspend(t1)
    
    t = time() - t0
    
    --m0 = remainder(i, 3)
    --if m0 = 1 then
        m1 += t
    --elsif m0 = 2 then
    --    m2 += t
    --elsif m0 = 0 then
    --    m3 += t
    --end if

    pretty_print(1, a, {0, 2, 1, 78, "%03d"})
    puts(1, "\nAnswer:\n")
    len1 = length(a[1])
    a = ToString(a)
    fn = open("test.txt", "a")
    printf(fn, "%s\n", {a})
    close(fn)
    printf(1, "%s\n", {a})
    ? len1
    
    printf(1, "%f seconds\n", t)
    
    printf(1, "task(%d of %d): stop\n", {i, length(args)})
end for

puts(1, "Compare times:\n")
--printf(1, "MULTIPLY_METHOD_LOW_POWER_MODE:       %10f seconds\n", {m1})
--printf(1, "MULTIPLY_METHOD_OLDER_PROCESSOR_MODE: %10f seconds\n", {m2})
--printf(1, "MULTIPLY_METHOD_POWER_HUNGRY_MODE:    %10f seconds\n", {m3})
printf(1, "%10f seconds\n", {m1})

fn = open("test.txt", "a")
puts(fn, "Real value of 'E':\n2.7182818284590452353602874713526624977572470936999595749669676277240766303535475945713821785251664274274663919320030599218174135966290435729003342952605956307381323286279434907632338298807531952510190115738341879307021540891499348841675092447614606680822648001684774118537423454424371075390777449920695517027618386062613313845830007520449338265602976067371132007093287091274437470472306969772093101416928368190255151086574637721112523897844250569536967707854499699679468644549059879316368892300987931277361782154249992295763514822082698951936680331825288693984964651058209392398294887933203625094431173012381970684161403970198376793206832823764648042953118023287825098194558153017567173613320698112509961818815930416903515988885193458072738667385894228792284998920868058257492796104841984443634632449684875602336248270419786232090021609902353043699418491463140934317381436405462531520961836908887070167683964243781405927145635490613031072085103837505101157477041718986106873969655212671546889570350354\n\n")
close(fn)

puts(1, "done.\n")
abort(0)

-- program ends when main task is finished
