cd = require("util/cooldown")

typeEval.buff_ja = {}
selfBuffs = {}
function typeEval.buff_ja.eval(gambit)
    if gambit.target == "self" then
        pl = windower.ffxi.get_player()
        selfBuffs = buffUtil.getBuffs()[pl.index]
        if not selfBuffs[gambit.buffId] and cd.abilityReady(gambit.val.recast_id) then
            windower.chat.input("/ja \""..gambit.val.en.."\" <me>")
            return tick.jaDelay
        end
    end

    return 0
end