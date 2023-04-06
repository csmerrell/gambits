GEO = require("lib/job/GEO")
spells = require("lib/provided/spell")

indiGambits = {}

for id,indi in pairs(GEO.indiSpells) do
    gambit = {}
    gambit.displayName = indi.name
    gambit.val = indi.spell
    gambit.minTargets = 1
    gambit.activation = ""..indi.spell.prefix.."\""..indi.spell.en.."\""

    if GEO.debuffs[indi.shortname] then
        gambit.target = "leader_engaged"
        gambit.validTarget = 35
    else
        gambit.target = "any"
        gambit.validTarget = 5
    end

    indiGambits[indi.shortname] = gambit
end

function indiGambits.expand(gambit)
    expanded = gambit
    aliased = indiGambits[gambit.name]
    if not aliased then
        gambitError.gambitNotFound(gambit)
        return nil
    else 
        for key, val in pairs(aliased) do
            if expanded[key] == nil then
                expanded[key] = val
            end
        end
        if expanded.target == "leader_engaged" then
            targetText = "Leader's (engaged)"
            expanded.displayFull = expanded.displayName.."   >   "..targetText
        end
        return expanded
    end
end

return indiGambits