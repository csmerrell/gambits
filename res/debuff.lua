debuff = {}
debuff.state = {}

windower.register_event("action_message", )

statusMsgs = {
    [203] = "statusStick"
    [204] = "statusWear"
}

function handleMsg (actor_id, target_id, actor_index, target_index, message_id, param_1, param_2, param_3)
    if statusMsgs[message_id] then 
        cmd = statusMsgs[message_id]
        debuffParams = {
            ["targetId"] = target_id
            ["args"] = { param_1, param_2, param_3 }
        }
        return debuff[cmd](debuffParams) 
    end
end

function debuff.statusWear(debuffParams)

end

function debuff.statusStick(debuffParams)

end