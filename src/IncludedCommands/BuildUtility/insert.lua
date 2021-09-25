--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local CommonState = require(script.Parent.Parent:WaitForChild("CommonState"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("insert","BuildUtility","Inserts a model with a given id at your location.")

    self.Arguments = {
        {
            Type = "numbers",
            Name = "Ids",
            Description = "Models to insert.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Ids)
    self.super:Run(CommandContext)
    
    --Insert the models.
    for _,Id in pairs(Ids) do
        --Insert the model.
        local Model = game:GetService("InsertService"):LoadAsset(Id)
        Model.Parent = self.API.AdminItemContainer
        
        --Move the model.
        local Character = CommandContext.Executor.Character
        if Character then
            local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
            if HumanoidRootPart then
                Model:MoveTo(HumanoidRootPart.Position)
            end
        end
    end
end



return Command