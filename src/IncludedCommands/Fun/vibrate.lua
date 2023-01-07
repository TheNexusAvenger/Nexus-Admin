--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "vibrate",
    Category = "FunCommands",
    Description = "Vibrates a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to vibrate.",
        },
        {
            Type = "number",
            Name = "Intensity",
            Description = "Intensity of the vibration.",
            Optional = true,
        },
    },
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        Api.CommandData.PlayerVibrations = {}
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, Intensity: number)
        Intensity = Intensity or 0.1
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetServerApi()
    
        for _, Player in Players do
            if Player.Character then
                local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart") :: BasePart
                if HumanoidRootPart then
                    --Stop the existing vibration.
                    if Api.CommandData.PlayerVibrations[Player] then
                        Api.CommandData.PlayerVibrations[Player]:Destroy()
                    end
    
                    --Create the object.
                    local Vibration = {}
                    Vibration.Active = true
                    Vibration.Intensity = Intensity
                    Vibration.HumanoidRootPart = HumanoidRootPart
                    function Vibration:Run()
                        while self.Active do
                            self.HumanoidRootPart.CFrame = (self.HumanoidRootPart :: BasePart).CFrame * CFrame.new((math.random(-100, 100) / 100) * self.Intensity, 0, (math.random(-100, 100) / 100) * self.Intensity)
                            task.wait()
                        end
                    end
                    function Vibration:Destroy()
                        Vibration.Active = false
                    end
    
                    --Store the object and start vibrating.
                    if Intensity ~= 0 then
                        task.spawn(function()
                            Vibration:Run()
                        end)
                    end
                    Api.CommandData.PlayerVibrations[Player] = Vibration
                end
            end
        end
    end,
}