buffIdList = require("lib/provided/buff")

buffs = {}

buffs.idMap = {}

for id,buff in pairs(buffIdList) do
    buffs.idMap[buff.en] = id
end

function buffs.details(id)
    return buffIdList[id]
end

return buffs