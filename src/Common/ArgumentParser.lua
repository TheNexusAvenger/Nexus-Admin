--[[
TheNexusAvenger

Legacy code for parsing arguments. The code has been fitted
to use the new API locations, but does not have full unit
tests.
--]]

local ArgumentParser = {}

local PlayerMap = {}
local AllUniquePlayers = {}
game:GetService("Players").PlayerAdded:Connect(function(Player)
    if PlayerMap[Player.Name] == nil then
        PlayerMap[Player.Name] = Player
        
        local Players = {}
        for _,Player in pairs(PlayerMap) do
            table.insert(Players,Player)
        end
        AllUniquePlayers = Players
    end
end)



function ArgumentParser:CreateParser(BaseString,ReferencePlayer)
    local CurrentPoint = 1
    local SplitStrings = {}
    
    local function FilterString(String)
        return _G.GetNexusAdminServerAPI().Filter:FilterString(String,ReferencePlayer)
    end
    
    
    
    string.gsub(BaseString,"([^%s]+%s*)",function(SubString)
        table.insert(SplitStrings,SubString)
    end)
    
    local function SetPointer(NewPoint)
        if type(NewPoint) ~= "number" then
            NewPoint = CurrentPoint
        end
        NewPoint = math.floor(NewPoint)
        
        if NewPoint < 1 then
            NewPoint = 1
        end
        if NewPoint > #SplitStrings then
            NewPoint = #SplitStrings + 1
        end
        
        CurrentPoint = NewPoint
    end
    
    local function GetNextElement()
        local NextElement = SplitStrings[CurrentPoint] or ""
        SetPointer(CurrentPoint + 1)
        return string.match(NextElement,"([^%s]+)") or ""
    end
    
    
    
    local Parser = {}
    function Parser:ResetPointer()
        SetPointer(1)
    end
    
    function Parser:SetPointer(NewPoint)
        SetPointer(NewPoint)
    end
    
    function Parser:OffsetPointer(Offset)
        if type(Offset) ~= "number" then return end
        SetPointer(CurrentPoint + Offset)
    end
    
    function Parser:GetCurrentPointer()
        return CurrentPoint
    end
    
    function Parser:GetTotalArguments()
        return #SplitStrings
    end
    
    function Parser:HasNext()
        return CurrentPoint <= #SplitStrings
    end
    
    function Parser:GetNextNumber()
        local NextElement = GetNextElement()
        return tonumber(NextElement)
    end
    
    function Parser:GetNextNumbers()
        local NextElement = GetNextElement()
        local NumberArray = {}
        
        string.gsub(NextElement,"([^,]+)",function(SubString)
            local Number = tonumber(SubString)
            if Number then table.insert(NumberArray,Number) end
        end)
        
        return NumberArray
    end
    
    local function ConvertToBool(BoolString)
        if BoolString == "true" or BoolString == "t" or BoolString == "yes" or BoolString == "y" then
            return true
        elseif BoolString == "false" or BoolString == "f" or BoolString == "no" or BoolString == "n" then
            return false
        end
    end
    
    function Parser:GetNextBool()
        local NextElement = string.lower(GetNextElement())
        
        return ConvertToBool(NextElement)
    end
    
    function Parser:GetNextBools()
        local NextElement = string.lower(GetNextElement())
        local BoolArray = {}
        
        string.gsub(NextElement,"([^,]+)",function(SubString)
            local BoolElement = ConvertToBool(SubString)
            if BoolElement ~= nil then table.insert(BoolArray,BoolElement) end
        end)
        
        return BoolArray
    end
    
    function Parser:GetNextString(ApplyFilter)
        local NextElement = GetNextElement()
        if NextElement ~= "" then
            if ApplyFilter then
                return FilterString(NextElement)
            else
                return NextElement
            end
        end
    end
    
    function Parser:GetRemainder(ApplyFilter)
        local Remainder = ""
        
        for i = CurrentPoint, #SplitStrings do
            Remainder = Remainder..SplitStrings[i]
        end
        SetPointer(#SplitStrings + 1)
        
        if Remainder ~= "" then
            if ApplyFilter then
                return FilterString(Remainder)
            else
                return Remainder
            end
        end
    end

    function Parser:GetNextPlayers(IncludeDisconnected)
        local NextElement = GetNextElement()
        local BasePlayers = game:GetService("Players"):GetPlayers()
        local AllPlayers = (IncludeDisconnected and AllUniquePlayers or BasePlayers)
        local PlayersLeft = game:GetService("Players"):GetPlayers()
        local ReturnPlayers = {}
        
        local function AddPlayer(Player)
            for i,OtherPlayer in pairs(PlayersLeft) do
                if Player == OtherPlayer then
                    table.remove(PlayersLeft,i)
                    break
                end
            end
            
            table.insert(ReturnPlayers,Player)
        end
        
        local function RemovePlayer(Player)
            for i,OtherPlayer in pairs(ReturnPlayers) do
                if Player == OtherPlayer then
                    table.remove(ReturnPlayers,i)
                    break
                end
            end
            
            table.insert(PlayersLeft,Player)
        end
        
        local PlayerArguments = {}
        string.gsub(NextElement,"([^,]+)",function(PlayerString)
            table.insert(PlayerArguments,PlayerString)
        end)
        
        for _,PlayerString in pairs(PlayerArguments) do
            local Remove = (string.sub(PlayerString,1,1) == "-")
            if Remove then PlayerString = string.sub(PlayerString,2) end
            
            local function ApplyPlayer(Player)
                if Remove then
                    RemovePlayer(Player)
                else
                    AddPlayer(Player)
                end
            end            
            
            local LowerPlayerString = string.lower(PlayerString)
            local FirstCharacter = string.sub(PlayerString,1,1)
            if FirstCharacter == "%" then
                local TeamName = string.lower(string.sub(PlayerString,2))
                local TeamNameLength = string.len(TeamName)
                
                local Teams = game:GetService("Teams"):GetTeams()
                for _,Team in pairs(Teams) do
                    if string.sub(string.lower(Team.Name),1,TeamNameLength) == TeamName then
                        for _,Player in pairs(Team:GetPlayers()) do
                            ApplyPlayer(Player)
                        end
                    end
                end
            elseif FirstCharacter == "$" then
                local GroupId = tonumber(string.sub(PlayerString,2))
                
                if GroupId then
                    for _,Player in pairs(BasePlayers) do
                        local Worked,Return = pcall(function() return Player:GetRankInGroup(GroupId) end)
                        if Worked == true and Return and Return > 0 then
                            ApplyPlayer(Player)
                        end
                    end
                end
            elseif PlayerString == "admins" then
                for _,Player in pairs(BasePlayers) do
                    if _G.GetNexusAdminServerAPI().Authorization.GetAdminLevel(Player) > -1 then
                        ApplyPlayer(Player)
                    end
                end
            elseif PlayerString == "nonadmins" then
                for _,Player in pairs(BasePlayers) do
                    if _G.GetNexusAdminServerAPI().Authorization.GetAdminLevel(Player) <= -1 then
                        ApplyPlayer(Player)
                    end
                end
            elseif PlayerString == "random" then
                if #BasePlayers == 1 then
                    ApplyPlayer(BasePlayers[1])
                elseif #BasePlayers >= 1 then
                    ApplyPlayer(BasePlayers[math.random(1,#BasePlayers)])
                end
            elseif PlayerString == "urandom" then
                if #PlayersLeft == 1 then
                    ApplyPlayer(PlayersLeft[1])
                elseif #PlayersLeft >= 1 then
                    ApplyPlayer(PlayersLeft[math.random(1,#PlayersLeft)])
                end
            elseif PlayerString == "me" then
                if ReferencePlayer then
                    ApplyPlayer(ReferencePlayer)
                end
            elseif PlayerString == "others" then
                for _,Player in pairs(AllPlayers) do
                    if Player ~= ReferencePlayer then
                        ApplyPlayer(Player)
                    end
                end
            elseif LowerPlayerString == "all" then
                for _,Player in pairs(AllPlayers) do
                    ApplyPlayer(Player)
                end
            else
                local PlayerName = string.lower(PlayerString)
                local PlayerNameLength = string.len(PlayerString)
                
                for _,Player in pairs(AllPlayers) do
                    if string.sub(string.lower(Player.Name),1,PlayerNameLength) == PlayerName then
                        ApplyPlayer(Player)
                    end
                end
            end
        end
        
        return ReturnPlayers
    end
    
    return Parser
end

function ArgumentParser:StringToArguments(String,ArguementTypes,PlayerSaidBy,IgnoreFilter)
    local Parser = ArgumentParser:CreateParser(String,PlayerSaidBy)
    local FilterStrings = (IgnoreFilter ~= true)
    local Arguments = {}
    
    local function GetArgument(ArgumentType)
        if ArgumentType == "Number" then
            return Parser:GetNextNumber()
        elseif ArgumentType == "TableOfNumbers" then
            return Parser:GetNextNumbers()
        elseif ArgumentType == "String" then
            return Parser:GetNextString(FilterStrings)
        elseif ArgumentType == "LongString" then
            return Parser:GetRemainder()
        elseif ArgumentType == "Bool" or ArgumentType == "Boolean" then
            return Parser:GetNextBool()
        elseif ArgumentType == "TableOfPlayers" then
            return Parser:GetNextPlayers()
        elseif ArgumentType == "TableOfAllPlayersByName" then
            local Players = Parser:GetNextPlayers(true)
            for i,Player in pairs(Players) do
                Players[i] = Player.Name
            end
            return Players
        elseif ArgumentType == "TableOfAllPlayersById" then
            local Players = Parser:GetNextPlayers(true)
            for i,Player in pairs(Players) do
                Players[i] = Player.UserId
            end
            return Players
        elseif ArgumentType == "Color3" then
            local Colors = Parser:GetNextNumbers()
            if #Colors >= 3 then
                return Color3.new(Colors[1]/255,Colors[2]/255,Colors[3]/255)
            end
        elseif ArgumentType == "Vector3" then
            local Coordinates = Parser:GetNextNumbers()
            if #Coordinates >= 3 then
                return Color3.new(Coordinates[1],Coordinates[2],Coordinates[3])
            end
        end
    end
    
    for i,ArgumentType in pairs(ArguementTypes or {}) do
        if type(ArgumentType) == "table" then
            for _,SubArgumentType in pairs(ArgumentType) do
                local NextArgument = GetArgument(SubArgumentType)
                if NextArgument then
                    Arguments[i] = NextArgument                    
                    break
                else
                    Parser:OffsetPointer(-1)
                end
            end
        else
            Arguments[i] = GetArgument(ArgumentType)
        end
    end
    
    return Arguments
end



return ArgumentParser