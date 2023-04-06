local help = require('lib/misc/help')

function commands.help(args)
    help.output()
end

function commands.help_c(args)
    help.outputConsole()
end

function commands.reload(args)
    windower.send_command("lua r gambits")
end
