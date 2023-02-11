-- Copyright (c) 2016-2023 James Cook

public include std/console.e

--with trace
--trace(1)

integer calculating = 1

global integer DEBUG = 1


global integer was_calculating = 0

-- make it visible everywhere:
global integer useTaskYield = 0 -- FALSE or TRUE

global procedure task_check_break(integer is_abort)
    while useTaskYield do
    	puts(1, "check_break\n")
        if get_key() = 'q' or check_break() then
            was_calculating = calculating
            calculating = 0
            if is_abort then
                abort(1/0)
            else
                exit
            end if    
        end if
        task_yield()
    end while
    -- task_suspend(task_self())
end procedure

global integer euntask1 = task_create(routine_id("task_check_break"), {DEBUG})

global procedure schedule_check_break(atom t1 = 0.01, atom t2 = 0.02)
	allow_break(0)
	useTaskYield = 1
	task_schedule(euntask1, {t1, t2})
end procedure

schedule_check_break()


----

sequence st

puts(1, "Echo computer code: \n")

while calculating do
    st = prompt_string("")
    puts(1, st)
    puts(1, "\n")
    if equal(st, "exit") then
    	exit
    end if
    ? task_list()
    task_yield()
end while
