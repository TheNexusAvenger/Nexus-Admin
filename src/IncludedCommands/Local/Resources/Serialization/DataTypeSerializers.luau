--Serializers for DataTypes.
--!strict

return {
    ["Axes"] = function(Data: Axes)
        local AxesStrings = {}
        if Data.X then
            table.insert(AxesStrings, "X")
        end
        if Data.Y then
            table.insert(AxesStrings, "Y")
        end
        if Data.Z then
            table.insert(AxesStrings, "Z")
        end
        return AxesStrings
    end,
    ["BrickColor"] = function(Data: BrickColor)
        return Data.Name
    end,
    ["Color3"] = function(Data: Color3)
        return {Data.R, Data.G, Data.B}
    end,
    ["ColorSequence"] = function(Data: ColorSequence)
        local SerializedPoints = {}
        for _, Keypoint: ColorSequenceKeypoint in Data.Keypoints do
            table.insert(SerializedPoints, {Keypoint.Time, Keypoint.Value.R, Keypoint.Value.G, Keypoint.Value.B})
        end
        return SerializedPoints
    end,
    ["CFrame"] = function(Data: CFrame)
        return {Data:GetComponents()}
    end,
    ["Faces"] = function(Data: Faces)
        local FacesStrings = {}
        if Data.Top then
            table.insert(FacesStrings, "Top")
        end
        if Data.Bottom then
            table.insert(FacesStrings, "Bottom")
        end
        if Data.Front then
            table.insert(FacesStrings, "Front")
        end
        if Data.Bottom then
            table.insert(FacesStrings, "Bottom")
        end
        if Data.Left then
            table.insert(FacesStrings, "Left")
        end
        if Data.Right then
            table.insert(FacesStrings, "Right")
        end
        return FacesStrings
    end,
    ["NumberRange"] = function(Data: NumberRange)
        return {Data.Min, Data.Max}
    end,
    ["NumberSequence"] = function(Data: NumberSequence)
        local SerializedPoints = {}
        for _, Keypoint: NumberSequenceKeypoint in Data.Keypoints do
            table.insert(SerializedPoints, {Keypoint.Time, Keypoint.Value, Keypoint.Envelope})
        end
        return SerializedPoints
    end,
    ["PhysicalProperties"] = function(Data: PhysicalProperties)
        return {Data.Density, Data.Friction, Data.Elasticity, Data.FrictionWeight, Data.ElasticityWeight}
    end,
    ["Ray"] = function(Data: Ray)
        return {Data.Origin.X, Data.Origin.Y, Data.Origin.Z, Data.Direction.X, Data.Direction.Y, Data.Direction.Z}
    end,
    ["Rect"] = function(Data: Rect)
        return {Data.Min.X, Data.Min.Y, Data.Max.X, Data.Max.Y}
    end,
    ["UDim"] = function(Data: UDim)
        return {Data.Scale, Data.Offset}
    end,
    ["UDim2"] = function(Data: UDim2)
        return {Data.X.Scale, Data.X.Offset, Data.Y.Scale, Data.Y.Offset}
    end,
    ["Vector2"] = function(Data: Vector2)
        return {Data.X, Data.Y}
    end,
    ["Vector3"] = function(Data: Vector3)
        return {Data.X, Data.Y, Data.Z}
    end,
}