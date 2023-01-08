--[[
TheNexusAvenger

Helper function for getting the data for checking for cosistency.
--]]

local HUMANOID_PROPERTIES_TO_CHECK = {
    "AutoJumpEnabled",
    "AutoRotate",
    "BreakJointsOnDeath",
    "CameraOffset",
    "DisplayDistanceType",
    "DisplayName",
    "Health",
    "HealthDisplayDistance",
    "HipHeight",
    "Jump",
    "JumpHeight",
    "JumpPower",
    "MaxHealth",
    "MaxSlopeAngle",
    "Name",
    "NameDisplayDistance",
    "NameOcclusion",
    "PlatformStand",
    "RequiresNeck",
    "RigType",
    "RootPart",
    "SeatPart",
    "Sit",
    "UseJumpPower",
    "WalkSpeed",
}

export type InstanceTreeNode = {
    Name: string,
    ClassName: string,
    Children: {InstanceTreeNode},
}



--[[
Gets the descendants of an instance.
--]]
local function GetInstanceTree(ParentInstance: Instance): {InstanceTreeNode}
    local Instances = {}
    for _, Child in ParentInstance:GetChildren() do
        table.insert(Instances, {
            Name = Child.Name,
            ClassName = Child.ClassName,
            Children = GetInstanceTree(Child),
        })
    end
    return Instances
end

return function (Player: Player): {{Description: string, CompareMode: string, Data: any}}
    local Backpack = Player:FindFirstChild("Backpack")
    local StarterGear = Player:FindFirstChild("StarterGear")
    local Character = Player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local HumanoidProperties = nil
    if Humanoid then
        HumanoidProperties = {}
        for _, PropertyName in HUMANOID_PROPERTIES_TO_CHECK do
            HumanoidProperties[PropertyName] = Humanoid[PropertyName]
        end
    end
    return {
        {
            Description = "Humanoid",
            CompareMode = "KeyValue",
            Data = HumanoidProperties,
        },
        {
            Description = "Character",
            CompareMode = "InstanceTree",
            Data = Character and GetInstanceTree(Character),
        },
        {
            Description = "Backpack",
            CompareMode = "InstanceTree",
            Data = Backpack and GetInstanceTree(Backpack),
        },
        {
            Description = "StarterGear",
            CompareMode = "InstanceTree",
            Data = StarterGear and GetInstanceTree(StarterGear),
        },
    }
end