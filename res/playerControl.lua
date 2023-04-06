pc = {}

function pc.onKeyboard(dik, pressed, flags, blocked)
    if pressed and not state.gambitLeader then
        if settings.followFanRadian then
            ipc.takeLeader(settings.followFanRadian)
        else
            ipc.takeLeader()
        end
    end
end

windower.register_event("keyboard", pc.onKeyboard)
