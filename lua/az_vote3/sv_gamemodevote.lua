--[[ Migrated straight from AzVote2. Will be rewrited someday.

	function AzVote:ClearGamemodeRTV()
		table.Empty( self.GamemodeRTVVoters )
		SetGlobalInt("AzVote GamemodeRTV Count", 0)
	end

	function AzVote:SetGamemodeRTVEndTime(t)
		SetGlobalInt("AzVote GamemodeRTVEndTime", t or 0)
	end

	function AzVote:PauseGRTVCleanse()

	end

	function AzVote:ResumeGRTVCleanse()

	end

	function AzVote:StopGRTVCleanse()

	end

	function AzVote:StartGRTVCleanse(t)
		t = t or 

		timer.Create( "AzVote GamemodeVoteCleanse", self.Config.CleanseTime, 1, function()
			self:BroadcastTL( "azvote.error.rtvfailed", #self.GamemodeRTVVoters, math.ceil( #player.GetAll() * self.Config.GamemodeRTVRatio ) )

			self:ClearGamemodeRTV()
			self.GamemodeVoteDisableTime = CurTime() + self.Config.DisableTime
		end)
		self:SetGamemodeRTVEndTime(CurTime() + self.Config.CleanseTime)
	end

	function AzVote:StartGamemodeVote( modes )
		timer.Destroy("AzVote GamemodeVoteCleanse")
		timer.Pause("AzVote MapVoteCleanse")
		
		self:ClearGamemodeRTV()
		self:ClearVotes()
		
		for k, mode in pairs(modes) do
			self.VoteTable[mode] = {}
		end 
		
		self:SetState( AZVOTE_STATE_VOTING )
		AzVote:BroadcastPreVote()
		
		timer.Simple(2, function()
			net.Start( "AzVote StartGamemodeVote" )
				net.WriteTable( modes )
			net.Broadcast()
		end)
		
		timer.Create( "AzVote FinishGamemodeVote", self.Config.VotingTime, 1, function()
			self:FinishGamemodeVote()
		end)
	end

	function AzVote:FinishGamemodeVote()
		net.Start( "AzVote FinishVote" )
		net.Broadcast()
		
		timer.UnPause("AzVote MapVoteCleanse")
		local maxVotes, winningMap, count = -1, nil, 0
		for k, v in pairs(self.VoteTable) do
			if (#v > maxVotes) then
				maxVotes = #v
				winningMap = k
			end
			count = count + 1
		end
		
		local neededCount = math.ceil( #player.GetAll() * self.Config.WinRatio )	
		if (maxVotes < neededCount) then
			self:BroadcastTL( "azvote.error.gamemode_notenoughvotes", maxVotes, neededCount )
			self:SetState( AZVOTE_STATE_NONE )
			return
		end
		
		if (maxVotes <= 0) then
			local v, k = table.Random(AzVote.VoteTable)
			winningMap = k
			self:BroadcastTL( "azvote.gamemodevote.winning.random", winningMap )
		else
			self:BroadcastTL( "azvote.gamemodevote.winning", winningMap, maxVotes )
		end
		
		if (self.CVar.PreventWin:GetBool()) then
			return
		end
		
		self:SetState( AZVOTE_STATE_VOTING )
		self:ClearVotes()
	end

	function AzVote:CheckGamemodeRTV()
		if (self:GetState() != AZVOTE_STATE_NONE) then
			return false
		end
		
		if (math.ceil(#player.GetAll() * self.Config.GamemodeRTVRatio) <= 0) then
			return false
		end
		
		local players = player.GetAll()
		for k, voter in pairs(self.GamemodeRTVVoters) do
			local found
			
			for _, ply in pairs(players) do
				if (voter == ply:SteamID()) then
					found = true
					break
				end
			end
			
			if (!found) then
				table.remove(self.GamemodeRTVVoters, k)
			end
		end
		
		if ( #self.GamemodeRTVVoters >= math.ceil(#player.GetAll() * self.Config.GamemodeRTVRatio) ) then
			self:ClearGamemodeRTV()

			local gamemodes = self:BuildGamemodesTable()
			TrimTable( gamemodes, self.Config.MaxGamemodes )

			self:StartGamemodeVote( gamemodes )
			
			return true
		end
		SetGlobalInt("AzVote GamemodeRTV Count", #self.GamemodeRTVVoters)
		
		return false
	end

	local function TrimTable( t, count )
		while (#t > count) do
			table.remove(t, math.random(1, #t))
		end
	end

	function AzVote:BuildGamemodesTable()
		return {}
	end

	function AzVote:AddGamemodeRTV( ply )
		for k, v in pairs(self.GamemodeRTVVoters) do
			if (v == ply:SteamID()) then
				ply:AVNotifyTL( "azvote.error.alreadyrocked" )
				return
			end
		end
		
		table.insert( self.GamemodeRTVVoters, ply:SteamID() )
		timer.Destroy( "AzVote GamemodeVoteCleanse")
		local check = self:CheckGamemodeRTV()
		
		self:BroadcastTL( "azvote.playergamemodertv", ply:Name(), #self.GamemodeRTVVoters, math.ceil( #player.GetAll() * self.Config.GamemodeRTVRatio ) )
		if (!check) then
			self:StartGRTVCleanse()
			
			SetGlobalInt("AzVote GamemodeRTV Count", #self.GamemodeRTVVoters)
		end
	end

	hook.Add( "PlayerSay", "AzVote GamemodeRTV", function( ply, msg )
		msg = string.lower( msg ):Trim()
		
		-- RTV
		for k, v in pairs( AzVote.Config.GamemodeRTVKeywords ) do
			if ( v == msg ) then
				if (CurTime() < self.GamemodeVoteDisableTime) then
					ply:AVNotifyTL( "azvote.error.votewillbeunlocked", math.ceil(self.GamemodeVoteDisableTime - CurTime()) )
					return false
				end
			
				if (AzVote:GetState() != AZVOTE_STATE_NONE) then
					ply:AVNotifyTL( "azvote.error.alreadyinprocess" )
					return false
				end

				AzVote:AddGamemodeRTV( ply )
				return false 
			end 
		end
	end)
]]