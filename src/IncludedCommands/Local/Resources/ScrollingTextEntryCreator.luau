--Creates text entries in a ScrollingTextWindow.
--!strict

local NexusVirtualList = require(script.Parent.Parent.Parent:WaitForChild("NexusVirtualList"))

export type Properties = {[string]: any}

return function(TextHeight: number, UseTextBoxes: boolean): NexusVirtualList.ListEntry<any>
    local TextDefaults = {
        TextColor3 = Color3.new(1, 1, 1),
        TextStrokeColor3 = Color3.new(0, 0, 0),
        TextStrokeTransparency = 0,
        Font = Enum.Font.SourceSans,
    }

    local TextListEntry = {}
    TextListEntry.__index = TextListEntry

    --[[
    Creates a text list entry. 
    --]]
    function TextListEntry.new(InitialIndex: number, InitialData: Properties): NexusVirtualList.ListEntry<Properties>
        local TextLabel: GuiObject = UseTextBoxes and Instance.new("TextBox") or Instance.new("TextLabel")
        TextLabel.BackgroundTransparency = 1
        if UseTextBoxes then
            (TextLabel :: TextBox).ClearTextOnFocus = false
            (TextLabel :: TextBox).TextEditable = false
        end
        (TextLabel :: TextLabel).TextSize = TextHeight;
        (TextLabel :: TextLabel).TextXAlignment = Enum.TextXAlignment.Left

        local self = setmetatable({
           GuiInstance = TextLabel,
        }, TextListEntry)
        self:Update(InitialIndex, InitialData)
        return (self :: any) :: NexusVirtualList.ListEntry<Properties>
    end

    --[[
    Updates the text list entry.
    --]]
    function TextListEntry.Update(self: NexusVirtualList.ListEntry<Properties>, Index: number, Data: Properties): ()
        local TextLabel = (self.GuiInstance :: any)
        TextLabel.Name = `Line{Index}`

        for Key, _ in Data do
            if not TextDefaults[Key] then
                TextDefaults[Key] = TextLabel[Key]
            end
        end
        for Key, Value in TextDefaults do
            TextLabel[Key] = Data[Key] or Value
        end
    end

    --[[
    Destroys the text list entry.
    --]]
    function TextListEntry.Destroy(self: NexusVirtualList.ListEntry<Properties>, Index: number, Data: Properties): ()
        self.GuiInstance:Destroy()
    end

    return (TextListEntry.new :: any) :: ListEntryConstructor<Properties>
end