--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "clone",
    Category = "UsefulFunCommands",
    Description = "Clones the character of the given players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to clone.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        --Clone the players.
        for _,Player in Players do
            if Player.Character then
                Player.Character.Archivable = true

                local NewCharacter = Player.Character:Clone()
                NewCharacter:TranslateBy(Vector3.new(0, 6, 0))
                NewCharacter.Parent = Api.AdminItemContainer
            end
        end
    end,
}