--[[
TheNexusAvenger

Window for selecting commands and arguments.
This module is unused becuase the feature was cancelled.
--]]

local ResizableWindow = require(script.Parent.Parent.Parent:WaitForChild("Window"):WaitForChild("ResizableWindow"))
local Dropdown = require(script.Parent.Parent:WaitForChild("Input"):WaitForChild("Dropdown"))
local NexusButton = script.Parent.Parent.Parent.Parent:WaitForChild("NexusButton")
local TextButtonFactory = require(NexusButton:WaitForChild("Factory"):WaitForChild("TextButtonFactory"))

local ButtonFactory = TextButtonFactory.CreateDefault(Color3.new(0,170/255,255/255))
local ExecuteButtonFactory = TextButtonFactory.CreateDefault(Color3.new(0,170/255,0))

local ConsoleCommandWindow = ResizableWindow:Extend()
ConsoleCommandWindow:SetClassName("ConsoleCommandWindow")
ConsoleCommandWindow.Workspace = game:GetService("Workspace")
ConsoleCommandWindow.Players = game:GetService("Players")

--[[
Creates the window.
--]]
function ConsoleCommandWindow:__new(API)
    --Determine the dimensions.
    local CameraHeight = self.Workspace.CurrentCamera.ViewportSize.Y
    self.TextHeight = CameraHeight * 0.025

    --Initialize the window.
    local MinHeight = (CameraHeight * 0.1) + (self.TextHeight * 4)
    self.MinHeight = MinHeight
    self:InitializeSuper(MinHeight * 2,MinHeight)
    self.ContentsAdorn.ClipsDescendants = true
    self.Title = "Nexus Admin Console"
    self.API = API

    --Create the common UI elements.
    local ArgumentsContainer = Instance.new("Frame")
    ArgumentsContainer.BackgroundTransparency = 1
    ArgumentsContainer.Size = UDim2.new(1,-self.TextHeight * 6,1,0)
    ArgumentsContainer.ClipsDescendants = true
    ArgumentsContainer.Parent = self.ContentsAdorn
    self.ArgumentsContainer = ArgumentsContainer

    local CommandHeader = Instance.new("TextLabel")
    CommandHeader.BackgroundTransparency = 1
    CommandHeader.Size = UDim2.new(0,self.TextHeight * 8,0,self.TextHeight)
    CommandHeader.Position = UDim2.new(0,self.TextHeight * 0.25,0,self.TextHeight * 0.25)
    CommandHeader.Text = "Command"
    CommandHeader.Font = "SciFi"
    CommandHeader.TextColor3 = Color3.new(1,1,1)
    CommandHeader.TextStrokeColor3 = Color3.new(0,0,0)
    CommandHeader.TextStrokeTransparency = 0
    CommandHeader.TextSize = self.TextHeight
    CommandHeader.TextXAlignment = "Left"
    CommandHeader.Parent = ArgumentsContainer

    local CommandSelectorButton,CommandSelectorText = ButtonFactory:Create()
    CommandSelectorButton.Size = UDim2.new(0,self.TextHeight * 8,0,(self.TextHeight * 1.4) / 1.2)
    CommandSelectorButton.Position = UDim2.new(0,self.TextHeight * 0.25,0,self.TextHeight * 1.35)
    CommandSelectorButton.Parent = ArgumentsContainer
    CommandSelectorText.Text = "(Select)"
    self.CommandSelectorButton = CommandSelectorButton
    self.CommandSelectorText = CommandSelectorText
    
    local CommandDescription = Instance.new("TextLabel")
    CommandDescription.BackgroundTransparency = 1
    CommandDescription.Size = UDim2.new(1,-self.TextHeight * 0.5,1,-self.TextHeight * 3)
    CommandDescription.Position = UDim2.new(0,self.TextHeight * 0.25,0,self.TextHeight * 3)
    CommandDescription.Text = ""
    CommandDescription.Font = "SciFi"
    CommandDescription.TextColor3 = Color3.new(1,1,1)
    CommandDescription.TextStrokeColor3 = Color3.new(0,0,0)
    CommandDescription.TextStrokeTransparency = 0
    CommandDescription.TextSize = self.TextHeight
    CommandDescription.TextWrapped = true
    CommandDescription.TextXAlignment = "Left"
    CommandDescription.TextYAlignment = "Top"
    CommandDescription.Parent = ArgumentsContainer
    self.CommandDescription = CommandDescription

    local ExecuteButton,ExecuteText = ExecuteButtonFactory:Create()
    ExecuteButton.Size = UDim2.new(0,self.TextHeight * 5,0,(self.TextHeight * 1.4) / 1.2)
    ExecuteButton.Position = UDim2.new(1,-self.TextHeight * 5.25,0,self.TextHeight * 1.35)
    ExecuteButton.Parent = self.ContentsAdorn
    ExecuteText.Text = "Execute"

    --Connect the buttons.
    local DB = true
    CommandSelectorButton.MouseButton1Down:Connect(function()
        if DB then
            DB = false
            self:OpenCommandSelector()
            wait()
            DB = true
        end
    end)
    ExecuteButton.MouseButton1Down:Connect(function()
        if DB then
            DB = false

            wait()
            DB = true
        end
    end)
