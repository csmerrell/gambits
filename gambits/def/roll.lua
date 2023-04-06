rolls = require("lib/provided/roll")
rollAliases = require("lib/alias/roll")

rollGambits = {}

for id, die in pairs(rolls) do
    gambit = {}
    gambit.displayName = die.en
    gambit.val = die
    gambit.target = "any"
    gambit.activation = "/ja \""..die.en.."\" <me>"

    rollGambits[id] = gambit
end

function rollGambits.expand(gambit)
    expanded = gambit
    aliased = rollGambits[rollAliases[gambit.name]]
    if not aliased then
        gambitError.gambitNotFound(gambit)
        return nil
    else 
        for key, val in pairs(aliased) do
            if expanded[key] == nil then
                expanded[key] = val
            end
        end
        expanded.validTargets = T{"any", "all", "self", "table"}
        return expanded
    end
end

return rollGambits