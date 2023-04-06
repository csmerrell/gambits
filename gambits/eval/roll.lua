COR = require("lib/job/cor")
cd = require("util/cooldown")

local cond = {}

function cond.phantomRollCD()
    return cd.abilityReady(COR.rollRecastId)
end

function cond.shouldFold()
    return cond.hasBust() and cd.abilityReady(COR.foldRecastId)
end

function cond.hasBust()
    return selfBuffs[COR.bustBuffId]
end

function cond.shouldRoll(die)
    if selfBuffs[COR.bustBuffId] and not cond.isPriorityRoll(die) then
        return false
    else
        return not selfBuffs[die.buffId]
    end
end

function cond.hasXI()
    for id, die in pairs(COR.rolls) do
        if selfBuffs[die.buffId] == 11 then
            return true
        end
    end
    return false
end

function cond.shouldDoubleUp(die)
    if selfBuffs[die.buffId] == nil then return false end
    
    -- If the buff value is a boolean, it means the gambits 
    --   addon was reloaded and can't retrieve current rolls value.
    --   Wait until the next the next rolls happen.
    if selfBuffs[die.buffId] == true then return false end

    if not cd.abilityReady(COR.doubleUpRecastId) then
        return false
    elseif selfBuffs[COR.doubleUpBuffId] == nil or selfBuffs[COR.doubleUpBuffId] ~= die.buffId then 
        return false
    elseif cond.hasXI() and selfBuffs[die.buffId] ~= 11 then 
        return true
    elseif selfBuffs[die.buffId] == die.lucky then
        return false
    elseif selfBuffs[die.buffId] <= 6 then
        return true
    elseif cond.shouldSnakeEye(die) then
        return true
    elseif selfBuffs[die.buffId] == die.unlucky then 
        return selfBuffs[die.buffId] <= 7
    end

    return false
end

function cond.shouldSnakeEye(die)
    if not cd.abilityReady(COR.snakeEyeRecastId) then return false end

    return selfBuffs[die.buffId] == 10 or selfBuffs[die.buffId] == die.unlucky
end

function cond.isPriorityRoll(die)
    for i, gambit in ipairs(activeGambits) do
        if gambit.evalType == "roll" then
            -- If the first roll gambit in the activeGambits list is the selected one, then it's the higher priority of the two.
            return gambit.val.id == die.id
        end
    end
    return false
end

typeEval.roll = {}
selfBuffs = {}
player = nil
function typeEval.roll.eval(gambit)
    player = windower.ffxi.get_party()['p0']
    selfBuffs = buffUtil.getBuffs()[player.mob.index]
    if cond.shouldFold() then
        windower.chat.input("/ja Fold <me>")
        return tick.jaDelay
    end

    if cond.shouldDoubleUp(gambit.val) then
        if cond.shouldSnakeEye(gambit.val) and not selfBuffs[COR.snakeEyeBuffId] then
            windower.chat.input("/ja \"Snake Eye\" <me>")
            return tick.jaDelay
        else
            windower.chat.input("/ja Double-Up <me>")
            return tick.jaDelay
        end
    end

    if not cd.abilityReady(COR.rollRecastId) then return 0 end

    if cond.shouldRoll(gambit.val) then
        windower.chat.input(gambit.activation)
        return tick.jaDelay
    end

    return 0
end