GEO = require("lib/job/GEO")
spells = require("lib/provided/spell")

geoGambits = {}
for id,geo in pairs(GEO.geoSpells) do
    gambit = {}
    gambit.displayName = geo.name
    gambit.val = geo.spell
    gambit.activation = ""..geo.spell.prefix.."\""..geo.spell.en.."\""

    if GEO.debuffs[geo.shortname] then
        gambit.geoType = "debuff"
        gambit.target = "leader_engaged"
        gambit.validTarget = 35
    else
        gambit.geoType = "buff"
        gambit.target = "any"
        gambit.validTarget = 5
    end


    geoGambits[geo.shortname] = gambit
end

function geoGambits.expand(gambit)
    expanded = gambit
    aliased = geoGambits[gambit.name]
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

return geoGambits