--Utility for time.
--!strict

local Time = {}

export type Time = typeof(Time)



--[[
Returns the current timestamp, or the timestamp
for the given time.
--]]
function Time.GetTimeString(self: Time, Time: number?): string
    local Date = os.date("*t", Time) :: any
    return string.format("%02.0f:%02.0f:%02.0f", Date.hour % 24, Date.min, Date.sec)
end

--[[
Returns the current timestamp, or the timestamp
for the given time.
--]]
function Time.GetDateTimeString(self: Time, Time: number?): string
    local Date = os.date("*t", Time) :: any
    return string.format("%04.0f-%02.0f-%02.0f %02.0f:%02.0f:%02.0f", Date.year, Date.month, Date.day, Date.hour % 24, Date.min, Date.sec)
end



return Time