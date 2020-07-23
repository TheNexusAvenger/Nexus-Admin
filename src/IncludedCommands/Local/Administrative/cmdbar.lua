--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("cmdbar","Administrative","Brings up the command line. Alternative to pressing \\.")

    self.Prefix = {"!",self.API.Configuration.CommandPrefix}

    --Update the command bar access.
    self.API.Authorization.AdminLevelChanged:Connect(function(Player,_)
        if self.Players.LocalPlayer == Player then
            self:UpdateCommandBarEnabled()
        end
    end)

    -- If the Cmdr command bar feature flag is changed, update the player permission.
    self.API.FeatureFlags:GetFeatureFlagChangedEvent("UseCmdrCommandBar"):Connect(function(enabled)
        self:UpdateCommandBarEnabled()
    end)

    self:UpdateCommandBarEnabled()
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext)
    self.super:Run(CommandContext)
    
    if self.API.FeatureFlags:GetFeatureFlag("UseCmdrCommandBar") then
        self.API.Cmdr:Toggle()
    else
        return "The Cmdr command bar has been disabled."
    end
end

--[[
Updates if the command bar is enabled.
--]]
function Command:UpdateCommandBarEnabled()
    if self.API.FeatureFlags:GetFeatureFlag("UseCmdrCommandBar") then
        self.API.Cmdr:SetEnabled(self.API.Authorization:IsPlayerAuthorized(self.Players.LocalPlayer,self.AdminLevel))
    else
        self.API.Cmdr:SetEnabled(false)
    end
end



return Command