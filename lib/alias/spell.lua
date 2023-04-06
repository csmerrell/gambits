stringExt = require("util/string")
spells = require("lib/provided/spell")

spellAliases = {}
for id,spell in pairs(spells) do
    name = string.lower(spell.en)
    spellAliases[name] = id
    
    splitSp = stringExt.split(name)
    if stringExt.mapNumeral(splitSp[2]) ~= nil then
        spellAliases[splitSp[1]..stringExt.mapNumeral(splitSp[2])] = id
    end

    spellAliases[stringExt.join(splitSp,"_")] = id
    spellAliases[stringExt.join(splitSp,"-")] = id
end

return spellAliases