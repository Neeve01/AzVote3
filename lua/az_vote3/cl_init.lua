include("cl_nethook.lua")
include("cl_hud.lua")

function AzVote.Initialize()
	AzVote.Initialized = true
	
	AzVote.CountdownGUITable = vgui.RegisterTable( include("az_vote3/vgui/countdown.lua"), "EditablePanel" )
	AzVote.VoteGUITable = vgui.RegisterTable( include("az_vote3/vgui/board_scaled.lua"), "EditablePanel" )

	AzVote.CountdownGUI = vgui.CreateFromTable( AzVote.CountdownGUITable )
	AzVote.VoteGUI = vgui.CreateFromTable( AzVote.VoteGUITable )
	AzVote:HideMenu()
end

function AzVote:ShowMenu( items, mask, description, timeout )
	if (!IsValid( self.VoteGUI )) then
		self.Initialize()
	end
	
	if (self.VoteGUI:IsVisible()) then
		self:HideMenu()
	end

	self.SelectedItem = nil  
	self.VoteGUI:SetHeader( description or az_translate "azvote.gui.votegeneric" )    
	self.VoteGUI:SetupItems( items, mask )
	self.VoteGUI:Show()
	self.VoteGUI:MakePopup()
	
	self.VoteGUI.StartTime = SysTime()
	self.VoteGUI.EndTime = timeout
	
	self.VoteGUI:SetKeyboardInputEnabled( false )
end

function AzVote:ShowCountdown( time, map, gamemode )
	if (!IsValid( self.CountdownGUI )) then
		self.Initialize()
	end
	
	if (self.CountdownGUI:IsVisible()) then
		self:HideMenu()
	end

	self.CountdownGUI:Set( time, map, gamemode )
	self.CountdownGUI:Show()
end

function AzVote:SubmitVote( item )
	self.SelectedItem = item
	net.Start("AzVote Vote")
		net.WriteString(item)
	net.SendToServer()
end

function AzVote:SubmitBoardClose()
	net.Start("AzVote BoardClose")
	net.SendToServer()
end

function AzVote:HideMenu()
	if (!IsValid( self.VoteGUI )) then
		self.Initialize()
	end
	
	self.VoteGUI:Hide()
end

function AzVote:SendVote( vote )
	net.Start( "AzVote SendVote" )
		net.WriteString( vote )
	net.SendToServer()
end

--[[
	Hooks
]]--
hook.Add( "Initialize", "AzVote Initialize", AzVote.Initialize)
if (AzVote.Initialized) then
	AzVote.Initialize()
end

hook.Add( "DrawOverlay", "AzVote HUD Paint", function()
	AzVote:PaintHUD()
end)