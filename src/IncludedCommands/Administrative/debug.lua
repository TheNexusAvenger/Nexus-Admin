--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local Command = BaseCommand:Extend()
Command.LogService = game:GetService("LogService")



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("debug","Administrative","Displays the output of the server.")

    --Create the remote function.
    local GetServerOutputRemoteFunction = Instance.new("RemoteFunction")
    GetServerOutputRemoteFunction.Name = "GetServerOutput"
    GetServerOutputRemoteFunction.Parent = self.API.EventContainer

    function GetServerOutputRemoteFunction.OnServerInvoke(Player)
        if self.API.Authorization:IsPlayerAuthorized(Player,self.AdminLevel) then
            local Output = {}
            for _,Line in pairs(self.LogService:GetLogHistory()) do
                local LineData = {
                    Text = Line.message,
                }
                table.insert(Output,LineData)

                if Line.messageType == Enum.MessageType.MessageError then
                    LineData.TextColor3 = Color3.new(1,0,0)
                elseif Line.messageType == Enum.MessageType.MessageInfo then
                    LineData.TextColor3 = Color3.new(102/255,127/255,1)
                elseif Line.messageType == Enum.MessageType.MessageWarning then
                    LineData.TextColor3 = Color3.new(1,153/255,102/255)
                end
            end

            return Output
        else
            return {"Unauthorized"}
        end
    end
end



return Command