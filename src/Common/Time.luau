--Utility for time.
--!strict

local TIME_DURATIONS = {
    {
        Label = "second",
        Seconds = 1,
        MaxDisplay = 60,
    },
    {
        Label = "minute",
        Seconds = 60,
        MaxDisplay = 60,
    },
    {
        Label = "hour",
        Seconds = 60 * 60,
        MaxDisplay = 24,
    },
    {
        Label = "day",
        Seconds = 24 * 60 * 60,
        MaxDisplay = 10 ^ 99, --No limit.
    },
}

local Time = {}

export type Time = typeof(Time)



--[[
Returns the current timestamp, or the timestamp for the given time.
--]]
function Time.GetTimeString(self: Time, Time: number?): string
    local Date = os.date("*t", Time) :: any
    return string.format("%02.0f:%02.0f:%02.0f", Date.hour % 24, Date.min, Date.sec)
end

--[[
Returns the current timestamp, or the timestamp for the given time.
--]]
function Time.GetDateTimeString(self: Time, Time: number?): string
    local Date = os.date("*t", Time) :: any
    return string.format("%04.0f-%02.0f-%02.0f %02.0f:%02.0f:%02.0f", Date.year, Date.month, Date.day, Date.hour % 24, Date.min, Date.sec)
end

--[[
Returns the a human-readable display for the given seconds.
--]]
function Time.GetDurationString(self: Time, Seconds: number): string
    local DurationString = ""
    for _, Label in TIME_DURATIONS do
        local Total = math.floor(Seconds / Label.Seconds)
        if Total <= 0 then break end
        if DurationString ~= "" then
            DurationString = `, {DurationString}`
        end
        local DisplayTotal = Total % Label.MaxDisplay
        DurationString = `{DisplayTotal} {Label.Label}{DisplayTotal == 1 and "" or "s"}{DurationString}`
    end
    return DurationString
end



return Time