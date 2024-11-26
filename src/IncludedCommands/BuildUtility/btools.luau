--Implementation of a command.
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "btools",
    Category = "BuildUtility",
    Description = "Gives the given players a set of the HopperBin tools.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to give build tools.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        --Give the build tools.
        for _, Player in Players do
            local Backpack = Player:FindFirstChild("Backpack")
            if Backpack then
                local GrabHopperBin = Instance.new("HopperBin")
                GrabHopperBin.Name = "Grab"
                GrabHopperBin.BinType = Enum.BinType.Grab
                GrabHopperBin.Parent = Backpack
                
                local CloneHopperBin = Instance.new("HopperBin")
                CloneHopperBin.Name = "Clone"
                CloneHopperBin.BinType = Enum.BinType.Clone
                CloneHopperBin.Parent = Backpack

                local HammerHopperBin = Instance.new("HopperBin")
                HammerHopperBin.Name = "Hammer"
                HammerHopperBin.BinType = Enum.BinType.Hammer
                HammerHopperBin.Parent = Backpack
            end
        end
    end,
}