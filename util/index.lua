function boolStr(bool)
    if bool then return "true" end 
    return "false"
end

function splitArgs(text)
    result = {}
    local spat, epat, buf, quoted = [=[^(['"])]=], [=[(['"])$]=]
    for str in text:gmatch("%S+") do
      local squoted = str:match(spat)
      local equoted = str:match(epat)
      local escaped = str:match([=[(\*)['"]$]=])
      if squoted and not quoted and not equoted then
        buf, quoted = str, squoted
      elseif buf and equoted == quoted and #escaped % 2 == 0 then
        str, buf, quoted = buf .. ' ' .. str, nil, nil
      elseif buf then
        buf = buf .. ' ' .. str
      end
      if not buf then table.insert(result, (str:gsub(spat,""):gsub(epat,""))) end
    end
    return result
end