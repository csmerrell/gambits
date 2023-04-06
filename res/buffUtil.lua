require("pack")

buffUtil = {}

buffUtil.partyBuffs = {}

function checkIfBuffs(id,data,modified,injected,blocked)
    if not injected and id == 0x076 then
        parseBuffs(data)
    elseif id == 0x028 then
        parsePhantomRoll(data)
    end
end

windower.register_event('incoming chunk', checkIfBuffs)

-- Load incoming party buffs into a table that gets recreated on every incoming chunk
function parseBuffs(data)
    buffUtil.partyBuffs = {}
    for i = 0,4 do
        if data:unpack('I',i*48+5) == 0 then
            break
        else
            local index = data:unpack('H',i*48+5+4)
            buffUtil.partyBuffs[index] = {}
            for n=1,32 do
                local buff_id = data:byte(i*48+5+16+n-1) + 256*( math.floor( data:byte(i*48+5+8+ math.floor((n-1)/4)) / 4^((n-1)%4) )%4)
                if buff_id ~= 255 and buff_id ~= 0 then
                    buffUtil.partyBuffs[index][buff_id] = true
                end
            end
        end
    end
end

activeRolls = {}
rolls = require("lib/provided/roll")

function parsePhantomRoll(data)
    if data:unpack('I', 6) ~= windower.ffxi.get_mob_by_target('me').id then return false end
    local category, param = data:unpack('b4b16', 11, 3)
    local effect, message = data:unpack('b17b10', 27, 6)
    if category == 6 then                       -- Use Job Ability
        if message == 420 then                  -- Phantom Roll
            activeRolls[rolls[param].buffId] = effect
            activeRolls[308] = rolls[param].buffId
        elseif message == 424 then              -- Double-Up
            activeRolls[rolls[param].buffId] = effect
            activeRolls[308] = rolls[param].buffId
        elseif message == 426 then              -- Bust
            activeRolls[rolls[param].buffId] = nil
        end
    end
end

function buffUtil.getBuffs()
    pl = windower.ffxi.get_player()
    selfIdx = pl.index
    selfBuffs = pl.buffs
    buffUtil.partyBuffs[selfIdx] = {}
    for i, buffId in ipairs(selfBuffs) do
        if activeRolls[buffId] then
            buffUtil.partyBuffs[selfIdx][buffId] = activeRolls[buffId]
        else
            buffUtil.partyBuffs[selfIdx][buffId] = true
        end
    end

    return buffUtil.partyBuffs
end

return buffUtil