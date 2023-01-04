--[[
TheNexusAvenger

Utility for time.
--]]
--!strict

local Types = require(script.Parent.Parent:WaitForChild("Types"))

local Time = {} :: Types.Time



--[[
Returns the current timestamp, or the timestamp
for the given time.
--]]
function Time:GetTimeString(Time: number?): string
    local Date = os.date("*t", Time) :: any
    return string.format("%02.0f:%02.0f:%02.0f", Date.hour % 24, Date.min, Date.sec)
end



return Time :: Types.Time