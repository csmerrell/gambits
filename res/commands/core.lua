function commands.on(args)
    if not tick.on then
        tick.on = true
        out.msg("[Gambits]: Engaged")
    else 
        out.msg("[Gambits]: Were already active")
    end
end

function commands.off(args)
    if tick.on then
        tick.on = false
        out.msg("[Gambits]: Disengaged")
    else 
        out.msg("[Gambits]: Were already inactive")
    end
end

function commands.toggle(args)
    if tick.on then
        tick.on = false
        out.msg("[Gambits]: Disengaged")
    else
        tick.on = true
        out.msg("[Gambits]: Engaged")
    end
end
