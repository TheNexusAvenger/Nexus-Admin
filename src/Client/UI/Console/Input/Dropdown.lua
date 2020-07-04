--[[
TheNexusAvenger

Displays a list of options.
This module is unused becuase the feature was cancelled.
--]]

local NexusObject = require(script.Parent.Parent.Parent.Parent:WaitForChild("NexusInstance"):WaitForChild("NexusObject"))
local NexusButton = script.Parent.Parent.Parent.Parent:WaitForChild("NexusButton")
local TextButtonFactory = require(NexusButton:WaitForChild("Factory"):WaitForChild("TextButtonFactory"))

local DropdownMenuButton = TextButtonFactory.CreateDefault(Color3.new(0,170/255,200/255))

local Dropdown = NexusObject:Extend()
Dropdown:SetClassName("Dropdown")
Dropdown.Workspace = game:GetService("Workspace")



--[[
Creates the dropdown.
--]]
function Dropdown:__new(Options,Callback,CancelCallback)
    self:InitializeSuper()

    --Create the container.
    local Container = Instance.new("Frame")
    Container.BackgroundTransparency = 1
    Container.Visible = false
    self.Container = Container

    --Sort the options by name.
    local Names = {}
    for Name,_ in pairs(Options) do
        table.insert(Names,Name)
    end
    table.sort(Names,function(a,b) return string.lower(a) < string.lower(b) end)
    table.insert(Names,"(Cancel)")

    --Create the buttons.
    self.Buttons = {}
    self.Options = Options
    for i,Name in pairs(Names) do
        --Create the button.
        local Button,TextLabel = DropdownMenuButton:Create()
        Button.Position = UDim2.new(0,0,1.2 * (i - 1),0)
        Button.Size = UDim2.new(1,0,1,0)
        TextLabel.Text = Name
        Button.Parent = Container
        table.insert(self.Buttons,Button)

        --Connect the events.
        if type(Options[Name]) == "string" then
            local DB = true
            Button.MouseButton1Down:Connect(function()
                if DB then
                    DB = false
                    Callback(Options[Name])
                    wait()
                    DB = true
                end
            end)
            Button.MouseEnter:Connect(function()
                self:HideSubmenus()
            end)
        elseif type(Options[Name]) == "table" then
            Button.MouseEnter:Connect(function()
                self:HideSubmenus()
                Options[Name]:Show(self.Container.Parent,self.Container.Size,self.Container.Position + UDim2.new(0,self.Container.Size.X.Offset,0,self.Container.Size.Y.Offset * 1.2 *  (i - 1)))
            end)
        else
            local DB = true
            Button.MouseButton1Down:Connect(function()
                if DB then
                    DB = false
                    if CancelCallback then
                        CancelCallback()
                    else
                        self:Hide()
                    end
                    wait()
                    DB = true
                end
            end)
        end
    end
end

--[[
Shows the dropdown menu.
--]]
function Dropdown:Show(Parent,Size,Position)
    --Change the position if the dropdown goes off-screen.
    local ScreenHeight = self.Workspace.CurrentCamera.ViewportSize.Y
    local EndPosition = Position.Y.Offset + (Size.Y.Offset * 1.2 * (#self.Buttons + 1))
    if EndPosition > ScreenHeight then
        Position = Position + UDim2.new(0,0,0,ScreenHeight - EndPosition)
    end

    --Move the container.
    self.Container.Parent = Parent
    self.Container.Size = Size
    self.Container.Position = Position
    self.Container.Visible = true
end

--[[
Hides all submenus.
--]]
function Dropdown:HideSubmenus()
    for _,Option in pairs(self.Options) do
        if type(Option) ~= "string" then
            Option:Hide()
        end
    end
end

--[[
Hides the dropdown menu.
--]]
function Dropdown:Hide()
    self:HideSubmenus()
    self.Container.Visible = false
end

--[[
Destroys the dropdown menu.
--]]
function Dropdown:Destroy()
    --Destroy the child dropdowns.
    for _,Option in pairs(self.Options) do
        if type(Option) ~= "string" then
            Option:Destroy()
        end
    end

    --Destroy the buttons.
    for _,Button in pairs(self.Buttons) do
        Button:Destroy()
    end

    --Destroy the container.
    self.Container:Destroy()
end



return Dropdown