--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local F3X = script.Parent.Parent:WaitForChild("Resources"):WaitForChild("F3X")
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("btools","BuildUtility","Gives the given players a set of the HopperBin tools and F3X Build tools.")

    self.Arguments = {
		{
			Type = "nexusAdminPlayers",
			Name = "Players",
			Description = "Players to give build tools.",
		},
	}
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
	self.super:Run(CommandContext)
	
    --Give the build tools.
    for _,Player in pairs(Players) do
        local Backpack = Player:FindFirstChild("Backpack")
        if Backpack then
            --Give the hopper bins.
            local GrabHopperBin = Instance.new("HopperBin")
            GrabHopperBin.Name = "Grab"
            GrabHopperBin.BinType = "Grab"
            GrabHopperBin.Parent = Backpack
            
            local CloneHopperBin = Instance.new("HopperBin")
            CloneHopperBin.Name = "Clone"
            CloneHopperBin.BinType = "Clone"
            CloneHopperBin.Parent = Backpack

            local HammerHopperBin = Instance.new("HopperBin")
            HammerHopperBin.Name = "Hammer"
            HammerHopperBin.BinType = "Hammer"
            HammerHopperBin.Parent = Backpack

            --Give the F3X tools.
            F3X:Clone().Parent = Backpack
        end
    end
end



return Command