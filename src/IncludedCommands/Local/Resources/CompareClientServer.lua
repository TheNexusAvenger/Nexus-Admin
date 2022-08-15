--[[
TheNexusAvenger

Helper function for comparing consistency data between the client and server.
--]]

local INDENT = "    "
local IGNORED_INSTANCES = {
    {
        Names = {
            ThumbnailCamera = true,
        },
        ClassName = "Camera",
    },
    {
        Names = {
            Climbing = true,
            Died = true,
            GettingUp = true,
            Swimming = true,
            Jumping = true,
            Landing = true,
            Splash = true,
            FreeFalling = true,
            Running = true,
        },
        ClassName = "Sound",
    },
}



--[[
Creates a warning line with an indent.
--]]
local function GetIndentedWarningLine(Text)
    return {
        Text = INDENT..Text,
        TextColor3 = Color3.fromRGB(255, 255, 0),
    }
end

--[[
Returns the lines for a KeyValue comparison.
--]]
local function CheckKeyValue(ClientData, ServerData)
    local Lines = {}
    for PropertyName, ServerValue in ServerData do
        local ClientValue = ClientData[PropertyName]
        if ClientValue ~= ServerValue then
            table.insert(Lines, GetIndentedWarningLine(PropertyName.." is inconsistent. (Client: "..tostring(ClientValue)..", Server: "..tostring(ServerValue)..")"))
        end
    end
    return Lines
end

--[[
Returns the lines for a InstanceTree comparison.
--]]
local function CheckInstanceTree(ClientData, ServerData)
    local Lines = {}
    local Scans = {
        {
            NotFoundPrefix = "Client is missing ",
            Source = ServerData,
            Target = ClientData,
        },
        {
            NotFoundPrefix = "Client has extra ",
            Source = ClientData,
            Target = ServerData,
        },
    }
    for i, Scan in Scans do
        --Build the queue of children to look at.
        local RemainingInstances = {}
        for _, SourceChild in Scan.Source do
            SourceChild.FullName = SourceChild.Name
            table.insert(RemainingInstances, SourceChild)
        end

        --Iterate over the queue.
        while #RemainingInstances > 0 do
            local NextInstance = table.remove(RemainingInstances, 1)

            --Ignore the instance if it should be ignored.
            local IgnoreInstance = false
            for _, IgnoredInstanceData in IGNORED_INSTANCES do
                if NextInstance.ClassName == IgnoredInstanceData.ClassName and (not IgnoredInstanceData.Names or IgnoredInstanceData.Names[NextInstance.Name]) then
                    IgnoreInstance = true
                    break
                end
            end
            if IgnoreInstance then
                continue
            end

            --Determine if the instance exists in the target.
            local TargetPathParts = string.split(NextInstance.FullName, ".")
            local TargetInstance = nil
            local CurrentParent = Scan.Target
            for i, Name in TargetPathParts do
                local NewParent = nil
                for _, TargetChild in CurrentParent.Children or CurrentParent do
                    if TargetChild.Name == Name then
                        NewParent = TargetChild
                        break
                    end
                end
                if NewParent then
                    CurrentParent = NewParent
                    if i == #TargetPathParts then
                        TargetInstance = NewParent
                    end
                end
            end

            --Either the instance does not exist or enqueue the children.
            if not TargetInstance then
                table.insert(Lines, GetIndentedWarningLine(Scan.NotFoundPrefix..NextInstance.FullName.." ("..NextInstance.ClassName..")"))
            else
                if i == 1 and NextInstance.ClassName ~= TargetInstance.ClassName then
                    table.insert(Lines, GetIndentedWarningLine(NextInstance.FullName.." classes don't match ("..NextInstance.ClassName.." ~= "..TargetInstance.ClassName..")"))
                end
                for _, Child in pairs(NextInstance.Children) do
                    Child.FullName = NextInstance.FullName.."."..Child.Name
                    table.insert(RemainingInstances, Child)
                end
            end
        end
    end
    return Lines
end



return function (ClientData, ServerData)
    --Create a map of the client data.
    local ClientDataMap = {}
    for _, ClientDataEntry in ClientData do
        if ClientDataEntry.Description then
            ClientDataMap[ClientDataEntry.Description] = ClientDataEntry
        end
    end

    --Build the lines.
    local Lines = {}
    for i, ServerEntry in ServerData do
        table.insert(Lines, ServerEntry.Description)

        --Run the comparison.
        local ClientEntry = ClientDataMap[ServerEntry.Description]
        if not ClientEntry then
            table.insert(Lines, GetIndentedWarningLine("Client returned no data."))
        else
            local ComparisonLines = nil
            if ServerEntry.CompareMode == "KeyValue" then
                ComparisonLines = CheckKeyValue(ClientEntry.Data, ServerEntry.Data)
            elseif ServerEntry.CompareMode == "InstanceTree" then
                ComparisonLines = CheckInstanceTree(ClientEntry.Data, ServerEntry.Data)
            end
            if ComparisonLines then
                for _, Line in ComparisonLines do
                    table.insert(Lines, Line)
                end
                if #ComparisonLines == 0 then
                    table.insert(Lines, INDENT.."Client and server are consistent.")
                end
            else
                table.insert(Lines, GetIndentedWarningLine("Unknown compare mode "..tostring(ServerEntry.CompareMode).."."))
            end
        end

        --Add an extra line if there is another entry.
        if i ~= #ServerData then
            table.insert(Lines, "")
        end
    end
    return Lines
end