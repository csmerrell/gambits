cd = require("util/cooldown")

local sublimationRecastId = 234
local sublimationActivatedBuffId = 187
local sublimationCompleteBuffId = 188

function typeEval.special.sublimation(gambit)
    if not cd.abilityReady(sublimationRecastId) then return 0 end

    pl = windower.ffxi.get_player()
    selfBuffs = buffUtil.getBuffs()[pl.index]
    if not selfBuffs[sublimationActivatedBuffId] and not selfBuffs[sublimationCompleteBuffId] then
        windower.chat.input("/ja Sublimation <me>")
        return tick.jaDelay
    end

    if gambit.missingMpThreshold then
        if pl.vitals.mp - pl.vitals.max_mp < gambit.missingMpThreshold then
            windower.chat.input("/ja Sublimation <me>")
            return tick.jaDelay
        end
    else
        if pl.vitals.mpp < 15 then
            windower.chat.input("/ja Sublimation <me>")
            return tick.jaDelay
        end
    end

    return 0
end