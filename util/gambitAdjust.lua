table = require("util/table")

function gambitAdjust(gambit, newProps)
    result = table.copy(gambit)
    for key, val in pairs(newProps) do
        result[key] = val
    end
    return result
end

return gambitAdjust