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
    self:InitializeSuper("vibrate","FunCommands","Vibrates a set of players.")
    
    self.Arguments = {
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
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players,Intensity)
    self.super:Run(CommandContext)
    Intensity = Intensity or 0.1
    
    for _,Player in pairs(Players) do
        if Player.Character then
            local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
            if HumanoidRootPart then
                --Stop the existing vibration.
                if CommonState.PlayerVibrations[Player] then
                    CommonState.PlayerVibrations[Player]:Destroy()
                end

                --Create the psuedo-object.
                local Vibration = {}
                Vibration.Active = true
                Vibration.Intensity = Intensity
                Vibration.HumanoidRootPart = HumanoidRootPart
                function Vibration:Start()
                    while self.Active do
                        self.HumanoidRootPart.CFrame = self.HumanoidRootPart.CFrame * CFrame.new((math.random(-100,100)/100) * self.Intensity,0,(math.random(-100,100)/100) * self.Intensity)
                        wait()
                    end
                end
                function Vibration:Destroy()
                    Vibration.Active = false
                end

                --Store the psuedo-object and start vibrating.
                if Intensity ~= 0 then
                    coroutine.wrap(function()
                        Vibration:Start()
                    end)()
                end
                CommonState.PlayerVibrations[Player] = Vibration
            end
        end
    end
end



return Command