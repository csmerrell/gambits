stringExt = require("util/string")
weaponSkills = require("lib/provided/ws")

wsAliases = {}

for id,ws in pairs(weaponSkills) do
    name = string.lower(ws.en)
    wsAliases[name] = id
    
    splitSp = stringExt.split(name)
    wsAliases[stringExt.join(splitSp,"_")] = id
    wsAliases[stringExt.join(splitSp,"-")] = id


    name = name:gsub("'", "")    
    splitSp = stringExt.split(name)
    wsAliases[stringExt.join(splitSp,"_")] = id
    wsAliases[stringExt.join(splitSp,"-")] = id
end

return wsAliases