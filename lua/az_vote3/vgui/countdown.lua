local l_size = ScrW() / 16 
local s_size = ScrW() / 48

surface.CreateFont("AzVote CountdownText L", { font = "roboto", size = l_size })
surface.CreateFont("AzVote CountdownText S", { font = "roboto", size = s_size })

local function nicetime( time )
	return os.date( "!%X", time )
end

return
{
	Set = function( self, time, map, gamemode )
		self.Time = time
		self.Map = map
		self.Gamemode = gamemode
	end,

	Init = function( self )
		self:SetPos( 0, (ScrH() / 3) * 2 )
		self:SetSize( ScrW(), (ScrH() / 3) )
	end,

	Paint = function( self, w, h )
		local spacing = 0
		local h_accum = 0
		if (!self.Time) then return end
		
		surface.SetFont("AzVote CountdownText S")
		local str = az_translate "azvote.countdown.changesin"
		local size_w, size_h = surface.GetTextSize(str)
		h_accum = h_accum + size_h + spacing
		draw.SimpleTextOutlined(str, "AzVote CountdownText S", w * 0.5, h_accum, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, Color(128,128,128,128))
		
		surface.SetFont("AzVote CountdownText L")
		str = nicetime(((self.Time - CurTime() > 0) and (self.Time - CurTime())) or 0)
		size_w, size_h = surface.GetTextSize(str)
		h_accum = h_accum + size_h + spacing - 15
		draw.SimpleTextOutlined(str, "AzVote CountdownText L", w * 0.5, h_accum, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, Color(128,128,128,128))
		
		local gmoffset = 0		
		if (self.Map && self.Map != "") then
			surface.SetFont("AzVote CountdownText S")
			str = az_translate("azvote.countdown.nextmap", self.Map)
			size_w, size_h = surface.GetTextSize(str)
			h_accum = h_accum + size_h + spacing - 15
			draw.SimpleTextOutlined(str, "AzVote CountdownText S", w * 0.5, h_accum, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, Color(128,128,128,128))
		end
		
		local gmname = az_translate "azvote.countdown.samegamemode"
		
		if (self.Gamemode && self.Gamemode != "") then
			gmname = az_translate("azvote.countdown.gamemode", self.Gamemode)
		end
		surface.SetFont("AzVote CountdownText S")
		str = gmname
		size_w, size_h = surface.GetTextSize(str)
		h_accum = h_accum + size_h + spacing
		draw.SimpleTextOutlined(gmname, "AzVote CountdownText S", w * 0.5, h_accum, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, Color(128,128,128,128))
	end,
	
	PerformLayout = function( self ) 
		self:SetPos( 0, (ScrH() / 2.65) * 2 )
	end,

	Think = function( self )
		if (!self.Time) then return end
	
		if (self.Time - CurTime() <= -2) then
			self:Hide()
		end
	end
}