end

--[[
Shows the window.
--]]
function ConsoleCommandWindow:Show(Parent)
    if not self.InitializeSizeSet then
        self.InitializeSizeSet = true
        self.WindowFrame.Size = UDim2.new(0,self.Workspace.CurrentCamera.ViewportSize.X - (4 * self.TextHeight),0,self.MinHeight)
        self.WindowFrame.Position = UDim2.new(0,2 * self.TextHeight,0,self.Workspace.CurrentCamera.ViewportSize.Y - (2 * self.MinHeight))
    end
    self.WindowFrame.Parent = Parent
    self.WindowFrame.Visible = true
end

--[[
Opens the command selector.
--]]
function ConsoleCommandWindow:OpenCommandSelector()
    if not self.CommandSelectorOpen then
        self.CommandSelectorOpen = true

        --Create the dropdown menus.
        if not self.CommandDropdownMenu then
            local CommandOptions = {}
            local CommandsUsed = {}
            for GroupName,GroupCommands in pairs(self.API.Registry.CommandsByGroup) do
                local CommandGroupOptions = {}
                for _,Command in pairs(GroupCommands) do
                    local CmdrCommand = self.API.Registry:GetReplicatableCmdrData(Command)
                    if not CommandsUsed[CmdrCommand.Name] then
                        CommandsUsed[CmdrCommand.Name] = true
                        CommandGroupOptions[CmdrCommand.Name] = CmdrCommand.Name
                    end
                end
                CommandOptions[GroupName] = Dropdown.new(CommandGroupOptions,function(SelectedOption)
                    self.CommandSelectorOpen = false
                    self.CommandDropdownMenu:Hide()
                    self:SetCommandSelector(SelectedOption)
                end)
            end

            --Create the main dropdown menu.
            self.CommandDropdownMenu = Dropdown.new(CommandOptions,nil,function()
                self.CommandSelectorOpen = false
                self.CommandDropdownMenu:Hide()
            end)
        end

        --Create the dropdown parent.
        if not self.DropdownParent or not self.DropdownParent.Parent then
            self.DropdownParent = Instance.new("ScreenGui")
            self.DropdownParent.Name = "NexusAdminDropdownMenuParent"
            self.DropdownParent.DisplayOrder = 10
            self.DropdownParent.Parent = self.Players.LocalPlayer:FindFirstChild("PlayerGui")
        end

        --Show the dropdown menu.
        self.CommandDropdownMenu:Show(self.DropdownParent,self.CommandSelectorButton.Size,UDim2.new(0,self.CommandSelectorButton.AbsolutePosition.X,0,self.CommandSelectorButton.AbsolutePosition.Y))
    end
end

--[[
Sets the selected command.
--]]
function ConsoleCommandWindow:SetCommandSelector(Command)
    self.CommandSelectorText.Text = Command

    --Clear the existing arguments.
    --UNIMPLEMENTED; Feature Cancelled

    --Add the new arguments.
    --UNIMPLEMENTED; Feature Cancelled
end



return ConsoleCommandWindow