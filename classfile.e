-- Copyright (c) 2016-2021 James Cook

-- Class file

-- class data

integer baseId = 0
object free_list = {}
object privateData = {}

export function getNewId()
	integer id
	if length(free_list) then
		id = free_list[1]
		free_list = free_list[2..$]
		return id
	end if
	privateData = append(privateData, {})
	baseId += 1
	return baseId
end function

--export function find_object(object data, integer start = 1)
--	integer f
--	f = find(data, privateData, start)
--	return f
--end function

export procedure replace_object(object id, object data)
	privateData[id] = data
end procedure

public function new_object_from_data(object data)
	object id = getNewId()
	replace_object(id, data)
	return id
end function

public procedure delete_object(object id)
	privateData[id] = {}
	free_list = append(free_list, id)
end procedure

export function get_data_from_object(object id)
	return privateData[id]
end function

public procedure store_object(object id_dst, object id_src)
	replace_object(id_dst, get_data_from_object(id_src))
end procedure

public function clone_object(object id)
	object ret_id = getNewId()
	privateData[ret_id] = get_data_from_object(id)
	return ret_id
end function

