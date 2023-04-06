stringExt = {}

function stringExt.split(str, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for s in string.gmatch(str, "([^"..sep.."]+)") do
        table.insert(t, s)
    end
    return t
end

function stringExt.join(arr, sep)
    result = ""
    for i, str in ipairs(arr) do
        if i == 1 then
            result = str
        else
            result = result..sep..str
        end
    end
    return result
end

function stringExt.mapNumeral(str)
    if str == "ii" then
        return "2"
    elseif str == "iii" then
        return "3"
    elseif str == "iv" then
        return "4"
    elseif str == "v" then
        return "5"
    elseif str == "vi" then
        return "6"
    else
        return nil
    end
end

return stringExt