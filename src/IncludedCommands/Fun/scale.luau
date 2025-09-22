--Implementation of a command.
--!strict

local SCALE_TYPES = {
    {
        Name = "All",
        Values = {"BodyDepthScale", "BodyHeightScale", "BodyWidthScale", "HeadScale"},
    },
    {
        Name = "Depth",
        Values = {"BodyDepthScale"},
    },
    {
        Name = "Height",
        Values = {"BodyHeightScale"},
    },
    {
        Name = "Width",
        Values = {"BodyWidthScale"},
    },
    {
        Name = "Head",
        Values = {"HeadScale"},
    },
}

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "scale",
    Category = "FunCommands",
    Description = "Scales the given characters by a multiplier. Does not support R6.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to give smoke to.",
        },
        {
            Type = "number",
            Name = "Multiplier",
            Description = "Multiplier to scale by.",
        },
        {
            Type = "characterScaleTypes",
            Name = "Type",
            Description = "Type of value to scale.",
            Optional = true,
        },
    },
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        local ScaleTypes = {}
        for _, ScaleType in SCALE_TYPES do
            table.insert(ScaleTypes, ScaleType.Name)
        end
        Api.Registry:AddEnumType("characterScaleType", ScaleTypes)
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, Multiplier: number, ScaleTypes: {string}?)
        --Get the scale values.
        local ScaleValueNames = {}
        for _, ScaleTypeName in ScaleTypes or {"All"} :: {string} do
            for _, ScaleType in SCALE_TYPES do
                if ScaleType.Name ~= ScaleTypeName then continue end
                for _, ScaleValueName in ScaleType.Values do
                    ScaleValueNames[ScaleValueName] = true
                end
            end
        end

        --Scale the characters.
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        for _, Player in Players do
            local Character = Player.Character
            if not Character then continue end
            local Humanoid = Character:FindFirstChildOfClass("Humanoid") :: Humanoid
            if not Humanoid then continue end
            if Humanoid.RigType == Enum.HumanoidRigType.R6 then
                Util:SendError(`{Player.Name} can't be scaled because the scale command does not support R6.`)
                continue
            end
            for ValueName, _ in ScaleValueNames do
                local ScaleValue = Humanoid:FindFirstChild(ValueName) :: NumberValue
                if not ScaleValue then continue end
                ScaleValue.Value = Multiplier * ScaleValue.Value
            end
        end
    end,
}