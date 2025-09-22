--Tests the Registry utility.
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Time = require(ReplicatedStorage.Packages.NexusAdmin.NexusAdmin.Common.Time)

return function()
    describe("The Time utility", function()
        it("should format seconds.", function()
            expect(Time:GetDurationString(1)).to.equal("1 second")
            expect(Time:GetDurationString((31 * 60) + 8)).to.equal("31 minutes, 8 seconds")
            expect(Time:GetDurationString((2 * 24 * 60 * 60) + (60 * 60) + (31 * 60) + 8)).to.equal("2 days, 1 hour, 31 minutes, 8 seconds")
        end)
    end)
end