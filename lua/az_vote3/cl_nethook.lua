net.Receive( "AzVote Vote", function()
	local item = net.ReadString()
	local user = net.ReadEntity()

	AzVote.VoteTable = AzVote.VoteTable or {}
	AzVote.VoteTable[item] = AzVote.VoteTable[item] or {}

	AzVote:Exclude(user)

	table.insert(AzVote.VoteTable[item], user)

	AzVote.VoteGUI:AddVote(user, item)
end)

net.Receive( "AzVote Vote Exclusion", function()
	local user = net.ReadEntity()
	AzVote:Exclude(user)
end)

net.Receive( "AzVote Generic Countdown", function()
	AzVote.HUD.ShouldCircle = false
	
	local timeout = net.ReadInt(32)
	local nextmap = net.ReadString()
	local nextgamemode = net.ReadString()

	AzVote:ShowCountdown(timeout, nextmap, nextgamemode)
end)

net.Receive( "AzVote MapVote Start", function()
	AzVote.HUD.ShouldCircle = false
	
	local maps = net.ReadTable()
	local mask = net.ReadString()
	local header = net.ReadString()
	local timeout = net.ReadFloat()

	if (az_translatable(header)) then
		header = az_translate(header)
	end
	AzVote.VoteTable = {}
	for k, map in pairs(maps) do
		AzVote.VoteTable[map] = {}
	end

	AzVote:ShowMenu( maps, mask, header, timeout )
end)

net.Receive( "AzVote Generic HideMenu", function()
	AzVote:HideMenu()
end)

net.Receive( "AzVote Generic HideCountdown", function()
	AzVote:HideCountdown()
end)

net.Receive( "AzVote Generic HideEverything", function()
	AzVote:HideMenu()
	AzVote:HideCountdown()
end)

net.Receive( "AzVote Notify", function()
	local msg = net.ReadString()
	surface.PlaySound( Sound("ambient/creatures/pigeon_idle1.wav") )
	chat.AddText( Color( 255, 80, 80 ), "[RTV] ", Color( 220, 220, 220 ), msg )
end)

net.Receive( "AzVote Notify TL", function()
	local msg = net.ReadString()
	local args = net.ReadTable()
	
	msg = { az_translate(msg, unpack(args)) }

	surface.PlaySound(Sound("ambient/creatures/pigeon_idle1.wav") )
	chat.AddText( Color( 255, 80, 80 ), "[RTV] ", Color( 220, 220, 220 ), unpack(msg))
end)

net.Receive( "AzVote Reload", function()
	include("az_vote3/shared.lua")
	include("az_vote3/cl_init.lua")
end)

net.Receive( "AzVote PreVote", function()
	AzVote.HUD.ShouldCircle = true
end)