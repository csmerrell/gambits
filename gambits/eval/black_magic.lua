typeEval.black_magic = {}

function typeEval.black_magic.eval(gambit)
    if pos.moving then return 0 end
    
    if state.engagedTargetId then
        mob = windower.ffxi.get_mob_by_id(state.engagedTargetId)
        if not mob then return 0 end

        windower.chat.input(gambit.activation.." "..state.engagedTargetId)
        return tick.spellcastBufferDelay + gambit.val.cast_time
    end

    return 0
end