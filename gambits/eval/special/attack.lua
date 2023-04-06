function typeEval.special.attack(gambit)
    engaged = windower.ffxi.get_player().status == 1
    if engaged then
        if not state.engagedTargetId then
            windower.send_command("input /attackoff; input /lockoff")
            return .5
        end

        if windower.ffxi.get_player().target_locked then
            windower.chat.input("/lockon")
        end
        return 0
    elseif state.engagedTargetId then
        mob = windower.ffxi.get_mob_by_id(state.engagedTargetId)
        if not mob then return 0 end

        if windower.ffxi.get_player().target_index ~= mob.index then 
            pIdx = state.getLeaderIdx()
            if pIdx then
                windower.chat.input("/assist <"..pIdx..">") 
            end
        else
            windower.chat.input("/attack;")
            return .5
        end
    end

    return 0
end