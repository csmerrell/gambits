local lightArtsBuffId = 358
local lightArtsRecastId = 228
local accessionBuffId = 366

function tryAccession()
    local no_buff_result = {
        hasBuff = false,
        cooldown = 0
    }
    
    local buff_progress_result = {
        hasBuff = false,
        cooldown = tick.jaDelay
    }
    
    local has_buff_result = {
        hasBuff = true,
        cooldown = 0
    }

    pl = windower.ffxi.get_player()
    if pl.sub_job ~= "SCH" then return no_buff_result end

    selfBuffs = buffUtil.getBuffs()[pl.index]
    if selfBuffs[accessionBuffId] then return has_buff_result end

    if not selfBuffs[lightArtsBuffId] then
        if cd.abilityReady(lightArtsRecastId) then
            windower.chat.input("/ja \"Light Arts\" <me>")
            return buff_progress_result
        else
            return no_buff_result
        end
    end

    if cd.stratagemReady() then
        windower.chat.input("/ja Accession <me>")
        return buff_progress_result
    else
        return no_buff_result
    end
end

return tryAccession