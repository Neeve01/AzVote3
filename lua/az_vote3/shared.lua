AzVote = AzVote or {}

AZVOTE_STATE_NONE = 0
AZVOTE_STATE_VOTING = 1
AZVOTE_STATE_CHANGING = 2

function AzVote:Exclude( ply )
	for k, item in pairs(self.VoteTable) do
		for kk, _ply in pairs(item) do
			if (ply == _ply) then
				table.remove(item, kk)
			end
		end
	end
end

function AzVote:GetState()
	return GetGlobalInt("AzVote State")
end

function AzVote:GetRTVEndTime()
	return GetGlobalInt("AzVote RTVEndTime")
end

function AzVote:GetGamemodeRTVEndTime()
	return GetGlobalInt("AzVote GamemodeRTVEndTime")
end