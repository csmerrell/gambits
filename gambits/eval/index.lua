typeEval = {}
require("gambits/eval/ws")
require("gambits/eval/roll")
require("gambits/eval/heal")
require("gambits/eval/black_magic")
require("gambits/eval/buff_ja")
require("gambits/eval/buff_enhancing")
require("gambits/eval/geomancy")
require("gambits/eval/indicolure")

function eval(gambit)
    return typeEval[gambit.type].eval(gambit)
end

typeEval.special = {}
require("gambits/eval/special/sublimation")
require("gambits/eval/special/attack")

function typeEval.special.eval(gambit)
    if typeEval.special[gambit.name] then
        return typeEval.special[gambit.name](gambit)
    else
        out.msg(string.format("[Gambits]: Special gambit `%s` not found.", gambit.name))
        return 0
    end
end

return eval