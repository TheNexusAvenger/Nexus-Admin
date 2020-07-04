--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("clean","BasicCommands","Clears items that admins have created.")
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Message)
    self.super:Run(CommandContext)
    
    --Clear the dropped tools.
    for _,Ins in pairs(self.Workspace:GetChildren()) do
        if Ins:IsA("Tool") then
            Ins:Destroy()
        end
    end

    --Clear the admin items.
    self.API.AdminItemContainer:ClearAllChildren()
end



return Command