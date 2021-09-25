--[[
TheNexusAvenger

Utility function for finding tools given a search string.
--]]

return function(SearchString,Containers)
    --Search the containers for tools.
    local Tools = {}
    string.gsub(SearchString,"([^%,]+)",function(ToolName)
        for _,Container in pairs(Containers) do
            for _,Tool in pairs(Container:GetChildren()) do
                if Tool:IsA("Tool") or Tool:IsA("HopperBin") then
                    if ToolName == "all" then
                        table.insert(Tools,Tool)
                    elseif string.sub(string.lower(Tool.Name),1,string.len(ToolName)) == string.lower(ToolName) then
                        table.insert(Tools,Tool)
                    end
                end
            end
        end
    end)

    --Return the tools.
    return Tools
end