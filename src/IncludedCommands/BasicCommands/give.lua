--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local ToolListEnum = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("ToolListEnum"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("give","BasicCommands","Gives a set of players tools matching the tool name(s) from Lighting, ReplicatedStorage, ServerStorage, or StarterPack.")
    ToolListEnum:SetUp(self.API.Registry)
    
    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to give tools.",
        },
        {
            Type = "nexusAdminTools",
            Name = "Tools",
            Description = "Tools to give.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players,ToolNames)
    self.super:Run(CommandContext)
    
    --Give the tools.
    for _,Tool in ToolListEnum:GetTools(ToolNames) do
        for _,Player in pairs(Players) do
            local Backpack = Player:FindFirstChild("Backpack")
            if Backpack then
                Tool:Clone().Parent = Backpack
            end
        end
    end
end



return Command