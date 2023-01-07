--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "play",
    Category = "FunCommands",
    Description = "Plays music with the given id.",
    Arguments = {
        {
            Type = "integer",
            Name = "AudioId",
            Description = "Audio id to play.",
        },
    },
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        local GlobalAudio = Instance.new("Sound")
        GlobalAudio.Name = "NexusAdmin_GlobalAudio"
        GlobalAudio.Looped = true
        Api.CommandData.GlobalAudioSound = GlobalAudio
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, AudioId: number)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetServerApi()

        --Get the audio information.
        local Worked,ProductData = pcall(function()
            return MarketplaceService:GetProductInfo(AudioId)
        end)
        if not Worked or not ProductData then
            Util:SendError("Error loading audio "..tostring(AudioId)..".")
            return
        end

        --Display a message for playing the audio.
        if ProductData.AssetTypeId ~= 3 then 
            Util:SendError(tostring(ProductData.Name.."("..tostring(AudioId)..") is not an audio."))
            return
        end
        for _,Player in Players:GetPlayers() do
            Api.Messages:DisplayHint(Player,tostring("Now playing \""..tostring(ProductData.Name).."\" ("..AudioId..")."))
        end

        --Play the audio.
        local GlobalAudio = Api.CommandData.GlobalAudioSound
        GlobalAudio:Stop()
        GlobalAudio.SoundId = "rbxassetid://"..tostring(AudioId)
        GlobalAudio.Parent = Workspace
        GlobalAudio:Play()
    end,
}