--[[
TheNexusAvenger

Filters strings to comply with Roblox's filtering rules.
--]]
--!strict

local Types = require(script.Parent.Parent:WaitForChild("Types"))

local Filter = {}
Filter.__index = Filter



--[[
Creates a filter instance.
--]]
function Filter.new(): Types.Filter
    return (setmetatable({
        TextService = game:GetService("TextService"),
        Chat = game:GetService("Chat"),
    }, Filter) :: any) :: Types.Filter
end

--[[
Escapes a string for rich text.
--]]
function Filter:EscapeRichText(String: string): string
    while true do
        local NewString, _ = string.gsub(String, "<([^/>]+)>([^<]+)</([^>]+)>", function(StartTag: string, Contents: string, EndTag: string): string
            local StartTagStart = string.match(StartTag, "^[^%s]+")
            local EndTagStart = string.match(EndTag, "^[^%s]+")
            if StartTagStart and EndTagStart and string.lower(StartTagStart) == string.lower(EndTagStart) then
                return "&lt;"..StartTag.."&gt;"..Contents.."&lt;/"..EndTag.."&gt;"
            end
            return "<"..StartTag..">"..Contents.."</"..EndTag..">"
        end :: any)
        if NewString == String then break end
        String = NewString
    end
    local NewString, _ = string.gsub(String, "<[^/]+/>", "&lt;&1/&gt;")
    return NewString
end



return (Filter :: any) :: Types.Filter