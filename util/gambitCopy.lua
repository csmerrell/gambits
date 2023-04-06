function gambitCopy(gambits)
    result = {}

    for i, gambit in ipairs(gambits) do
        table.insert(result, gambit)
    end

    return result
end

return gambitCopy