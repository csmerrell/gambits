help = {}

help.text = [[[Gambits] - Command List:
0. Command Prefix: 
    - [gambits | gam]
1. [help | help_c] 
    - Displays this help menu. (help_c will show in the windower overlay)
2. [on | off | toggle]
    - Activates, disables, or toggles gambit execution
3. follow <subCommands>
    - Adjust auto-follow settings. Subcommands:
        - [p1 | p2 | p3 | p4 | p5]
        - [on | off | toggle | t]
        - [distance | dist | d] [2-25]
*. reload
    - Reloads the addon (alias for "lua r gambits").
]]

function help.output()
    --output command list using ffxi system message font
    windower.add_to_chat(121, help.text)
end

function help.outputConsole()
    --output command list using ffxi system message font
    print(help.text)
end

return help