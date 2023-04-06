issue = {}
function issue.eval()
    if not settings.gambitLeader then return false end

    issue.engaged()
    issue.claimed()
end

function issue.engaged()
    if windower.ffxi.get_player().status == 1 then
        -- Player engaged
        if not state.engaged then
            state.engaged = true
            state.engagedTarget = windower.ffxi.get_mob_by_target("t")
            windower.send_ipc_message("engaged "..state.engagedTarget.id)
        end
    elseif windower.ffxi.get_player().status == 0 then
        if state.engaged then
            state.engaged = false
            state.engagedTarget = nil
            windower.send_ipc_message("disengaged")
        end
    end
end

function issue.claimed()

end