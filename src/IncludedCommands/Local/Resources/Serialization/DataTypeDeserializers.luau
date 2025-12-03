--Deserializers for DataTypes.
--!strict

return {
    ["Axes"] = function(Data)
        local AxesEnums = {}
        for _, EnunName in Data do
            table.insert(AxesEnums, (Enum.Axis :: any)[EnunName])
        end
        return Axes.new(unpack(AxesEnums))
    end,
    ["BrickColor"] = function(Data)
        return BrickColor.new(Data)
    end,
    ["Color3"] = function(Data)
        return Color3.new(unpack(Data))
    end,
    ["ColorSequence"] = function(Data)
        local Keypoints = {}
        for _, KeypointData in Data do
            table.insert(Keypoints, ColorSequenceKeypoint.new(KeypointData[1], Color3.new(KeypointData[2], KeypointData[3], KeypointData[4])))
        end
        return ColorSequence.new(Keypoints)
    end,
    ["CFrame"] = function(Data)
        return CFrame.new(unpack(Data))
    end,
    ["Faces"] = function(Data)
        local FaceEnums = {}
        for _, EnunName in Data do
            table.insert(FaceEnums, (Enum.NormalId :: any)[EnunName])
        end
        return Faces.new(unpack(FaceEnums))
    end,
    ["NumberRange"] = function(Data)
        return NumberRange.new(Data[1], Data[2])
    end,
    ["NumberSequence"] = function(Data)
        local Keypoints = {}
        for _, KeypointData in Data do
            table.insert(Keypoints, NumberSequenceKeypoint.new(KeypointData[1], KeypointData[2], KeypointData[3]))
        end
        return NumberSequence.new(Keypoints)
    end,
    ["PhysicalProperties"] = function(Data)
        return PhysicalProperties.new(unpack(Data))
    end,
    ["Ray"] = function(Data)
        return Ray.new(Vector3.new(Data[1], Data[2], Data[3]), Vector3.new(Data[4], Data[5], Data[6]))
    end,
    ["Rect"] = function(Data)
        return Rect.new(unpack(Data))
    end,
    ["UDim"] = function(Data)
        return UDim.new(unpack(Data))
    end,
    ["UDim2"] = function(Data)
        return UDim2.new(unpack(Data))
    end,
    ["Vector2"] = function(Data)
        return Vector2.new(unpack(Data))
    end,
    ["Vector3"] = function(Data)
        return Vector3.new(unpack(Data))
    end,
    ["Vector3int16"] = function(Data)
        return Vector3int16.new(unpack(Data))
    end,
} :: {[string]: (any) -> (any)}