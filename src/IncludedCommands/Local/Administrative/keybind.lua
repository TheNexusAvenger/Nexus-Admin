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
    self:InitializeSuper("keybind","Administrative","Binds the key with a specified command.")

    self.Prefix = {"!",self.API.Configuration.CommandPrefix}
    self.Arguments = {
		{
			Type = "userInput",
			Name = "Key",
			Description = "Key to bind.",
		},
		{
			Type = "string",
			Name = "Command",
            Description = "Command to run.",
		},
    }

    --Connect the key presses.
    self.UserInputService.InputBegan:Connect(function(Input)
        if not self.UserInputService:GetFocusedTextBox() then
            local Commands = CommonState.Keybinds[Input.KeyCode] or CommonState.Keybinds[Input.UserInputType]
            if Commands then
                for _,Command in pairs(Commands) do
                    self.API.Messages:DisplayHint(self.API.Executor:ExecuteCommandWithOrWithoutPrefix(Command,self.Players.LocalPlayer,{ExecuteContext="Keybind"}))
                end
            end
        end
    end)
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Key,_)
    self.super:Run(CommandContext)

    --Bind the key.
    if not CommonState.Keybinds[Key] then
        CommonState.Keybinds[Key] = {}
    end
    table.insert(CommonState.Keybinds[Key],self:GetRemainingString(CommandContext.RawText,2))

    --Return the message.
    return "Key bound."
end



return Command