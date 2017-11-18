AzVote.MapVote = {}
AzVote.MapVote.DisableTime = AzVote.MapVote.DisableTime or 0
AzVote.MapVote.RTVVoters = AzVote.MapVote.RTVVoters or {}

function AzVote.MapVote:Cleanup()
	if (timer.Exists("AzVote MapVote RTV Cleanse")) then
		timer.Destroy("AzVote MapVoteCleanse")
	end
	
	if (timer.Exists("AzVote MapVote Finish")) then
		timer.Destroy("AzVote FinishMapVote") 
	end
	
	if (timer.Exists("AzVote MapVote PreVote")) then
		timer.Destroy("AzVote MapVote PreVote")
	end
	
	if (timer.Exists("AzVote MapVote Change")) then
		timer.Destroy("AzVote MapVote Change")
	end

	AzVote.MapVote.DisableTime = 0
	AzVote.MapVote.RTVVoters = {}
end

function AzVote.MapVote:CleanupRTV()
	local players = player.GetAll()
	for k, voter in pairs(self.RTVVoters) do
		local found
		
		for _, ply in pairs(players) do
			if (voter == ply:SteamID()) then
				found = true
				break
			end
		end
		
		if (!found) then
			table.remove(self.RTVVoters, k)
		end
	end
end

