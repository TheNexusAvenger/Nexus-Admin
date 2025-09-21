--Creates text entries in an ApiTextList.
--!strict

export type Properties = {[string]: any}
export type TextListEntry = {
    GuiInstance: GuiObject,
    Update: (self: TextListEntry, Index: number, Data: Properties) -> (TextListEntry),
    Destroy: (self: TextListEntry) -> (),
}

return function(TextHeight: number, TextType: "TextLabel" | "TextBox"): (InitialIndex: number, InitialData: Properties) -> (TextListEntry)
    local TextDefaults = {
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        TextStrokeTransparency = 0,
        Font = Enum.Font.SourceSans,
    }

    local TextListEntry = {}
    TextListEntry.__index = TextListEntry

    --[[
    Creates a text list entry. 
    --]]
    function TextListEntry.new(InitialIndex: number, InitialData: Properties): TextListEntry
        local TextLabel = Instance.new(TextType) :: any
        TextLabel.BackgroundTransparency = 1
        if TextType == "TextBox" then
            (TextLabel :: TextBox).ClearTextOnFocus = false
            (TextLabel :: TextBox).TextEditable = false
        end
        (TextLabel :: TextLabel).TextSize = TextHeight;
        (TextLabel :: TextLabel).TextXAlignment = Enum.TextXAlignment.Left;

        local self = (setmetatable({
            GuiInstance = TextLabel,
        }, TextListEntry) :: any) :: TextListEntry
        self:Update(InitialIndex, InitialData)
        return self
    end

    --[[
    Updates the text list entry.
    --]]
    function TextListEntry.Update(self: TextListEntry, Index: number, Data: Properties): ()
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
    function TextListEntry.Destroy(self: TextListEntry, Index: number, Data: Properties): ()
        self.GuiInstance:Destroy()
    end

    --Return the constructor.
    return TextListEntry.new
end