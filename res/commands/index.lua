commands = {}

require('res/commands/debug')
require('res/commands/user')
require('res/commands/core')
require('res/commands/follow')
require('res/commands/update')


windower.register_event('addon command', function(...)
    local args = {...}
    local subArgs = {}
    for i=2,#args do
        subArgs[i - 1] = args[i]
    end

    if commands[args[1]] then
        commands[args[1]](subArgs)
        display.box:text(display.getText())
    else
        gambitError.commandNotFound(args)
    end
end)

return commands