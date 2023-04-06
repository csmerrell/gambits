weaponSkills = require("lib/provided/ws")
wsAliases = require("lib/alias/ws")

wsGambits = {}

for id, ws in pairs(weaponSkills) do
    gambit = {}
    gambit.displayName = ws.en
    gambit.val = ws
    gambit.target = "t"
    gambit.behavior = "burn"
    gambit.tpThreshold = 1000
    gambit.activation = "/ws \""..ws.en.."\" <t>"

    wsGambits[id] = gambit
end

function wsGambits.expand(gambit)
    expanded = gambit
    aliased = wsGambits[wsAliases[gambit.name]]
    if not aliased then
        gambitError.gambitNotFound(gambit)
        return nil
    else 
        for key, val in pairs(aliased) do
            if expanded[key] == nil then
                expanded[key] = val
            end
        end
        return expanded
    end
end

return wsGambits