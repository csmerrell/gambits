spells = require("lib/provided/spell")
spellAliases = require("lib/alias/spell")

spellGambits = {}
for id,spell in pairs(spells) do
    gambit = {}
    gambit.displayName = spell.en
    gambit.val = spell
    gambit.target = "any"
    gambit.focus = "single"
    gambit.activation = ""..spell.prefix.."\""..spell.en.."\""

    spellGambits[spell.id] = gambit
end

function spellGambits.expand(gambit)
    expanded = gambit
    aliased = spellGambits[spellAliases[gambit.name]]
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
        if expanded.focus == "multiple" then
            expanded.displayName = expanded.displayName.." (aoe)"
        end
        expanded.validTargets = T{"any", "all", "self", "table"}
        return expanded
    end
end

return spellGambits