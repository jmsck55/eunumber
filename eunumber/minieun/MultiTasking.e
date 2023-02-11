-- Copyright (c) 2016-2023 James Cook
-- multitasking support for EuNumber.
-- include eunumber/multitasking.e

--with define USE_TASK_YIELD

-- MultiTasking support:

-- Use in your program:

-- ifdef USE_TASK_YIELD then
--     if useTaskYield then
--         task_yield()
--     end if
-- end ifdef

ifdef WITHOUT_TRACE then
without trace
end ifdef

ifdef USE_TASK_YIELD then

    public include std/console.e
    include common.e
    include returntouser.e

    -- make it visible everywhere:
    global integer useTaskYield = FALSE -- FALSE or TRUE

    global procedure task_check_break(integer is_abort)
        integer count = 0
        while useTaskYield do
ifdef DEBUG_TASK then
                if count = 10 then
                    count = 1
                else
                    count += 1
                end if
                printf(1, "check_break: %d\n", count)
end ifdef
            if get_key() = 'q' or check_break() then
                abort_calculating = 1
                if is_abort then
                    abort(1/0)
                else
                    exit
                end if    
            end if
            task_yield()
        end while
    end procedure    

    global integer euntask1 = task_create(routine_id("task_check_break"), {TRUE})
    global integer euntask2 = task_create(routine_id("task_check_break"), {FALSE})

    global procedure schedule_check_break(atom t1 = 1, atom t2 = 2, integer debug_task = 1)
        allow_break(0)
        useTaskYield = 1
        if debug_task then
            task_schedule(euntask1, {t1, t2})
        else
            task_schedule(euntask2, {t1, t2})
        end if
    end procedure

ifdef DEBUG_TASK then
        schedule_check_break()
end ifdef

end ifdef

