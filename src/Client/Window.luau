--API for creating standard windows.
--!strict

local ApiWindow = require(script.Parent:WaitForChild("UI"):WaitForChild("Window"):WaitForChild("ApiWindow"))

local Window = {}
Window.__index = Window

export type Window = typeof(setmetatable({}, Window))



--[[
Creates a window with a given name.
--]]
function Window.CreateWindow(self: Window, TitleName: string): ApiWindow.ApiWindow
    local NewWindow = ApiWindow.new()
    NewWindow:SetTitle(TitleName)
    return NewWindow
end



return Window