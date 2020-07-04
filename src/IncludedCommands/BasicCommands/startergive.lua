--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local ToolFilter = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("ToolFilter"))
local Command = BaseCommand:Extend()
Command.Containers = {
    game:GetService("Lighting"),
    game:GetService("ReplicatedStorage"),
    game:GetService("ServerStorage"),
    game:GetService("StarterPack"),
}



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("startergive","BasicCommands","Gives a set of players tools matching the tool name(s) from Lighting, ReplicatedStorage, ServerStorage, or StarterPack and makes it so they spawn with them.")
    
    self.Arguments = {
		{
			Type = "nexusAdminPlayers",
			Name = "Players",
			Description = "Players to give tools.",
		},
		{
			Type = "string",
			Name = "Tools",
			Description = "Tools to give.",
		},
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players,Tools)
    self.super:Run(CommandContext)
    
    --Give the tools.
    for _,Tool in pairs(ToolFilter(Tools,self.Containers)) do
        for _,Player in pairs(Players) do
            local Backpack = Player:FindFirstChild("Backpack")
            local StarterGear = Player:FindFirstChild("StarterGear")
            if Backpack then
                Tool:Clone().Parent = Backpack
            end
            if StarterGear then
                Tool:Clone().Parent = StarterGear
            end
        end
    end
end



return Command