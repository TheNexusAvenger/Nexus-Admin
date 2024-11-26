--Tests the Serialization class.
--!strict

local Serialization = require(game:GetService("ServerScriptService"):WaitForChild("MainModule"):WaitForChild("NexusAdmin"):WaitForChild("IncludedCommands"):WaitForChild("Local"):WaitForChild("Resources"):WaitForChild("Serialization"))

return function()
    describe("Serialization", function()
        it("should have the needed serializers.", function()
            Serialization:CheckSerializers()
        end)
    end)
end