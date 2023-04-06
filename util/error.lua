gambitError = {}

function gambitError.commandNotFound(args) 
    windower.add_to_chat(
        121, 
        string.format([[[Gambits]: Command `%s` not found. 
    Try `gambits help` (output - chat log) 
    Or `gambits help_c` (output - windower console)]]
        , args[1])
    )
end

function gambitError.setNotFound(setName) 
    windower.add_to_chat(
        121, 
        string.format([[[Gambits]: Set `%s` not found. 
    Staying on the currently active set.]], setName)
    )
end

function gambitError.defaultSetNotFound(setName) 
    windower.add_to_chat(
        121, 
        string.format([[[Gambits]: `default` set not found for `%s`. 
    Make sure your job file returns a gambit set named `default`.]], 
        windower.ffxi.get_player().main_job)
    )
end

function gambitError.gambitNotFound(gambit) 
    windower.add_to_chat(
        121, 
        string.format([[[Gambits]: Gambit of type `%s` named `%s` not found.]], 
        gambit.type, 
        gambit.name)
    )
end

function gambitError.unknownGambitType(gambit)
    windower.add_to_chat(
        121, 
        string.format([[[Gambits]: Unkown gambit type `%s` requested for gambit `%s`.]], 
        gambit.type, 
        gambit.name)
    )
end

return gambitError