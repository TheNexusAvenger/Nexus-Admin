--Serializes and deserializes instances.
--!strict

local DIRECT_SERIALIZE_TYPES = {
    boolean = true,
    EnumItem = true,
    number = true,
    string = true,
}
local IGNORED_TYPES = {
    Content = true,
    Font = true,
    SecurityCapabilities = true,
}
local IGNORED_INSTANCES = {
    Script = true,
    LocalScript = true,
    ModuleScript = true,
}
local DEPENDENT_PROPERTIES = {
    CanvasPosition = true,
} :: {[string]: boolean}

local HttpService = game:GetService("HttpService")
local ReflectionService = game:GetService("ReflectionService")

local DataTypeSerializers = require(script:WaitForChild("DataTypeSerializers"))
local DataTypeDeserializers = require(script:WaitForChild("DataTypeDeserializers"))

local Serialization = {}
Serialization._CanCreateCache = {} :: {[string]: boolean}
Serialization._PropertiesCache = {} :: {[string]: {PropertiesEntry}}

export type Serialization = typeof(Serialization)
type PropertiesEntry = {
    Name: string,
    Type: string,
}



--[[
Returns if an instance can be created.
--]]
function Serialization.CanCreate(self: Serialization, ClassName: string): boolean
    if self._CanCreateCache[ClassName] == nil then
        local ClassPermits = ReflectionService:GetClass(ClassName).Permits
        self._CanCreateCache[ClassName] = (ClassPermits ~= nil and ClassPermits.New ~= nil)
    end
    return self._CanCreateCache[ClassName]
end

--[[
Returns the properties for a class.
--]]
function Serialization.GetProperties(self: Serialization, ClassName: string): {PropertiesEntry}
    if not self._PropertiesCache[ClassName] then
        local Properties = {}
        for _, Property in ReflectionService:GetPropertiesOfClass(ClassName) do
            if not Property.Type.ScriptType then continue end
            if not Property.Permits or not Property.Permits.Read or not Property.Permits.Write then continue end
            table.insert(Properties, {
                Name = Property.Name,
                Type = Property.Type.ScriptType,
            })
        end
        self._PropertiesCache[ClassName] = Properties
    end
    return self._PropertiesCache[ClassName]
end

--[[
Checks that the needed DataType serializers and deserializers exist.
--]]
function Serialization.CheckSerializers(self: Serialization): ()
    --Get the types.
    local Types = {}
    for _, Class in ReflectionService:GetClasses() do
        if not Class.Permits or not Class.Permits.New then continue end
        for _, Property in ReflectionService:GetPropertiesOfClass(Class.Name) do
            if not Property.Permits or not Property.Permits.Read or not Property.Permits.Write then continue end
            local TypeName = Property.Type.ScriptType
            if not TypeName then continue end
            if TypeName == "Instance" then continue end
            if DIRECT_SERIALIZE_TYPES[TypeName] then continue end
            if IGNORED_TYPES[TypeName] then continue end
            Types[TypeName] = true
        end
    end

    --Determine the types that don't have serializers and deserializers.
    local MissingSerializers = {}
    local MissingDeserializers = {}
    for TypeName, _ in Types do
        if not DataTypeSerializers[TypeName] then
            table.insert(MissingSerializers, TypeName)
        end
        if not DataTypeDeserializers[TypeName] then
            table.insert(MissingDeserializers, TypeName)
        end
    end
    if #MissingSerializers > 0 or #MissingDeserializers > 0 then
        error(`DataType serializers or deserializers found:\n\tSerializers: {HttpService:JSONEncode(MissingSerializers)}\n\tDeserializers: {HttpService:JSONEncode(MissingDeserializers)}`)
    end
end

