stringExt = require("util/string")
tableExt = require("util/table")

helpUpdateMsg = [[[Gambits]: Update command format:
    [slot] [<subCommands>]
    Subcommands:
        [key | k] [<new gambit key>]
        [target | t] [<target type> | <ordered party table: e.g. {1,0,3}>] 
        [conditions | c] [<see docs for options>] ]]

invalidUpdateMsg = [[[Gambits]: Update command `%s` not found.
Valid formats: 
    [slot] [<subCommands>]
    Subcommands:
        [key | k] [<new gambit key>]
        [target | t] [<see update doc for options>] 
        [conditions | c] [<see update doc for options] ]]

function commands.update(args)
    if not (#args >= 3) then
        out.msg(helpUpdateMsg)
        return
    end

    slotNum = tonumber(args[1])
    if not slotNum then 
        out.msg("[Gambits]: Provided slot `"..args[1].."` isn't a number.")
        return
    end

    passThroughArgs = { unpack(args, 3) }
    if updateCmds[args[2]] then return updateCmds[args[2]](slotNum, passThroughArgs) end

    out.msg(string.format(invalidUpdateMsg, args[2]))
end
commands.u = commands.update

updateCmds = {}

function updateCmds.key(slot, args)
    keyedGambit = updateCmds.getKeyedGambit(args[1])
    if not keyedGambit then
        out.msg(string.format([[[Gambits]: Gambit with key `%s` not found.
    Make sure to use the key that's declared on the current job's gambits table.
    - Example: `gambits update 3 key cure3` Will look in the current job's gambits folder for `gambits.cure3` and replace the gambit at slot 3 with it.]], 
    args[1]))
        return
    end

    if keyedGambit.name then
        table.remove(activeGambits, slot)
        table.insert(activeGambits, slot, expandGambit(keyedGambit))
    elseif keyedGambit[1].name then
        table.remove(activeGambits, slot)
        for i=#keyedGambit, 1, -1 do
            table.insert(activeGambits, slot, expandGambit(keyedGambit[i]))
        end
    else
        out.msg([[[Gambits]: Gambit with key `%s` has an invalid format. 
        Please see the documentation for proper gambit formatting.]])
    end
end
updateCmds.k = updateCmds.key 

function updateCmds.getKeyedGambit(key)
    keyedGambit = {}

    split = stringExt.split(key, ".")
    if #split > 1 then
        keyedGambit = gambits[split[1]]
        for i, k in pairs(split) do
            if keyedGambit[k] then
                keyedGambit = keyedGambit[k]
            end 
        end
    else
        keyedGambit = gambits[key]
    end

    return keyedGambit
end

function updateCmds.target(slot, args)
    target = args[1]
    for i=2,#args do
        target = target..args[i]
    end

    error = false
    if target[1] == "{" then 
        target = tableExt.parseTable(target)
        if tableExt.contains(activeGambits[slot].validTargets, "table") then
            activeGambits[slot].target = target
        else
            error = true
        end
    else
        if tableExt.contains(activeGambits[slot].validTargets, target) then
            activeGambits[slot].target = target
        else
            error = true
        end
    end

    if error then
        out.msg(string.format("[Gambits]: Target `%s` is not valid for the gambit at slot `%s`.", args[1], slot))
    end
end
updateCmds.t = updateCmds.target

function updateCmds.conditions(slot, args)
    out.msg("[Gambits]: General Conditions not yet implemented")
end
updateCmds.c = updateCmds.conditions
