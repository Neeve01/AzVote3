include("vgui/arc.lua")

AzVote.HUD = {}

local rtv_dramatic_buffer = 0
local gamemode_rtv_dramatic_buffer = 0
local goffset_dramatic_buffer = 0

AzVote.HUD.ShouldCircle = false

local function scale(x, base)
	base = base or 1080
	return math.ceil(ScrH() * (x / base))
end

local circle_head = 0
local circle_tail = 0
local circle_c = 0

local delta = 0
local old_time = 0

function AzVote:PaintHUD()
	local delta = SysTime() - old_time
	old_time = SysTime()
	
	local goffset = 0
	local rtv_time = math.max(0, (self:GetRTVEndTime() or 0) - CurTime())
	
	if (rtv_dramatic_buffer > 0 || rtv_time > 0) then
		local text = os.date("!%X", rtv_time):gsub("00:", "")

		surface.SetFont("AzVote ItemNames")
		local textw = surface.GetTextSize(text)
		local rtvw = surface.GetTextSize("RTV")
		
		local y = scale(880)
		local w = rtvw + textw + scale(12)
		local h = scale(20)
		
		if (textw == 0 || rtv_time <= 0) then
			w = 0
		end
		
		rtv_dramatic_buffer = math.Approach(rtv_dramatic_buffer, w, math.max(scale(0.05), math.abs(w - rtv_dramatic_buffer) / 10))
		
		render.SetScissorRect(0, y, rtv_dramatic_buffer, y + h, true)
			surface.SetDrawColor( Color( 72, 48, 0, 100 ) )
			surface.DrawRect( -1, y, rtv_dramatic_buffer + 1, h )
			
			surface.SetDrawColor( Color( 255, 128, 128, 100 ) )
			surface.DrawRect( rtvw + scale(5), y, scale(2), h )
			
			draw.SimpleText("RTV", "AzVote ItemNames", scale(2), y + h / 2, Color(255, 255, 255, 192), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(text, "AzVote ItemNames", rtvw + scale(10), y + h / 2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		render.SetScissorRect(0, 0, 0, 0, false)
		
		goffset = goffset + h + scale(2)
	end
	
	goffset_dramatic_buffer = math.Approach(goffset_dramatic_buffer, goffset, math.max(scale(0.05), math.abs(goffset - goffset_dramatic_buffer) / 10))
	
	local gamemode_rtv_time = math.max(0, (self:GetGamemodeRTVEndTime() or 0) - CurTime())
	
	if (gamemode_rtv_dramatic_buffer > 0 || gamemode_rtv_time > 0) then
		local text = os.date("!%X", gamemode_rtv_time):gsub("00:", "")

		surface.SetFont("AzVote ItemNames")
		local textw = surface.GetTextSize(text)
		local rtvw = surface.GetTextSize("GRTV")
		
		local y = scale(880) + goffset_dramatic_buffer
		
		local w = rtvw + textw + scale(12)
		local h = scale(20)
		
		if (textw == 0 || gamemode_rtv_time <= 0) then
			w = 0
		end
		
		gamemode_rtv_dramatic_buffer = math.Approach(gamemode_rtv_dramatic_buffer, w, math.max(scale(0.05), math.abs(w - gamemode_rtv_dramatic_buffer) / 10))
		
		render.SetScissorRect(0, y, gamemode_rtv_dramatic_buffer, y + h, true)
			surface.SetDrawColor( Color( 72, 48, 0, 100 ) )
			surface.DrawRect( 0, y, gamemode_rtv_dramatic_buffer, h )
			
			surface.SetDrawColor( Color( 255, 128, 128, 100 ) )
			surface.DrawRect( rtvw + scale(5), y, scale(2), h )
			
			draw.SimpleText("GRTV", "AzVote ItemNames", scale(2), y + h / 2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(text, "AzVote ItemNames", rtvw + scale(10), y + h / 2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		render.SetScissorRect(0, 0, 0, 0, false)
		
		goffset = goffset + h + scale(2)
	end
	
	--local power = 1 - (math.sin(CurTime()) + 1) / 2
	if (circle_c == 0) then
		circle_tail = math.Approach(circle_tail, 320, math.max(1.5, math.abs((circle_tail - 320) / 70)))
		if (circle_tail >= 320) then
			circle_c = 1
		end
	elseif (circle_c == 1) then
		circle_head = math.Approach(circle_head, 320, math.max(1.5, math.abs((circle_head - 320) / 70)))
		if (circle_head >= 320) then
			circle_tail = -40
			circle_head = -40
			circle_c = 0
		end
	end
	
	if (AzVote.HUD.ShouldCircle) then
		local m = 260
		local h = (CurTime() * m + circle_head) 
		local t = (CurTime() * m + circle_tail)
		
		exdraw.Arc(ScrW() / 2, ScrH() / 2, 32, 8, h, t, 5, Color(255, 64, 64))
	end
end