-- Copyright (c) 2016-2023 James Cook

-- Class file

namespace classfile

-- class data

export object table = 0
export object freeList = {}
export object privateData = {}

export constant TABLE = 1, FREELIST = 2, PRIVATEDATA = 3

export type table_t(sequence s)
    if length(s) = 3 then
        if sequence(s[PRIVATEDATA]) then
            sequence tmp = s[FREELIST]
            if sequence(tmp) then
                for i = 1 to length(tmp) do
                    if not integer(tmp[i])
                        or tmp[i] < 1
                        or tmp[i] > length(s[PRIVATEDATA])
                    then
                        return 0
                    end if
                end for
                return 1
            end if
        end if
    end if
    return 0
end type

export function NewTable(object tableId)
    -- Use with SwapTable()
    sequence t = repeat({}, 3)
    t[TABLE] = tableId
    -- t[FREELIST] = {}
    -- t[PRIVATEDATA] = {}
    return t
end function

export function GetTableData()
    sequence s = repeat(0, 3)
    s[TABLE] = table
    s[FREELIST] = freeList
    s[PRIVATEDATA] = privateData
    return s
end function

export function SwapTable(sequence x = GetTableData())
    sequence tmp = GetTableData()
    table = x[TABLE]
    freeList = x[FREELIST]
    privateData = x[PRIVATEDATA]
    return tmp
end function

export function GetTableId()
    return table
end function

-- New idea (for future versions of classfile.e):

-- d = { {id, data}, {id, data}, ... }
-- sorted.
-- recent = { ids, datas }
-- 100 or less in recent.
-- recent has one list for ids, another list for datas.
-- 1) Use recent list, until space gets used up.
-- 2) Use sorted d list, for more values.

export function GetNewId(object data = {})
    if length(freeList) then
        integer id
        id = freeList[1]
        freeList = freeList[2..$]
        if length(data) then
            privateData[id] = data
        end if
        return id
    else
        privateData = append(privateData, data)
        return length(privateData)
    end if
end function

export function GetLengthOfObject(integer id)
    return length(privateData[id])
end function

export procedure ReplaceObject(integer id, object data, object index = {}, integer isfill = 0, object fill = 0)
ifdef EXTRA_CHECK_CLASSFILE then
    if equal(data, {}) then -- {} could be uninitialized data
        abort(1/0)
    end if
end ifdef
    integer f
    f = find(id, freeList)
    if f then
        -- remove from freeList
        freeList = freeList[1..f - 1] & freeList[f + 1..$]
    end if
    if equal(index, {}) then
        privateData[id] = data
    else
        if isfill then
            integer len = GetLengthOfObject(id)
            if index > len then
                privateData[id] &= repeat(fill, index - len)
            end if
        end if
        privateData[id][index] = data -- Euphoria uses syntax checking
    end if
end procedure

export function NewObjectFromData(object data)
ifdef EXTRA_CHECK_CLASSFILE then
    if equal(data, {}) then -- {} could be uninitialized data
        return 0 -- function fails, couldn't store uninitialized data
    end if
end ifdef
    integer id = GetNewId(data)
    return id
end function

export function GetDataFromObject(integer id, object index = {})
    if equal(index, {}) then
        return privateData[id]
    end if
    return privateData[id][index]
end function

-- Integer only functions:

export procedure DeleteObject(integer id)
    if not find(id, freeList) then
        freeList = prepend(freeList, id)
        privateData[id] = {}
    end if
end procedure

export procedure StoreObject(integer idDst, integer idSrc)
    ReplaceObject(idDst, privateData[idSrc])
end procedure

export function NewObjectFromId(integer id)
    integer retId = NewObjectFromData(privateData[id])
    --integer retId = GetNewId(privateData[id])
    -- StoreObject(retId, id)
    -- privateData[retId] = privateData[id]
    return retId
end function


-- End of file.
