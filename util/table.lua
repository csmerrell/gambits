tableExt = require("table")
stringExt = require("util/string")

function tableExt.contains(t, val)
    for i, v in ipairs(t) do
        if v == val then return true end
    end
    return false
end

function tableExt.keyMap(t, newKey)
    result = {}
    for i,v in ipairs(t) do
        result[v.newKey] = v
    end

    return result
end

function tableExt.map(t, itemCb)
    result = {}
    for i,v in ipairs(t) do
        mapped = itemCb(v)
        result[mapped.key] = mapped.val
    end

    return result
end

function tableExt.parseTable(str)
    if type(str) == "table" then return str end
    
    t={}
    str = str:gsub('%{', '')
    str = str:gsub('%}', '')
    str = str:gsub("%s+", "")
    split = stringExt.split(str, ",")
    for i=1,#split do
        num = tonumber(split[i])
        if tableExt.contains(T{0,1,2,3,4,5}, num) then
            table.insert(t, num)
        end
    end
    return t
end

function tableExt.copy(t)
    result = {}
    for k, v in pairs(t) do
        result[k] = v
    end
    return result
end

function tableExt.iCopy(t)
    result = {}
    for i, v in ipairs(t) do
        result.insert(v)
    end
    return result
end

return tableExt