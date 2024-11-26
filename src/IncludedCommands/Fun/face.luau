--Implementation of a command.
--!strict

local InsertService = game:GetService("InsertService")

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "face",
    Category = "FunCommands",
    Description = "Gives the face with the given id to each player.",
    Arguments = {
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
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, Id: number)
        --Insert the face.
        local Face = nil
        local Model = InsertService:LoadAsset(Id)
        for _, FaceItem in Model:GetChildren() do
            if FaceItem:IsA("Decal") then
                Face = FaceItem
            end
        end

        --Set the face.
        if Face then
            for _, Player in Players do
                local Character = Player.Character
                if Character then
                    local Head = Character:FindFirstChild("Head")
                    if Head then
                        --Get the transparency.
                        local ExistingFace = Head:FindFirstChildOfClass("Decal") :: Decal
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
    end,
}