validTargets = {}

validTargets.ids = {
    [1] = "Self",
    [5] = "Party",
    [29] = "PC",
    [32] = "Enemy",
    [63] = "All",
    [157] = "Dead",
}

function validTargets.isValid(targetTypeId, target)
    if targetTypeId ~= 157 and target.hpp == 0 then return false end
    
    if targetTypeId == 1 then return validTargets.isSelf(target) end
    if targetTypeId == 5 then return validTargets.isParty(target) end
    if targetTypeId == 29 then return validTargets.isPC(target) end
    if targetTypeId == 32 then return validTargets.isEnemy(target) end
    if targetTypeId == 63 then return validTargets.isAll(target) end
    if targetTypeId == 157 then return validTargets.isDead(target) end
end

function validTargets.mobType(target)
    if windower.ffxi.get_player().id == target.id then
        return 'SELF'
    elseif target.is_npc then
        if target.id%4096>2047 then
            return 'NPC'
        else
            return 'MONSTER'
        end
    else
        return 'PC'
    end
end

function validTargets.isSelf(target)
    return validTargets.mobType(target) == "SELF" and not target.charmed
end

function validTargets.isParty(target)
    party = windower.ffxi.get_party()
    for i=0,5 do
        if party['p'..i].mob and party['p'..i].mob.id == target.id and not party['p'..i].charmed then
            return true
        end
    end
    return false
end

function validTargets.isPC(target)
    return validTargets.isParty(target) or (validTargets.mobType(target) == "PC" and not target.charmed)
end

function validTargets.isAll(target)
    return target.hpp ~= 0 and not target.charmed
end

function validTargets.isEnemy(target)
    return validTargets.mobType(target) == "MONSTER" or target.charmed
end

function validTargets.isDead(target)
    return target.hp == 0
end

return validTargets