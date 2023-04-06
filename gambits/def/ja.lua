jas = require("lib/provided/ja")
jaAliases = require("lib/alias/ja")

jaGambits = {}

for id, ja in pairs(jas) do
    gambit = {}
    gambit.displayName = ja.en
    gambit.val = ja
    gambit.target = "self"
    gambit.activation = "/ja \""..ja.en.."\" <me>"

    jaGambits[id] = gambit
end

function jaGambits.expand(gambit)
    expanded = gambit
    aliased = jaGambits[jaAliases[gambit.name]]
    if not aliased then
        gambitError.gambitNotFound(gambit)
        return nil
    else 
        for key, val in pairs(aliased) do
            if expanded[key] == nil then
                expanded[key] = val
            end
        end
        if gambit.type == "ja_buff" then
            expanded.validTargets = T{"any", "self", "all", "table"}
        end
        return expanded
    end
end

return jaGambits