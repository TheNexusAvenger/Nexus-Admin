--[[
TheNexusAvenger

Loads Nexus Admin.

Loader version: V.2.7.14
GitHub: https://github.com/thenexusavenger/nexus-admin

For the change log, view the GitHub Releases (except V.1.0.0, V.1.0.1, V.1.1.0, and V.1.2.0).
For adding custom commands, view the GitHub documentation.
For bugs or feature requests (including new commands), use the GitHub Issues.
--]]

local Config = {
    --Prefix for standard commands.
    CommandPrefix = ":",

    --Keybinds for opening the command bar.
    --WARNING: Keybinds that are set here become unusable in the command bar.
    ActivationKeys = {Enum.KeyCode.F2,},

    --Default rank a new player would have.
    DefaultAdminLevel = -1,

    --This is for setting up other admins in your game. You don't need to add yourself as long as you are the owner
    --[[
    Set up:
    Admins = {
        [SomeId] = AdminLevel,
        [261] = 4,
        [1] = 3,
        [99] = 1,
        [6] = 2,
    }
    --]]
    Admins = {

    },

    --This is for setting up certain ranks in a group being able to use certain levels of commands.
    --You will need to have access to the roles in the group admin page for the rank ids.
    --Each rank will default to the highest admin level
    --[[
    Set up:
    GroupAdminLevels = {
        [GroupId] = {
            [RankId] = 2,
            [RankId] = 3,
            [RankId] = 4,
        },
        [1] = {
            [10] = 1,
            [15] = 5,
        },
        [12] = {
            [100] = 1,
            [150] = 5,
        },
        ... (You can add/remove groups)
    },    
    
    --]]
    GroupAdminLevels = {

    },

    --Banned users is for preventing certain users from entering the game.
    --Setting an id equal to true doesn't give a message, and a string is the ban message.
    --[[
    Set up:
    BannedUsers = {
        [UserId] = true, --Banned without a ban message
        [UserId] = "Some Ban Message", --Bans with a ban message
        [1] = "Banned for being ROBLOX",
        [261] = true, --Too awesome to have a ban message
    }
    --]]
    BannedUsers = {

    },

    --The names of the admin levels.
    AdminNames = {
        [-1] = "Non-Admin", --Basic commands, like !help and !quote
        [0] = "Debug Admin", --Only debug commands
        [1] = "Moderator", --Some commands, can't kick, no "fun" commands
        [2] = "Admin", --Most commands, can't ban or shutdown
        [3] = "Super Admin",--All commands, can be kicked by full admin
        [4] = "Owner Admin", --All commands, except :admin
        [5] = "Creator Admin", --All commands, including :admin
    },

    --Default admin levels needed to use a set of default commands.
    AdministrativeLevel = 1,
    BuildUtilityLevel = 1,
    BasicCommandsLevel = 1,
    UsefulFunCommandsLevel = 2,
    FunCommandsLevel = 3,
    PersistentCommandsLevel = 4,
    
    --Configurations for internal commands.
    --If a value is nil, it will default to the command's default setting.
    --If a value is not nil, the setting will override the default setting.
    CommandConfigurations = {
        --Default Admin Level for Server Lock (slock). Defaults to 0, but can be any number.
        DefaultServerLockAdminLevel = nil,
    },

    --Below is for overriding the defaults levels
    --If a value is nil, it will default to the default command level of the group
    --If a value is a number, it will override the default command level of the group
    --This can be useful to make an abusive command un-usable or make a useful command usable.
    CommandLevelOverrides = {
        Administrative = {
            admin = 5,
            unadmin = 5,
            ban = 3,
            unban = 3,
            kick = 2,
            slock = 2,
            keybind = -1,
            unkeybind = -1,
            keybinds = -1,
            alias = -1,
            cmds = -1,
            cmdbar = 0,
            debug = 0,
            localdebug = nil,
            system = nil,
            snapshot = nil,
            checkconsistency = nil,
            characterhistory = nil,
            logs = 0,
            admins = 0,
            bans = nil,
            usage = -1,
            featureflag = nil,
            featureflags = nil,
            featureflaglogs = nil,
        },
        BasicCommands = {
            vote = nil,
            pchat = nil,
            track = nil,
            untrack = nil,
            chatlogs = nil,
            killlogs = nil,
            joinlogs = nil,
            batch = nil,
            delay = nil,
            loop = nil,
            stoploops = nil,
            playerstep = nil,
            m = nil,
            h = nil,
            pm = nil,
            ph = nil,
            sm = nil,
            sh = nil,
            mute = nil,
            unmute = nil,
            crash = nil,
            shutdown = nil,
            countdown = nil,
            stopcountdown = nil,
            age = nil,
            refresh = nil,
            clean = nil,
            punish = nil,
            respawn = nil,
            team = nil,
            tools = nil,
            give = nil,
            startergive = nil,
            startertool = nil,
            sword = nil,
            atksword = nil,
            removetools = nil,
            resetstats = nil,
            change = nil,
            gear = nil,
            inventory = nil,
            createteam = nil,
            removeteam = nil,
            renameteam = nil,
            sortteams = nil,
        },
        BuildUtility = {
            clearterrain = nil,
            fixlighting = nil,
            time = nil,
            brightness = nil,
            ambient = nil,
            outdoorambient = nil,
            fogcolor = nil,
            fogend = nil,
            fogstart = nil,
            shadows = nil,
            btools = nil,
            s = nil,
            insert = nil,
        },
        UsefulFunCommands = {
            name = nil,
            unname = nil,
            ff = nil,
            unff = nil,
            kill = nil,
            damage = nil,
            heal = nil,
            health = nil,
            god = nil,
            ungod = nil,
            walkspeed = nil,
            place = nil,
            tp = nil,
            to = nil,
            bring = nil,
            where = nil,
            tpto = nil,
            thru = nil,
            flip = nil,
            stun = nil,
            unstun = nil,
            jump = nil,
            sit = nil,
            unsit = nil,
            lock = nil,
            unlock = nil,
            clone = nil,
            explode = nil,
            view = nil,
            jail = nil,
            unjail = nil,
            fling = nil,
            grav = nil,
            setgrav = nil,
            fly = nil,
            unfly = nil,
            collide = nil,
            uncollide = nil,
        },
        FunCommands = {
            removehats = nil,
            play = nil,
            volume = nil,
            pause = nil,
            resume = nil,
            stop = nil,
            blind = nil,
            unblind = nil,
            char = nil,
            unchar = nil,
            hat = nil,
            disco = nil,
            spin = nil,
            unspin = nil,
            freeze = nil,
            thaw = nil,
            invisible = nil,
            visible = nil,
            light = nil,
            unlight = nil,
            fire = nil,
            unfire = nil,
            smoke = nil,
            unsmoke = nil,
            sparkles = nil,
            unsparkles = nil,
            face = nil,
            rocket = nil,
            unrocket = nil,
            vibrate = nil,
            unvibrate = nil,
        },
        PersistentCommands = {
            pban = nil,
            unpban = nil,
            pbans = nil,
        },
    },

    --Overrides for features as part of Nexus Admin. Most likely, you will
    --not have to change anything; it is meant for developer use.
    FeatureFlagOverrides = {

    },
}










--This is where the actual loading happens. Feel free to use this in another script
--Doubt you will need to, but here it is.
xpcall(function()
    --Require the development module from ServerScriptService.
    local NexusAdminModule
    for _,Module in pairs(game:GetService("ServerScriptService"):GetChildren()) do
        if Module:IsA("ModuleScript") and Module:FindFirstChild("NexusAdmin") then
            NexusAdminModule = require(Module)
            break
        end
    end

    --Require the Roblox module if there isn't a development one in ServerScriptService.
    if NexusAdminModule == nil then
        NexusAdminModule = require(386507112)
    end

    --Load Nexus admin.
    NexusAdminModule(script,Config)
end, function(ErrorMessage: string)
    warn("NEXUS ADMIN FAILED TO LOAD: "..tostring(ErrorMessage).."\n"..debug.traceback())
end)
