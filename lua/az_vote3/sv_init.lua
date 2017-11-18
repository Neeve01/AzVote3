AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_nethook.lua")
AddCSLuaFile("cl_hud.lua")

AddCSLuaFile("vgui/countdown.lua")
AddCSLuaFile("vgui/board.lua")
AddCSLuaFile("vgui/board_scaled.lua")
AddCSLuaFile("vgui/arc.lua")

----------------------------------------------------
 
include("shared.lua" ) 
include("sv_config.lua")
include("sv_mapvote.lua")
include("sv_gamemodevote.lua")
include("sv_nethook.lua")
include("sv_convar.lua")
include("sv_addons.lua")

----------------------------------------------------

AzVote.VoteTable = {}

----------------------------------------------------

function AzVote:ClearVotes()
	table.Empty( AzVote.VoteTable )
end

function AzVote:SetState( state )
	SetGlobalInt("AzVote State", state)
end 

function AzVote:PrintConsole(msg, level)
	level = level or "info";

	local color
	if (level == "error") then
		color = Color(255, 128, 0)
	else
		color = Color(255, 255, 255)
	end
	
	MsgC(Color(128, 255, 0), "[AzVote] ", color, tostring(msg) .. "\n");
end

function AzVote:CommenceChangelevel( map, mode, time, isforced )
	if (isforced) then
		AzVote:ChangelevelDelayed( map, mode, time )
	else
		local handled = AzVote.Addons:HandleChangelevel(map, mode, time, isforced)

		if (!handled) then
			AzVote:ChangelevelDelayed( map, mode, time )
		end
	end
end


function AzVote:ChangelevelDelayed( map, mode, time )
	self:BroadcastCountdown(CurTime() + time, map, mode)
	timer.Remove("AzVote ChangelevelTimer")
	
	timer.Create("AzVote ChangelevelTimer", time, 1, function()
		self:Changelevel( map, mode )
	end)
end

function AzVote:Changelevel( map, mode )
	if (self.CVar.PreventChange:GetBool()) then
		self:Cleanup()
		return
	end

	if (mode && type(mode) == "string" && mode:Trim() != "") then
		RunConsoleCommand("gamemode", mode:Trim() )
	end
	RunConsoleCommand("changelevel", map )
end

function AzVote:BuildMapsTable( prefixes ) 
	local maps = file.Find("maps/*.bsp", "GAME")
	local m = {}
	for i, map in pairs(maps) do
		map = map:gsub("%.bsp$", "")
		for j, prefix in pairs(prefixes) do
			if (string.sub(map, 1, #prefix) == prefix) then
				table.insert(m, map)
			end
		end
	end
	return m
end

function AzVote:TrimTable( t, count )
	while (#t > count) do
		table.remove(t, math.random(1, #t))
	end
end

function AzVote:SetVote( ply, item ) 
	for k, voteitem in pairs(AzVote.VoteTable) do
		for kk, voter in pairs(voteitem) do
			if (voter == ply:SteamID()) then
				table.remove(voteitem, kk)
			end
		end
	end
	if (!AzVote.VoteTable[item]) then
		return
	end
	
	table.insert(AzVote.VoteTable[item], ply:SteamID())
end

function AzVote:Reload()
	AzVote:Cleanup(true)

	net.Start("AzVote Reload")
	net.Broadcast()
	
	AzVote = nil
	SetGlobalBool("AzVote:ReloadRequested", true)
	include("az_vote3/shared.lua")
	include("az_vote3/sv_init.lua")
end 

function AzVote:Cleanup(silent)	
	self:ClearVotes()
	self.Addons:Cleanup()
	
	AzVote.MapVote:Cleanup()
	
	if (self:GetState() == AZVOTE_STATE_VOTING) then
		self:BroadcastTL( "azvote.cancel.restart" )
		
		net.Start( "AzVote Generic HideEverything" )
		net.Broadcast() 
	end
	
	self:SetState(AZVOTE_STATE_NONE)
	
	if (!silent) then
		self:PrintConsole("Cleaning up.")
	end
end

function AzVote:Init()
	AzVote.ScriptRoot = "az_vote3\\";
	AzVote.Addons:LoadAddons()
end

-- Handle reload
if (GetGlobalBool("AzVote:ReloadRequested")) then
	AzVote.Inited = true
end

if (AzVote.Inited) then 
	AzVote:Cleanup(true)
	AzVote:Init()
end

if (GetGlobalBool("AzVote:ReloadRequested")) then
	SetGlobalBool("AzVote:ReloadRequested", false)
	AzVote:PrintConsole("Successfully reloaded.")
end

--[[
	Hooks
]]-- 

hook.Add("Initialize", "AzVote Initialization", function()
	AzVote.Inited = true
	
	AzVote:Init()
end)

--[[ dead code ahead
hook.Add("PlayerDisconnected", "AzVote PlayerDisconnect", function()
	AzVote:CheckRTV()
	AzVote:CheckGamemodeRTV()
	
	SetGlobalInt("AzVote RTV Needed", math.ceil(#player.GetAll() * AzVote.Config.RTVRatio))
	SetGlobalInt("AzVote GamemodeRTV Needed", math.ceil(#player.GetAll() * AzVote.Config.RTVRatio))
end)

hook.Add("PlayerConnected", "AzVote PlayerConnect", function()
	AzVote:CheckRTV()
	AzVote:CheckGamemodeRTV()
	
	SetGlobalInt("AzVote RTV Needed", math.ceil(#player.GetAll() * AzVote.Config.RTVRatio))
	SetGlobalInt("AzVote GamemodeRTV Needed", math.ceil(#player.GetAll() * AzVote.Config.RTVRatio))
end) ]]