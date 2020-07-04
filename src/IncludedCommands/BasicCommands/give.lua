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
    self:InitializeSuper("give","BasicCommands","Gives a set of players tools matching the tool name(s) from Lighting, ReplicatedStorage, ServerStorage, or StarterPack.")
    
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
            if Backpack then
                Tool:Clone().Parent = Backpack
            end
        end
    end
end



return Command