--[[
TheNexusAvenger

Base class for a command.
--]]

local NexusObject = require(script.Parent.Parent:WaitForChild("NexusInstance"):WaitForChild("NexusObject"))
local IncludedCommandUtil = require(script.Parent:WaitForChild("IncludedCommandUtil"))

local BaseCommand = NexusObject:Extend()
BaseCommand:SetClassName("BaseCommand")
BaseCommand.Workspace = game:GetService("Workspace")
BaseCommand.Lighting = game:GetService("Lighting")
BaseCommand.Players = game:GetService("Players")
BaseCommand.StarterGui = game:GetService("StarterGui")
BaseCommand.Teams = game:GetService("Teams")
BaseCommand.InsertService = game:GetService("InsertService")
BaseCommand.LogService = game:GetService("LogService")
BaseCommand.MarketplaceService = game:GetService("MarketplaceService")
BaseCommand.PhysicsService = game:GetService("PhysicsService")
BaseCommand.RunService = game:GetService("RunService")
BaseCommand.TeleportService = game:GetService("TeleportService")
BaseCommand.UserInputService = game:GetService("UserInputService")
BaseCommand.TweenService = game:GetService("TweenService")
warn("BaseCommand is deprecated and will be removed in a future release of Nexus Admin.")



--[[
Creates a base command
--]]
function BaseCommand:__new(Keyword,Category,Description)
    self:InitializeSuper()
    
    --Initialize the commadn data.
    if _G.GetNexusAdminServerAPI then
        self.API = _G.GetNexusAdminServerAPI()
    elseif _G.GetNexusAdminClientAPI then
        self.API = _G.GetNexusAdminClientAPI()
    end
    self.Prefix = ((self.API or {}).Configuration or {}).CommandPrefix
    self.Keyword = Keyword
    self.Category = Category
    self.Description = Description
    if self.API then
        if Keyword and Category then
            if type(Keyword) == "table" then
                self.AdminLevel = self.API.Configuration:GetCommandAdminLevel(Category,Keyword[1])
            else
                self.AdminLevel = self.API.Configuration:GetCommandAdminLevel(Category,Keyword)
            end
        end
    end
    self.Arguments = {}
end

--[[
Returns if a command is from a context.
--]]
function BaseCommand:ExecutedFromContext(Context)
    return self.CurrentUtil:ExecutedFromContext(Context)
end

--[[
Returns if a command was executed from the chat.
--]]
function BaseCommand:ExecutedFromChat()
    return self.CurrentUtil:ExecutedFromChat()
end

--[[
Returns if a command was executed from the gui console.
The GUI console was cancelled. This should never be true.
--]]
function BaseCommand:ExecutedFromGuiConsole()
    return self.CurrentUtil:ExecutedFromGuiConsole()
end

--[[
Returns if a command was executed from a keybind.
--]]
function BaseCommand:ExecutedFromKeybind()
    return self.CurrentUtil:ExecutedFromKeybind()
end

--[[
Sends a response back to the executor.
--]]
function BaseCommand:SendResponse(Message,Color)
    self.CurrentUtil:SendResponse(Message,Color)
end

--[[
Sends a message back to the executor.
--]]
function BaseCommand:SendMessage(Message)
    self.CurrentUtil:SendMessage(Message)
end

--[[
Sends an error back to the executor.
--]]
function BaseCommand:SendError(Message)
    self.CurrentUtil:SendError(Message)
end

--[[
Runs the command.
--]]
function BaseCommand:Run(CommandContext)
    self.CurrentContext = CommandContext
    self.CurrentUtil = IncludedCommandUtil.ForContext(CommandContext)
end

--[[
Returns the remaining string after a specified
amount of "sections".
--]]
function BaseCommand:GetRemainingString(CommandString,Sections)
    self.CurrentUtil:GetRemainingString(CommandString,Sections)
end

--[[
Moves a player to a given CFrame.
Includes unsitting the player to prevent
teleporting seats.
--]]
function BaseCommand:TeleportPlayer(Player,TargetCFrame)
    self.CurrentUtil:TeleportPlayer(Player,TargetCFrame)
end

--[[
Flattens the class to a table.
--]]
function BaseCommand:Flatten()
    return {
        --Cmdr data.
        Name = self.Name,
        Aliases = self.Aliases,
        Group = self.Group,
        Args = self.Args,
        AutoExec = self.AutoExec,

        --Nexus Admin data.
        Prefix = self.Prefix,
        Keyword = self.Keyword,
        Category = self.Category,
        Description = self.Description,
        AdminLevel = self.AdminLevel,
        Arguments = self.Arguments,
        Run = function(_,...)
            return self:Run(...)
        end,
    }
end



return BaseCommand