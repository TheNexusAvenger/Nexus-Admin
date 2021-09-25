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
    self:InitializeSuper("face","FunCommands","Gives the face with the given id to each player.")
    
    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to change the face.",
        },
        {
            Type = "integer",
            Name = "Id",
            Description = "Face id to use.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players,Id)
    self.super:Run(CommandContext)
    
    --Insert the face.
    local Face
    local Model = self.InsertService:LoadAsset(Id)
    for _,FaceItem in pairs(Model:GetChildren()) do
        if FaceItem:IsA("Decal") then
            Face = FaceItem
        end
    end

    --Set the face.
    if Face then
        for _,Player in pairs(Players) do
            local Character = Player.Character
            if Character then
                local Head = Character:FindFirstChild("Head")
                if Head then
                    --Get the transparency.
                    local ExistingFace = Head:FindFirstChildOfClass("Decal")
                    local Transparency = ExistingFace.Transparency
                    ExistingFace:Destroy()

                    --Add the new face.
                    local NewFace = Face:Clone()
                    NewFace.Transparency = Transparency
                    NewFace.Parent = Head
                end
            end
        end
    end
end



return Command