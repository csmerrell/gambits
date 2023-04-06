cd = require("util/cooldown")
wsAliases = require("lib/alias/ws")
weaponSkills = require("lib/provided/ws")

typeEval.ws = {}
function typeEval.ws.eval(gambit)
    pl = windower.ffxi.get_player();
    if not state.engagedTargetId then return 0 end;

    gambit.tpThreshold = tonumber(gambit.tpThreshold)
    if not gambit.tpThreshold or gambit.tpThreshold < 1000 then gambit.tpThreshold = 1000 end

    if pl.vitals.tp < gambit.tpThreshold then return 0 end

    if gambit.behavior == "burn" then
        windower.chat.input(gambit.activation)
        return tick.wsDelay
    elseif gambit.behavior == "sc" or gambit.behavior == "skillchain" then
        isEcon = false
        if gambit.maxTpThreshold and tonumber(gambit.maxTpThreshold) < pl.vitals.tp then
            isEcon = true;
        end
        return typeEval.ws.skillchain(gambit, isEcon)
    elseif gambit.behavior == "avoid_sc" or gambit.behavior == "avoid_skillchain" then
        return typeEval.ws.avoidSkillchain(gambit)
    end

    return 0
end

function typeEval.ws.skillchain(gambit, isEcon)
    if gambit.step == 1 then
        if state.WSStack.size == 0 or state.WSStack:last().time < 3 then
            windower.chat.input(gambit.activation)
            return tick.wsDelay
        else
            return 0
        end
    else
        if state.WSStack.size <= gambit.step then return 0 end

        currTime = os.clock()
        node = state.WSStack:first()
        evalStep = 1
        for i = 1, state.WSStack.size do
            if not node then 
                if isEcon then
                    windower.chat.input(gambit.activation)
                    return tick.wsDelay
                end

                return 0 
            end

            if evalStep == gambit.step and 3 < node < 10 then
                winodwer.chat.input(gambit.activation)
                return tick.wsDelay    
            end

            unaliasedName = weaponSkills[wsAliases[gambit.stack[evalStep]]]
            if not unaliasedName then
                out.msg("[Gambits]: WS in Skillchain at step ["..evalStep.."] isn't a recognized WS key: ["..gambit.stack[evalStep].."]")
            else
                unaliasedName = unaliasedName.en
            end

            if node.name == unaliasedName then
                evalStep = evalStep + 1
                node = node.next
            else
                evalStep = 1
            end
        end
    end
    
    if isEcon then
        windower.chat.input(gambit.activation)
        return tick.wsDelay
    end

    return 0
end

function typeEval.ws.avoidSkillchain(gambit)
    return 0
end