function AzVote.MapVote:CheckRTV()
	if (AzVote:GetState() != AZVOTE_STATE_NONE) then
		return false
	end

	if (math.ceil(#player.GetAll() * AzVote.Config.RTVRatio) <= 0) then
		return false
	end

	return (#self.RTVVoters >= math.ceil(#player.GetAll() * AzVote.Config.RTVRatio))
end

function AzVote.MapVote:StartMapVote( maps, forced )
	AzVote:SetState(AZVOTE_STATE_VOTING)
	
	timer.Destroy("AzVote MapVote CleanseRTV")
	
	-- pause gamemode rtv here
	
	AzVote:BroadcastPreVote()
		
	timer.Create("AzVote MapVote PreVote", 2, 1, function()
		net.Start( "AzVote MapVote Start" )
			net.WriteTable( maps )
			net.WriteString( "maps/thumb/%s.png" )
			net.WriteString( "Vote for next map!" )
			net.WriteFloat( CurTime() + AzVote.Config.VotingTime )
		net.Broadcast()
		
		-- Setup vote table
		table.Empty(AzVote.VoteTable)
		for k, v in pairs(maps) do
			AzVote.VoteTable[v] = {}
		end
		
		timer.Create("AzVote MapVote Finish", AzVote.Config.VotingTime, 1, function()
			AzVote:SetState( AZVOTE_STATE_NONE )
			AzVote:BroadcastVoteFinish()
			-- unpause gamemode rtv here
			
			net.Start( "AzVote Vote Finish" )
			net.Broadcast()
	
			local maxVotes, winningMap, count = 0, nil, 0
			for k, v in pairs(AzVote.VoteTable) do
				if (#v > maxVotes) then
					maxVotes = #v
					winningMap = k
				end
				count = count + 1
			end
			
			if (!forced) then
				local neededCount = math.ceil( #player.GetAll() * AzVote.Config.WinRatio )	
				if (maxVotes < neededCount) then
					AzVote:BroadcastTL( "azvote.error.notenoughvotes", maxVotes, neededCount )
					AzVote:SetState( AZVOTE_STATE_NONE )
					return
				end
			end
			
			if (maxVotes <= 0) then
				local v, k = table.Random(AzVote.VoteTable)
				winningMap = k
				AzVote:BroadcastTL( "azvote.mapvote.winning.random", winningMap )
			else
				AzVote:BroadcastTL( "azvote.mapvote.winning", winningMap, maxVotes )
			end
			table.Empty(AzVote.VoteTable)
			
			if (AzVote.CVar.PreventWin:GetBool()) then
				return
			end
			
			AzVote:SetState( AZVOTE_STATE_CHANGING )
			
			AzVote:CommenceChangelevel( winningMap, nil, 10, forced )
		end)
	end)
end

function AzVote.MapVote:AddRTV( ply )
	local neededCount = math.ceil( #player.GetAll() * AzVote.Config.RTVRatio )	
	table.insert( self.RTVVoters, ply:SteamID() )
	
	if (!timer.Exists("AzVote MapVote CleanseRTV")) then
		AzVote:BroadcastTL( "azvote.mapvote.rtv.first", ply:Nick(), #self.RTVVoters, neededCount )
		AzVote:BroadcastTL( "azvote.mapvote.rtv.hint", table.GetFirstValue( AzVote.Config.RTVKeywords ) )
	else
		AzVote:BroadcastTL( "azvote.mapvote.rtv", ply:Nick(), #self.RTVVoters, neededCount )
	end
	
	self:CleanupRTV()
	
	if (self:CheckRTV()) then
		table.Empty(self.RTVVoters)
		
		local currentMode = GetConVar( "gamemode" ):GetString() or GAMEMODE.Folder:match("gamemodes/(.+)")
		if (!AzVote.Config.Gamemodes[currentMode]) then
			AzVote:BroadcastTL( "azvote.mapvote.rtv.error.gamemode" )
			AzVote:BroadcastTL( "azvote.mapvote.rtv.error.failed" )
		end
		
		local maps = AzVote:BuildMapsTable( AzVote.Config.Gamemodes[currentMode].Prefixes )
		if (#maps > 0) then
			AzVote:TrimTable( maps, AzVote.Config.MaxMaps )
			self:StartMapVote( maps )
		else
			AzVote:BroadcastTL( "azvote.mapvote.rtv.error.maps" )
			AzVote:BroadcastTL( "azvote.mapvote.rtv.error.failed" )
		end
	else
		timer.Create("AzVote MapVote CleanseRTV", AzVote.Config.CleanseTime, 1, function()	
			local neededCount = math.ceil( #player.GetAll() * AzVote.Config.RTVRatio )
			
			AzVote:BroadcastTL( "azvote.mapvote.rtv.error.votes", #self.RTVVoters, neededCount )
			
			table.Empty(self.RTVVoters)
		end)
	end
end

hook.Add( "PlayerSay", "AzVote MapRTV", function( ply, msg )
	local self = AzVote.MapVote
	msg = string.lower(msg):Trim()
	
	for k, v in pairs( AzVote.Config.RTVKeywords ) do
		if ( v == msg ) then
			if (CurTime() < self.DisableTime) then
				ply:AVNotifyTL( "azvote.error.votewillbeunlocked", math.ceil(self.DisableTime - CurTime()))
				return false
			end
		
			if (AzVote:GetState() != AZVOTE_STATE_NONE) then
				ply:AVNotifyTL( "azvote.error.alreadyinprocess" )
				return false
			end

			for k, v in pairs(self.RTVVoters) do
				if (v == ply:SteamID()) then
					ply:AVNotifyTL( "azvote.mapvote.error.alreadyrocked" )
					return false
				end
			end
			
			self:AddRTV( ply )
			return false 
		end 
	end
end)

-- Hook up default map changing
function game.LoadNextMap()
	local currentMode = GetConVar( "gamemode" ):GetString() or GAMEMODE.Folder:match("gamemodes/(.+)")
	local maps = AzVote:BuildMapsTable( AzVote.Config.Gamemodes[currentMode].Prefixes )
	
	if (#player.GetAll() == 0) then
		if (#maps > 0) then
			AzVote:Changelevel(table.Random(maps))
		else
			AzVote:Changelevel(game.GetMap())
		end
		return
	end
	
	if (#maps > 0) then
		AzVote:TrimTable( maps, AzVote.Config.MaxMaps )
		
		AzVote.MapVote:StartMapVote( maps, true )
	else
		AzVote:Changelevel(game.GetMap())
	end
end
