if (AzVote.Addons && AzVote.Addons.Loaded && AzVote.Addons.Cleanup) then
    AzVote.Addons:Cleanup()
end

AzVote.Addons = {}
AzVote.Addons.Loaded = {}

local function _print(o, color)
    MsgC(color or Color(128, 255, 0), tostring(o) .. "\n");
end

function AzVote.Addons:LoadAddons()
    self.Loaded = {}

    local files = file.Find(AzVote.ScriptRoot .. "addons\\*.lua", "LSV")

    AzVote:PrintConsole("Loading addons...", "info")
    for k, v in pairs(files) do
        ADDON = {}

        include(string.format(AzVote.ScriptRoot .. "addons\\%s", v))

        if (!ADDON.Name) then
            _print(string.format(" > Couldn't load %s: missing name.", v), Color(255, 128, 0))
            continue
        end

        -- Should we even load it?
        local shouldload = true;
        if (!ADDON.ShouldLoad) then
            shouldload = false;
        elseif (type(ADDON.ShouldLoad) == "boolean") then
            shouldload = ADDON.ShouldLoad;
        elseif (type(ADDON.ShouldLoad) == "function") then
            shouldload = ADDON.ShouldLoad();
        end
        if (!shouldload) then
            continue
        end

        -- Check for duplicates
        local duplicate = false
        for kk, vv in pairs(self.Loaded) do
            if (ADDON.Name == vv.Name) then
                duplicate = true;
                break;
            end
        end
        if (duplicate) then
            _print(string.format(" > Couldn't load %s: duplicate name with %s.", v, vv.ScriptFile), Color(255, 128, 0))
        end

        -- And if successful, add it.
        ADDON.ScriptFile = v

        _print(string.format(" > Addon loaded: %s", ADDON.Name))
        table.insert(self.Loaded, ADDON)
    end
    ADDON = nil
    print("")
    for k, v in pairs(self.Loaded) do
        if (v.Init) then
            v:Init()
        end
    end
end

-- Finalize is mostly used for debugging purposes. 
-- Cleanup shouldn't ever be called mid-game.
function AzVote.Addons:Cleanup()
    for k, v in pairs(self.Loaded) do
        if (v.Finalize) then
            v:Finalize()
        end
    end
end

function AzVote.Addons:HandleChangelevel(map, mode, time, forced)
    forced = forced or false
    time = time or AzVote.Config.TimeToChange

    local handled = false
    for k, v in pairs(self.Loaded) do
        if (v.Changelevel) then
            if (v.Changelevel) then
                handled = v:Changelevel(map, mode, time, forced)
            end
        end
    end
    return handled
end