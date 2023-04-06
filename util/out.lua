out = {}

function out.msg(m)
    windower.add_to_chat(121, m)
end

function out.stringifyBool(b)
    if b then return "true" end
    return "false"
end

function out.logTable(t)
    print(out.stringifyTable(t, false))
end

function out.logKeys(t)
    print(out.stringifyTable(t, true))
end

function out.stringifyTable(t, onlyKeys)
    if type(t) == 'table' then
        local s = '{ '
        for k,v in pairs(t) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            if onlyKeys then
                s = s .. '['..k..'],'
            else
                s = s .. '['..k..'] = ' .. out.stringifyTable(v) .. ', '
            end
        end
        return s .. '} '
    else
        return tostring(t)
    end
end

function out.stringifyTableLite(t)
    if type(t) == 'table' then
        local s = '{ '
        for k,v in pairs(t) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s ..out.stringifyTable(v).. ', '
        end
        return s .. '} '
    else
        return tostring(t)
    end
end

return out