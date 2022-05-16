--[[
TheNexusAvenger

Serializes and deserializes instances.
--]]

local IGNORED_TYPES = {
    BinaryString = true,
    Content = true,
    Font = true,
    QDir = true,
    QFont = true,
}
local IGNORED_INSTANCES = {
    Script = true,
    LocalScript = true,
    ModuleScript = true,
}




local HttpService = game:GetService("HttpService")

local ApiReference = require(script:WaitForChild("ApiReference"))
local DataTypeSerializers = require(script:WaitForChild("DataTypeSerializers"))
local DataTypeDeserializers = require(script:WaitForChild("DataTypeDeserializers"))

local Serialization = {}



--[[
Updates the API reference.
--]]
function Serialization:UpdateApiReference()
    ApiReference:UpdateApiReference()
end

--[[
Checks that the needed DataType serializers and deserializers exist.
--]]
function Serialization:CheckSerializers()
    --Get the types.
    local Types = {}
    for _, Class in pairs(ApiReference:GetApiDump().Classes) do
        for _, Member in pairs(Class.Members or {}) do
            --Ignore the member if it isn't a type.
            if Member.MemberType ~= "Property" then
                continue
            end
            local TagsMap = {}
            for _, Tag in pairs(Member.Tags or {}) do
                TagsMap[Tag] = true
            end
            if TagsMap["ReadOnly"] or TagsMap["Hidden"] then
                continue
            end
            if Member.Security.Write ~= "None" then
                continue
            end
            if not Member.Serialization.CanSave then
                continue
            end

            --Add the type if it is not ingored.
            local TypeName = Member.ValueType.Name
            if Member.ValueType.Category == "DataType" and not IGNORED_TYPES[TypeName] then
                Types[TypeName] = true
            end
        end
    end

    --Determine the types that don't have serializers and deserializers.
    local MissingSerializers = {}
    local MissingDeserializers = {}
    for TypeName, _ in pairs(Types) do
        if not DataTypeSerializers[TypeName] then
            table.insert(MissingSerializers, TypeName)
        end
        if not DataTypeDeserializers[TypeName] then
            table.insert(MissingDeserializers, TypeName)
        end
    end
    if #MissingSerializers > 0 or #MissingDeserializers > 0 then
        error("DataType serializers or deserializers found:\n\tSerializers: "..HttpService:JSONEncode(MissingSerializers).."\n\tDeserializers: "..HttpService:JSONEncode(MissingDeserializers))
    end
end

--[[
Serializes a list of instances.
--]]
function Serialization:Serialize(Instances)
    --Create a list of instances to serialize.
    local CurrentIndex = 1
    local InstancesToSerialize = {}
    local InstancesToAddQueue = {}
    for _, Ins in pairs(Instances) do
        table.insert(InstancesToAddQueue, Ins)
    end
    while #InstancesToAddQueue > 0 do
        --Get the next instance and ignore it if it is not creatable or ignored.
        local Ins = table.remove(InstancesToAddQueue, 1)
        if IGNORED_INSTANCES[Ins.ClassName] or not ApiReference:IsCreateable(Ins.ClassName) then
            continue
        end

        --Add the instance and enqueue the children.
        InstancesToSerialize[Ins] = CurrentIndex
        CurrentIndex += 1
        for _, SubIns in pairs(Ins:GetChildren()) do
            table.insert(InstancesToAddQueue, SubIns)
        end
    end

    --Serialize the instances.
    local SerializedInstances = {}
    for Ins, Id in pairs(InstancesToSerialize) do
        --Create and store the base data.
        local SerializedInstance = {
            ClassName = Ins.ClassName
        }
        SerializedInstances[Id] = SerializedInstance

        --Serialize the properties.
        for _, Property in pairs(ApiReference:GetProperties(Ins.ClassName)) do
            local PropertyName = Property.Name
            local PropertyValue = Ins[PropertyName]
            local PropertyTypeName = Property.ValueType.Name
            local PropertyTypeCategory = Property.ValueType.Category
            if PropertyTypeCategory == "Enum" then
                PropertyValue = PropertyValue.Name
            elseif PropertyTypeCategory == "Class" then
                if PropertyValue then
                    PropertyValue = InstancesToSerialize[PropertyValue]
                end
            elseif PropertyTypeCategory == "DataType" then
                if PropertyValue then
                    PropertyValue = DataTypeSerializers[PropertyTypeName](PropertyValue)
                end
            end
            SerializedInstance[PropertyName] = PropertyValue
        end
    end

    --Return the serialized instances.
    return SerializedInstances
end

--[[
Deserializes a list of instances.
--]]
function Serialization:Deserialize(SerializedInstances)
    --Create the instances.
    local Instances = {}
    for i, SerializedInstance in pairs(SerializedInstances) do
        Instances[i] = Instance.new(SerializedInstance.ClassName)
    end

    --Set the properties.
    for i, SerializedInstance in pairs(SerializedInstances) do
        local Ins = Instances[i]
        for _, Property in pairs(ApiReference:GetProperties(Ins.ClassName)) do
            local PropertyName = Property.Name
            local PropertyValue = SerializedInstance[PropertyName]
            local PropertyTypeName = Property.ValueType.Name
            local PropertyTypeCategory = Property.ValueType.Category
            if PropertyValue then
                if PropertyTypeCategory == "Class" then
                    if PropertyValue then
                        PropertyValue = Instances[PropertyValue]
                    end
                elseif PropertyTypeCategory == "DataType" then
                    if PropertyValue then
                        PropertyValue = DataTypeDeserializers[PropertyTypeName](PropertyValue)
                    end
                end
                Ins[PropertyName] = PropertyValue
            end
        end
    end
    
    --Return the instances with no parents.
    local NoParentInstances = {}
    for _, Ins in pairs(Instances) do
        if Ins.Parent then continue end
        table.insert(NoParentInstances, Ins)
    end
    return NoParentInstances
end



return Serialization