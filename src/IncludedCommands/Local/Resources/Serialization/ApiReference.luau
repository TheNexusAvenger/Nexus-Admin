--Manages the API reference.
--!strict

local MAX_LENGTH_PER_VALUE = 180000

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local ApiReferenceData = script.Parent:WaitForChild("ApiReferenceData")
local ApiReference = {
    ApiDump = nil :: any,
    UpdateAttmepted = false,
    PropertiesCache = {},
}

export type ApiReference = typeof(ApiReference)



--[[
Updates the API reference.
--]]
function ApiReference.UpdateApiReference(self: ApiReference): ()
    --Return if an update was attempted.
    if self.UpdateAttmepted or RunService:IsClient() then
        return
    end

    --Get the latest API version.
    local Worked, ApiVersion = pcall(function()
        return HttpService:JSONDecode(HttpService:RequestAsync({
            Url = "https://raw.githubusercontent.com/RobloxAPI/build-archive/master/data/production/latest.json",
            Method = "GET",
        }).Body).GUID
    end)
    if not Worked then
        warn(`Failed to get latest API version because {ApiVersion}`)
        self.UpdateAttmepted = true
        return
    end

    --Get the latest API dump.
    local Worked, ApiDumpJson = pcall(function()
        local Response = HttpService:RequestAsync({
            Url = `https://raw.githubusercontent.com/RobloxAPI/build-archive/master/data/production/builds/{ApiVersion}/API-Dump.json`,
            Method = "GET",
        })
        if Response.StatusCode ~= 200 then
            error(`Invalid response returned: {Response.StatusCode} - {Response.StatusMessage}`)
        end
        return Response.Body
    end)
    if not Worked then
        warn(`Failed to get lates API dump because {ApiDumpJson}`)
        self.UpdateAttmepted = true
        return
    end

    --Clear the existing StringValues.
    for _, StringValue in ApiReferenceData:GetChildren() do
        if StringValue:IsA("StringValue") then
            StringValue:Destroy()
        end
    end

    --Store the values.
    local CurrentValueId = 1
    while ApiDumpJson ~= "" do
        local StringValueFragment = Instance.new("StringValue")
        StringValueFragment.Name = tostring(CurrentValueId)
        StringValueFragment.Value = string.sub(ApiDumpJson, 1, MAX_LENGTH_PER_VALUE)
        StringValueFragment.Parent = ApiReferenceData
        CurrentValueId = CurrentValueId + 1
        ApiDumpJson = string.sub(ApiDumpJson, MAX_LENGTH_PER_VALUE + 1)
    end
end

--[[
Returns the current API reference.
--]]
function ApiReference.GetApiDump(self: ApiReference)
    --Build the API dump if it isn't already stored.
    if not self.ApiDump then
        local ApiDumpJson = ""
        local CurrentIndex = 1
        while ApiReferenceData:FindFirstChild(tostring(CurrentIndex)) do
            ApiDumpJson ..= ApiReferenceData:FindFirstChild(tostring(CurrentIndex)).Value
            CurrentIndex = CurrentIndex + 1
        end
        self.ApiDump = HttpService:JSONDecode(ApiDumpJson)
    end

    --Return the API dump.
    return self.ApiDump
end

--[[
Returns the base API reference for a class name.
--]]
function ApiReference.GetRaw(self: ApiReference, ClassName: string)
    for _, Class in self:GetApiDump().Classes do
        if Class.Name == ClassName then
            return Class
        end
    end
    return nil
end

--[[
Returns if the class is creatable.
--]]
function ApiReference.IsCreateable(self: ApiReference, ClassName: string): boolean
    local Class = self:GetRaw(ClassName)
    if not Class then return false end
    for _, Tag in Class.Tags or {} do
        if Tag == "NotCreatable" then
            return false
        end
    end
    return true
end

--[[
Returns the writable properties of a class, including superclasses.
--]]
function ApiReference.GetProperties(self: ApiReference, ClassName: string)
    if not self.PropertiesCache[ClassName] then
        --Get the properties of the class.
        local Properties = {}
        local Class = self:GetRaw(ClassName)
        if Class then
            for _, Member in Class.Members do
                --Ignore the property if it isn't a property.
                if Member.MemberType ~= "Property" then
                    continue
                end

                --Ignore the property if it is read only.
                local TagsMap = {}
                for _, Tag in Member.Tags or {} do
                    TagsMap[Tag] = true
                end
                if TagsMap["ReadOnly"] or TagsMap["Hidden"] or TagsMap["Deprecated"] then
                    continue
                end
                if Member.Security.Write ~= "None" then
                    continue
                end
                if not Member.Serialization.CanSave and not Member.Serialization.CanLoad then
                    continue
                end

                --Add the property.
                table.insert(Properties, Member)
            end

            --Add the superclass properties.
            if Class.Superclass then
                for _, Property in self:GetProperties(Class.Superclass) do
                    table.insert(Properties, Property)
                end
            end
        end
        self.PropertiesCache[ClassName] = Properties
    end

    --Return the properties.
    return self.PropertiesCache[ClassName] or {}
end



return ApiReference