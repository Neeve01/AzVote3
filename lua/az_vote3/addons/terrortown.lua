if (!ADDON) then return end

ADDON.Name = "TTT Changelevel Handler"

function ADDON:ShouldLoad()
	return !GAMEMODE || GetConVar("ttt_haste")
end

function ADDON:Changelevel(map, mode, time, forced)
	if (#player.GetAll() > 1) then
		AzVote:BroadcastTL( "azvote.mapvote.nextround" )

		hook.Add("TTTEndRound", "AzVote TTT Hook", function()
			AzVote:ChangelevelDelayed( map, mode, time )
			hook.Remove("TTTEndRound", "AzVote TTT Hook")
		end)
	else
		AzVote:Changelevel( map, mode )
	end

	-- Handled
	return true
end

function ADDON:Finalize()
	hook.Remove("TTTEndRound", "AzVote TTT Hook")
end