--[[
Serializes a list of instances.
--]]
function Serialization.Serialize(self: Serialization, Instances: {Instance}, ExcludeCallback: ((Instance) -> (boolean))?): {{[string]: any}}
    --Create a list of instances to serialize.
    local CurrentIndex = 1
    local InstancesToSerialize = {}
    local InstancesToAddQueue = {}
    for _, Ins in Instances do
        table.insert(InstancesToAddQueue, Ins)
    end
    while #InstancesToAddQueue > 0 do
        --Get the next instance and ignore it if it is not creatable or ignored.
        local Ins = table.remove(InstancesToAddQueue, 1) :: Instance
        if IGNORED_INSTANCES[Ins.ClassName] or not self:CanCreate(Ins.ClassName) then
            continue
        end
        if ExcludeCallback and ExcludeCallback(Ins) then
            continue
        end

        --Add the instance and enqueue the children.
        InstancesToSerialize[Ins] = CurrentIndex
        CurrentIndex += 1
        for _, SubIns in Ins:GetChildren() do
            table.insert(InstancesToAddQueue, SubIns)
        end
    end

    --Serialize the instances.
    local SerializedInstances = {}
    for Ins, Id in InstancesToSerialize do
        --Create and store the base data.
        local SerializedInstance = {
            ClassName = Ins.ClassName
        }
        SerializedInstances[Id] = SerializedInstance

        --Serialize the properties.
        for _, Property in self:GetProperties(Ins.ClassName) do
            local PropertyName = Property.Name
            local PropertyValue = (Ins :: any)[PropertyName]
            if PropertyValue == nil then continue end
            local PropertyType = Property.Type
            if PropertyType == "EnumItem" then
                PropertyValue = PropertyValue.Name
            elseif PropertyType == "Instance" then
                if PropertyValue then
                    PropertyValue = InstancesToSerialize[PropertyValue]
                end
            elseif not DIRECT_SERIALIZE_TYPES[PropertyType] then
                if PropertyValue then
                    if DataTypeSerializers[PropertyType] then
                        PropertyValue = DataTypeSerializers[PropertyType](PropertyValue)
                    elseif not IGNORED_TYPES[PropertyType] then
                        warn(`Unsupported property serialization type: {PropertyType}`)
                        PropertyValue = nil
                    end
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
function Serialization.Deserialize(self: Serialization, SerializedInstances: {{[string]: any}}): {Instance}
    --Create the instances.
    local Instances = {}
    for i, SerializedInstance in SerializedInstances do
        Instances[i] = Instance.new(SerializedInstance.ClassName)
    end

    --Set the properties.
    for i, SerializedInstance in SerializedInstances do
        --Determine the properties to set.
        local Ins = Instances[i]
        local Properties = {}
        for _, Property in self:GetProperties(Ins.ClassName) do
            local PropertyName = Property.Name
            local PropertyValue = SerializedInstance[PropertyName]
            local PropertyType = Property.Type
            if PropertyValue then
                if PropertyType == "Instance" then
                    if PropertyValue then
                        PropertyValue = Instances[PropertyValue]
                    end
                elseif not DIRECT_SERIALIZE_TYPES[PropertyType] then
                    if PropertyValue then
                        if DataTypeDeserializers[PropertyType] then
                            PropertyValue = DataTypeDeserializers[PropertyType](PropertyValue)
                        elseif not IGNORED_TYPES[PropertyType] then
                            warn(`Unsupported property deserialization type: {PropertyType}`)
                            PropertyValue = nil
                        end
                    end
                end
                Properties[PropertyName] = PropertyValue
            end
        end

        --Set the properties.
        --Some properties are dependent on others, so they are set twice.
        for PropertyName, PropertyValue in Properties do
            (Ins :: any)[PropertyName] = PropertyValue
        end
        for PropertyName, _ in DEPENDENT_PROPERTIES do
            if Properties[PropertyName] then
                (Ins :: any)[PropertyName] = Properties[PropertyName]
            end
        end
    end

    --Return the instances with no parents.
    local NoParentInstances = {}
    for _, Ins in Instances do
        if Ins.Parent then continue end
        table.insert(NoParentInstances, Ins)
    end
    return NoParentInstances
end



return Serialization