--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "insert",
    Category = "BuildUtility",
    Description = "Inserts a model with a given id at your location.",
    Arguments = {
        {
            Type = "numbers",
            Name = "Ids",
            Description = "Models to insert.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Ids: {number})
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        --Insert the models.
        for _, Id in Ids do
            --Insert the model.
            local Model = game:GetService("InsertService"):LoadAsset(Id)
            Model.Parent = Api.AdminItemContainer
            
            --Move the model.
            local Character = CommandContext.Executor.Character
            if Character then
                local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") :: BasePart
                if HumanoidRootPart then
                    Model:MoveTo(HumanoidRootPart.Position)
                end
            end
        end
    end,
}