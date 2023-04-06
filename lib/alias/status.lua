statusIdList = require("lib/provided/status")

statuses = {}

for id,status in pairs(statusIdList) do
    statuses[status.en] = id
end

return statuses