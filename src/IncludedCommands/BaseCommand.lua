--[[
TheNexusAvenger

Base class for a command.
--]]

local NexusObject = require(script.Parent.Parent:WaitForChild("NexusInstance"):WaitForChild("NexusObject"))

local BaseCommand = NexusObject:Extend()
BaseCommand:SetClassName("BaseCommand")
BaseCommand.Workspace = game:GetService("Workspace")
BaseCommand.Lighting = game:GetService("Lighting")
BaseCommand.Players = game:GetService("Players")
BaseCommand.StarterGui = game:GetService("StarterGui")
BaseCommand.Teams = game:GetService("Teams")
BaseCommand.InsertService = game:GetService("InsertService")
BaseCommand.MarketplaceService = game:GetService("MarketplaceService")
BaseCommand.PhysicsService = game:GetService("PhysicsService")
BaseCommand.RunService = game:GetService("RunService")
BaseCommand.TeleportService = game:GetService("TeleportService")
BaseCommand.UserInputService = game:GetService("UserInputService")
BaseCommand.TweenService = game:GetService("TweenService")



--[[
Creates a base command
--]]
function BaseCommand:__new(Keyword,Category,Description)
    self:InitializeSuper()
    
    --Initialize the commadn data.
    if _G.GetNexusAdminServerAPI then
        self.API = _G.GetNexusAdminServerAPI()
    else
        self.API = _G.GetNexusAdminClientAPI()
    end
    self.Prefix = self.API.Configuration.CommandPrefix
    self.Keyword = Keyword
    self.Category = Category
    self.Description = Description
    if Keyword and Category then
        if type(Keyword) == "table" then
            self.AdminLevel = self.API.Configuration:GetCommandAdminLevel(Category,Keyword[1])
        else
            self.AdminLevel = self.API.Configuration:GetCommandAdminLevel(Category,Keyword)
        end
    end
    self.Arguments = {}
end

--[[
Returns if a command is from a context.
--]]
function BaseCommand:ExecutedFromContext(Context)
    local Data = self.CurrentContext:GetData()
    return Data and type(Data) == "table" and Data.ExecuteContext == Context
end

--[[
Returns if a command was executed from the chat.
--]]
function BaseCommand:ExecutedFromChat()
    return self:ExecutedFromContext("Chat")
end

--[[
Returns if a command was executed from the gui console.
The GUI console was cancelled. This should never be true.
--]]
function BaseCommand:ExecutedFromGuiConsole()
    return self:ExecutedFromContext("NexusAdminConsole")
end

--[[
Returns if a command was executed from a keybind.
--]]
function BaseCommand:ExecutedFromGuiConsole()
    return self:ExecutedFromContext("Keybind")
end

--[[
Sends a response back to the executor.
--]]
function BaseCommand:SendResponse(Message,Color)
    if self:ExecutedFromChat() or self:ExecutedFromGuiConsole() or self:ExecutedFromGuiConsole() then
        if self.CurrentContext.Executor then
            if _G.GetNexusAdminServerAPI then
                self.API.Messages:DisplayHint(self.CurrentContext.Executor,Message)
            else
                self.API.Messages:DisplayHint(Message)
            end
        end
    else
        self.CurrentContext:Reply(Message,Color)
    end
end

--[[
Sends a message back to the executor.
--]]
function BaseCommand:SendMessage(Message)
    self:SendResponse(Message,Color3.new(1,1,1))
end

--[[
Sends an error back to the executor.
--]]
function BaseCommand:SendError(Message)
    self:SendResponse(Message,Color3.new(1,0,0))
end

--[[
Runs the command.
--]]
function BaseCommand:Run(CommandContext)
    self.CurrentContext = CommandContext

    --Add the command to the logs.
    if self.API.Logs then
        coroutine.wrap(function()
            self.API.Logs:Add(CommandContext.Executor.Name.." ["..self.API.Time:GetTimeString().."]: "..self.API.Filter:FilterString(CommandContext.RawText,CommandContext.Executor))
        end)()
    end
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