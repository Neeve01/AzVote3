util.AddNetworkString( "AzVote MapVote Start" )
util.AddNetworkString( "AzVote PreVote" )

util.AddNetworkString( "AzVote Vote BoardClose" )
util.AddNetworkString( "AzVote Vote Exclusion" )
util.AddNetworkString( "AzVote Vote Finish" )
util.AddNetworkString( "AzVote Vote" )

util.AddNetworkString( "AzVote Generic HideMenu" )
util.AddNetworkString( "AzVote Generic HideCountdown" )
util.AddNetworkString( "AzVote Generic HideEverything" )

util.AddNetworkString( "AzVote Generic Countdown" )

util.AddNetworkString( "AzVote Notify" )
util.AddNetworkString( "AzVote Notify TL" )
		
util.AddNetworkString( "AzVote Reload" )

net.Receive( "AzVote Vote", function( len, ply )
	local item = net.ReadString()

	AzVote:SetVote( ply, item )
	AzVote:BroadcastVote( ply, item )
end)

net.Receive( "AzVote BoardClose", function( len, ply )
	SetGlobalInt((GetGlobalInt("AzVote VotersCount") or 0) - 1)
end)

function AzVote:BroadcastVote( ply, item )
	net.Start( "AzVote Vote" )
		net.WriteString( item )
		net.WriteEntity( ply )
	net.Broadcast()
end

function AzVote:BroadcastExclusion( ply )
	net.Start( "AzVote Generic Exclusion" )
		net.WriteEntity( ply )
	net.Broadcast()
end

function AzVote:BroadcastPreVote()
	net.Start( "AzVote PreVote" )
	net.Broadcast()
end

function AzVote:BroadcastVoteFinish()
	net.Start( "AzVote Generic HideMenu" )
	net.Broadcast()
end

function AzVote:BroadcastCountdown( time, map, gamemode )
	net.Start( "AzVote Generic Countdown" )
		net.WriteInt( time, 32 )
		net.WriteString( map or "" )
		net.WriteString( gamemode or "" )
	net.Broadcast()
end

local PLAYER = FindMetaTable("Player")

function AzVote:Broadcast( str )
	net.Start("AzVote Notify")
		net.WriteString( str )
	net.Broadcast()
end

function AzVote:BroadcastTL( key, ... )
	net.Start("AzVote Notify TL")
		net.WriteString(key)
		net.WriteTable({...})
	net.Broadcast()
end

function PLAYER:AVNotify( str )
	net.Start("AzVote Notify")
		net.WriteString( str )
	net.Send(self)
end

function PLAYER:AVNotifyTL( key, ... )
	net.Start("AzVote Notify TL")
		net.WriteString(key)
		net.WriteTable({...})
	net.Send(self)
end