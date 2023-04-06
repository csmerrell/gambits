stringExt = require("util/string")
rolls = require("lib/provided/roll")

rollAliases = {}

for id,roll in pairs(rolls) do
    splitApo = stringExt.split(roll.en, '\'')
    if splitApo ~= roll.en then
        rollAliases[string.lower(splitApo[1])] = id
    end

    splitSp = stringExt.split(roll.en)
    rollAliases[string.lower(splitSp[1])] = id

    if roll.job then
        rollAliases[string.lower(roll.job)] = id
    end

    rollAliases[string.lower(roll.en)] = id
end

return rollAliases