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

--[[
Returns the legible duration for the given seconds.
--]]
function Time.SecondsToDuration(self: Time, Seconds: number): string
    local Days = math.floor(Seconds / (60 * 60 * 24))
    local D_Remainder = Seconds % (60 * 60 * 24)
    local Hours = math.floor(D_Remainder / (60 * 60))
    local H_Remainder = D_Remainder%(60 * 60)
    local Minutes = math.floor(H_Remainder / 60)
    local Seconds = H_Remainder % 60
    
    return `{Days} Days; {Hours} Hours; {Minutes} Minutes; {Seconds} Seconds`
end


return Time