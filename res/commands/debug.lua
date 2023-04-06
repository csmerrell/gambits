local colors = require('lib/misc/chatColors')

function commands.sampleColors(args)
    colors.sample()
end

function commands.echoDelay(args)
    out.echo(tick.tickDelay)
end

function commands.tick(args)
    if tick.on then
        out.msg("on")
    else
        out.msg("off")
    end
end