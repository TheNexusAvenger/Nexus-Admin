--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

--[[
Sets the provided player's RigType
]]
local function SetRigType(Player : Player, RigType : string)
    RigType = Enum.HumanoidRigType[RigType]
    
    local Humanoid: Humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    
    local HumanoidDescription = Humanoid:GetAppliedDescription() or Players:GetHumanoidDescriptionFromUserId(Player.UserId)
    local NewCharacter: Model = Players:CreateHumanoidModelFromDescription(HumanoidDescription, RigType, Enum.AssetTypeVerification.Always) 
    local Animate: BaseScript = NewCharacter:FindFirstChild("Animate")

    local OldCFrame = Player.Character and Player.Character:GetPivot() or CFrame.new()

    if Player.Character then
        Player.Character:Destroy()
        Player.Character = nil
    end
    Player.Character = NewCharacter

    -- Clone StarterCharacterScripts to new character
    if StarterPlayer:FindFirstChild("StarterCharacterScripts") then
        for _, v in StarterPlayer:FindFirstChild("StarterCharacterScripts"):GetChildren() do
            if v.Archivable then
                v:Clone().Parent = NewCharacter
            end
        end
    end

    NewCharacter:PivotTo(oldCFrame)
    NewCharacter.Parent = workspace

    -- hacky way to fix other people being unable to see animations.
    for _ = 1, 2 do
        if Animate then
            Animate.Disabled = not Animate.Disabled
        end
    end

    return NewCharacter
end

return {
    Keyword = "rig",
    Category = "UsefulFunCommands",
    Description = "Changes the RigType of a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to change the RigType of.",
        },
        {
            Type = "rigType",
            Name = "RigType",
            Description = "The RigType to change to."
        }
    },
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        local RigTypeEnum = {}
        for _, RigType in Enum.HumanoidRigType:GetEnumItems() do
            table.insert(RigTypeEnum,RigType.Name)
        end
        Api.Registry:AddEnumType("rigType",RigTypeEnum)
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, RigType: string)
        for _, Player in Players do
            task.defer(SetRigType, Player, RigType)
        end
    end,
}
