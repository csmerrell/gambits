stringExt = require("util/string")
jas = require("lib/provided/ja")

jaAliases = {}

for id,ja in pairs(jas) do
    if ja.prefix ~= "/pet" then
        name = string.lower(ja.en)
        jaAliases[name] = id
        
        splitSp = stringExt.split(name)
        jaAliases[stringExt.join(splitSp,"_")] = id
        jaAliases[stringExt.join(splitSp,"-")] = id
    end
end

return jaAliases