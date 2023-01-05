--[[
TheNexusAvenger

Utility for included commands.
--]]
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

local Types = require(script.Parent.Parent:WaitForChild("Types"))

local IncludedCommantUtil = {}
IncludedCommantUtil.__index = IncludedCommantUtil



--[[
Creates a version of the utility for a command context.
--]]
function IncludedCommantUtil.ForContext(CommandContext: Types.CmdrCommandContext)
    return setmetatable({
        CurrentContext = CommandContext
    }, IncludedCommantUtil)
end

--[[
Returns the client API.
--]]
function IncludedCommantUtil:GetClientApi(): Types.NexusAdminApi
    return require(ReplicatedStorage:WaitForChild("NexusAdminClient")) :: Types.NexusAdminApi
end

--[[
Returns the server API.
--]]
function IncludedCommantUtil:GetServerApi(): Types.NexusAdminApiServer
    local Api = require(ServerScriptService:WaitForChild("NexusAdmin")) :: Types.NexusAdminApiServer
    while not Api:GetAdminLoaded() do task.wait() end
    return Api
end

--[[
Returns the relevant API for the given runtime.
--]]
function IncludedCommantUtil:GetApi(): Types.NexusAdminApi
    if RunService:IsServer() then
        self:GetServerApi()
    end
    return self:GetClientApi()
end

--[[
Returns if a command is from a context.
--]]
function IncludedCommantUtil:ExecutedFromContext(ContextName: string): boolean
    local Data = self.CurrentContext:GetData()
    return Data ~= nil and type(Data) == "table" and Data.ExecuteContext == ContextName
end

--[[
Returns if a command was executed from the chat.
--]]
function IncludedCommantUtil:ExecutedFromChat(): boolean
    return self:ExecutedFromContext("Chat")
end

--[[
Returns if a command was executed from the gui console.
The GUI console was cancelled. This should never be true.
--]]
function IncludedCommantUtil:ExecutedFromGuiConsole(): boolean
    return self:ExecutedFromContext("NexusAdminConsole")
end

--[[
Returns if a command was executed from a keybind.
--]]
function IncludedCommantUtil:ExecutedFromKeybind(): boolean
    return self:ExecutedFromContext("Keybind")
end

--[[
Sends a response back to the executor.
--]]
function IncludedCommantUtil:SendResponse(Message: string, Color: Color3): ()
    if self:ExecutedFromChat() or self:ExecutedFromGuiConsole() or self:ExecutedFromKeybind() then
        if self.CurrentContext.Executor then
            if RunService:IsServer() then
                self:GetServerApi().Messages:DisplayHint(self.CurrentContext.Executor, Message)
            else
                self:GetClientApi().Messages:DisplayHint(Message)
            end
        end
    else
        self.CurrentContext:Reply(Message, Color)
    end
end

--[[
Sends a message back to the executor.
--]]
function IncludedCommantUtil:SendMessage(Message: string): ()
    self:SendResponse(Message, Color3.new(1, 1, 1))
end

--[[
Sends an error back to the executor.
--]]
function IncludedCommantUtil:SendError(Message: string): ()
    self:SendResponse(Message, Color3.new(1, 0, 0))
end

--[[
Returns the remaining string after a specified
amount of "sections".
--]]
function IncludedCommantUtil:GetRemainingString(CommandString: string, Sections: number): string
    --Remove parts of the string until the sections are passed.
    local InitialSpacesCleared = false
    local InQuotes = false
    local Escaping = false
    local InWhitespace = false
    while CommandString ~= "" and Sections > 0 do
        local Character = string.sub(CommandString, 1, 1)
        CommandString = string.sub(CommandString, 2)

        --Update the state based on the character.
        if InitialSpacesCleared or Character ~= " " then
            InitialSpacesCleared = true
            if Escaping then
                Escaping = false
            else
                if Character == "\\" then
                    Escaping = true
                    InWhitespace = false
                elseif Character == "\"" then
                    InQuotes = not InQuotes
                    InWhitespace = false
                elseif Character == " " then
                    if not InWhitespace and not InQuotes then
                        InWhitespace = true
                        Sections = Sections - 1
                    end
                else
                    InWhitespace = false
                end
            end
        end
    end

    --Remove the spaces in the front.
    while string.sub(CommandString, 1, 1) == " " do
        CommandString = string.sub(CommandString, 2)
    end

    --Return the remaining string.
    return CommandString
end

--[[
Moves a player to a given CFrame.
Includes unsitting the player to prevent
teleporting seats.
--]]
function IncludedCommantUtil:TeleportPlayer(Player: Player, TargetCFrame: CFrame): ()
    if not Player.Character then return end
    local Character = Player.Character :: Model
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") :: Part
    local Humanoid = Character:FindFirstChildOfClass("Humanoid") :: Humanoid
    if not HumanoidRootPart or not Humanoid then return end
    if Humanoid.SeatPart then
        --Unsit the player if the player is sitting and wait for the player to leave the seat before teleporting.
        Humanoid.Sit = false
        task.defer(function()
            while Humanoid.SeatPart do wait() end
            Humanoid.Sit = true
            HumanoidRootPart.CFrame = TargetCFrame
        end)
    else
        --Teleport the player.
        HumanoidRootPart.CFrame = TargetCFrame
    end
end



return IncludedCommantUtil