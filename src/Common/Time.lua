--[[
TheNexusAvenger

Utility for time.
--]]

local NexusObject = require(script.Parent.Parent:WaitForChild("NexusInstance"):WaitForChild("NexusObject"))

local Time = NexusObject:Extend()
Time:SetClassName("Time")



--[[
Returns the current timestamp, or the timestamp
for the given time.
--]]
function Time:GetTimeString(Time)
    local Date = os.date("*t",Time)
    return string.format("%02.0f:%02.0f:%02.0f",Date.hour % 24,Date.min,Date.sec)
end



return Time