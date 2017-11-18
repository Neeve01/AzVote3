AzVote.CVar = {}

AzVote.CVar.PreventWin = CreateConVar( "azvote_preventwin", "0", bit.bor(FCVAR_ARCHIVE), "Prevents vote winning. Useful for debugging voting system." ) 
AzVote.CVar.PreventChange = CreateConVar( "azvote_preventchange", "0", bit.bor(FCVAR_ARCHIVE), "Prevents map change. Useful for debugging voting system." ) 


concommand.Add("azvote_reload", function()
	AzVote:Reload()
end, nil, nil, bit.bor(FCVAR_SERVER_CAN_EXECUTE))