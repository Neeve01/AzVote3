MsgC(Color(255, 128, 0), "-----------------------------")
MsgC(Color(255, 128, 0), "> AzVote3 Loaded\n")   
MsgC(Color(255, 128, 0), "> Copyright (c) Neeve01, @NotMyWing\n")
MsgC(Color(255, 128, 0), "> https://github.com/Neeve01\n")
MsgC(Color(255, 128, 0), "-----------------------------")

if SERVER then
	include("az_vote3/sv_init.lua" ) 
elseif CLIENT then
	include("az_vote3/shared.lua" ) 
	include("az_vote3/cl_init.lua" )
end

local files = file.Find("maps/ttt_*.bsp", "GAME")
for k, v in pairs(files) do
	if (!file.Exists(string.format("maps/thumb/%s.png", v), "GAME")) then
		print(string.format("NO THUMBNAIL: %s", v))
	end
end