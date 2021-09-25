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
    self:InitializeSuper("play","FunCommands","Plays music with the given id.")

    self.Arguments = {
        {
            Type = "integer",
            Name = "AudioId",
            Description = "Audio id to play.",
        },
    }
    
    --Create the audio.
    CommonState.GlobalAudio = Instance.new("Sound")
    CommonState.GlobalAudio.Name = "NexusAdmin_GlobalAudio"
    CommonState.GlobalAudio.Looped = true
    CommonState.GlobalAudio.Parent = self.Workspace
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,AudioId)
    self.super:Run(CommandContext)
    
    --Get the audio information.
    local Worked,ProductData = pcall(function()
        return self.MarketplaceService:GetProductInfo(AudioId)
    end)
    if not Worked or not ProductData then
        self:SendError("Error loading audio "..AudioId..".")
        return
    end

    --Display a message for playing the audio.
    if ProductData.AssetTypeId ~= 3 then 
        self:SendError(tostring(ProductData.Name.."("..AudioId..") is not an audio."))
        return
    end
    for _,Player in pairs(self.Players:GetPlayers()) do
        self.API.Messages:DisplayHint(Player,tostring("Now playing \""..tostring(ProductData.Name).."\" ("..AudioId..")."))
    end

    --Play the audio.
    CommonState.GlobalAudio:Stop()
    CommonState.GlobalAudio.SoundId = "rbxassetid://"..AudioId
    CommonState.GlobalAudio:Play()
end



return Command