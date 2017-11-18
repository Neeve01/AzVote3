local function scale(x, base)
	base = base or 1080
	return math.ceil(ScrH() * (x / base))
end

surface.CreateFont( "AzVote ItemNames", {
	font	= "Helvetica",
	size	= scale(16),
	weight	= 800 
} )

local ITEMSIZE = 160 -- Raw on 1080
local MAX_ITEMS_LINE = 5
local MAX_LINES = 3

local function OutlinedBox( x, y, w, h, thickness )
	for i=0, thickness - 1 do
		surface.DrawOutlinedRect( x + i, y + i, w - i * 2, h - i * 2 )
	end
end

local VOTERTABLE = {
	SetItem = function( self, ply, item )
		self.Name:SetText( ply:Name() )
		self.Avatar:SetPlayer( ply, scale(18) )
		self.Item = item 	
		self.Player = ply
	end,
	
	Init = function( self )  
		self:SetTall(scale(20))
		self:Dock( TOP )
		
		self.Avatar = self:Add( "AvatarImage" )
		self.Avatar:SetSize( scale(18), scale(18) )
		self.Avatar:SetPos( scale(3), scale(1) )
		
		self.Name = self:Add("DLabel")
		self.Name:SetFont( "AzVote ItemNames" ) 
		self.Name:Dock( FILL )
		self.Name:SetText( "" )
		self.Name:SetTextColor( Color( 255, 255, 0, 255 ) )
		self.Name:DockMargin(scale(4 + 18 + 3), 0, scale(4), 0)
		self.Name:SetContentAlignment( 4 )
		self.Name:SetExpensiveShadow( 2, Color( 0, 0, 0, 200 ) )
	end,
	
	Paint = function( self, w, h )
		surface.SetDrawColor( Color( 72, 48, 0, 220 ) )
		surface.DrawRect( 0, 0, w, h )
	end,

	Think = function( self )
		local votetable = AzVote.VoteTable
		if (!votetable) then
			self:Remove()
			return
		end
		
		local votes = AzVote.VoteTable[self.Item]
		if (!votes) then
			self:Remove()
			return
		end
		
		if (!table.IndexOf(votes, self.Player)) then
			self:Remove()
			return
		end
	end
}

VOTERTABLE = vgui.RegisterTable( VOTERTABLE, "DPanel" )

local ITEMTABLE = {
	SetItem = function( self, itemname, mask )
		itemname = itemname:gsub("%.bsp$", "")
		self.Item = itemname
		local img = string.format( mask or "%s", itemname )
		print(img)
		img = file.Exists( img, "GAME" ) && img || "maps/thumb/noicon.png"
		self.Image:SetImage(img)
		self.ItemName:SetText( itemname )
	end,
	
	Init = function( self )  
		self.Votes = self.Votes or {}
	
		local w = scale(ITEMSIZE + 8)
		self:SetSize( w, w )
		
		local margin = scale(4)
		self.Image = self:Add("DImage")
		self.Image:Dock( FILL )
		self.Image:DockMargin(margin, margin, margin, margin)
		
		local namepanel = self.Image:Add("DPanel")
		namepanel:SetZPos(scale(16))
		namepanel:Dock(BOTTOM)
		namepanel:SetTall(scale(20))
		function namepanel:Paint(w, h)
			surface.SetDrawColor( Color( 0, 0, 0, 128 ) )
			surface.DrawRect( 0, 0, w, h )
		end
		
		self.ItemName = namepanel:Add( "DLabel" )
		self.ItemName:SetFont( "AzVote ItemNames" ) 
		self.ItemName:SetTextColor( Color( 255, 255, 0, 255 ) )
		self.ItemName:Dock( FILL )
		self.ItemName:DockMargin(0,0,0,0)
		self.ItemName:SetContentAlignment( 5 )
		self.ItemName:SetExpensiveShadow( 2, Color( 0, 0, 0, 200 ) )
		self.ItemName:SetText( "Unknown" ) 
		
		self.ClickOverlay = self:Add("DButton")
		self.ClickOverlay:SetZPos( 2 )
		self.ClickOverlay:Dock(FILL)
		self.ClickOverlay.HoverBuffer = 0
		self.ClickOverlay:SetText("")
		
		local itemtable = self
		self.ClickOverlay.Paint = function(self, w, h)
			if (AzVote.SelectedItem == itemtable.Item) then
				surface.SetDrawColor( Color( 0, 255, 0, 128 ) )
				OutlinedBox(0, 0, w, h, 6)
			end
			
			if (self:IsDown()) then
				surface.SetDrawColor( Color( 0, 0, 0, 159 ) )
			elseif (self.HoverBuffer > 0) then
				surface.SetDrawColor( Color( 0, 0, 0, 95 * self.HoverBuffer ) )
			else 
				return
			end
			surface.DrawRect(0, 0, w, h)
		end
		
		self.ClickOverlay.DoClick = function()
			AzVote:SubmitVote(self.Item)
			surface.PlaySound( "garrysmod/save_load1.wav" ) 
		end

		self.ClickOverlay.Think = function(self)			
			if (self:IsHovered()) then
				self.HoverBuffer = 1
			elseif (self.HoverBuffer < 0.05 && self.HoverBuffer >= 0) then -- Avoid excess calculation
				self.HoverBuffer = 0
			else
				self.HoverBuffer = self.HoverBuffer * 0.95
			end
		end
		
		self.VoteCountPanel = self.Image:Add("DPanel")
		self.VoteCountPanel:SetZPos(16)
		self.VoteCountPanel:Dock(TOP)
		self.VoteCountPanel:SetTall(scale(20))
		
		function self.VoteCountPanel:Paint(w, h)
			surface.SetDrawColor( Color( 0, 0, 0, 128 ) )
			surface.DrawRect( 0, 0, w, h )
		end
		
		self.VoteCount = self.VoteCountPanel:Add("DLabel")
		self.VoteCount:SetFont( "AzVote ItemNames" ) 
		self.VoteCount:Dock( FILL )
		self.VoteCount:SetText( az_translate( "azvote.item.votecount", 0) )
		self.VoteCount:SetTextColor( Color( 255, 255, 0, 255 ) )
		self.VoteCount:DockMargin(0,0,0,0)
		self.VoteCount:SetContentAlignment( 2 )
		self.VoteCount:SetExpensiveShadow( 2, Color( 0, 0, 0, 200 ) )
		
		self.VotersContainer = self.Image:Add("DScrollPanel")
		self.VotersContainer:SetZPos( 16 )
		self.VotersContainer:Dock(FILL)
		local scroll = self.VotersContainer:GetVBar()
		
		scroll:SetWide(8)
		scroll.btnUp.Paint = function() end
		scroll.btnDown.Paint = function() end
		scroll.Paint = function(self, w, h) 
			surface.SetDrawColor( Color( 72, 48, 0, 220 ) )
			surface.DrawRect( 0, 0, w, h )
		end
		scroll.btnGrip.Paint = function(self, w, h)
			surface.DisableClipping( true )
			surface.SetDrawColor( Color( 220, 48, 0, 220 ) )
			surface.DrawRect( 0, -scroll.btnDown:GetTall() + 1, w - 2, h + scroll.btnDown:GetTall() * 2 - 1 )
			surface.DisableClipping( false ) 
		end
		
		self.VotersLayout = self.VotersContainer:Add("DPanel")
		self.VotersLayout:Dock( TOP )
		self.VotersLayout.Paint = function(self, w, h)
		end
		
		self.ClickOverlay.OnMouseWheeled = function( s, delta )
			self.VotersContainer:GetVBar():AddScroll(-delta)
		end
	end,
	
	Paint = function( self, w, h )
		surface.SetDrawColor( Color( 0, 0, 0, 64 ) )
		surface.DrawRect( 0, 0, w, h )	
	end,

	Think = function( self ) 
		local visible = self.VoteCountPanel:IsVisible()
		local hovered = self.ClickOverlay:IsHovered()
		local count = #((AzVote.VoteTable or {})[self.Item] or {})
		self.VoteCount:SetText( az_translate( "azvote.item.votecount", count) )
		self.VotersLayout:SetTall(scale(#self.VotersLayout:GetChildren() * 20))
		
		count = count > 0
		if (visible && (!hovered && !count)) then
			self.VoteCountPanel:Hide()
		elseif (!visible && (hovered || count)) then
			self.VoteCountPanel:Show()
		end
		
		if (true) then
			return
		end
		
		self.Votes = self.Votes or {}
		local votes = AzVote.VoteTable[self.Item] or {}
		
		for k, ply in pairs(votes) do
			for k, v in pairs(self.VotersLayout:GetChildren()) do
				if (v.Player == ply) then
					continue
				end
			end
			local t = self.VotersLayout:Add( VOTERTABLE )
			t:SetItem(ply, self.Item)
		end
		
		self.Votes = votes
	end
}

ITEMTABLE = vgui.RegisterTable( ITEMTABLE, "DPanel" ) 

local HEADER_SIZE = 18

surface.CreateFont( "AzVote Branding", {
	font	= "Helvetica",
	size	= scale(HEADER_SIZE - 2),
	weight	= 800
} )

return
{
	SetHeader = function( self, text )
		self.HeaderText:SetText( text )
	end,
	
	SetupItems = function( self, items, mask )
		self.IconLayout:Clear()
		
		table.sort(items)
		for k, v in pairs(items) do
			local item = self.IconLayout:Add( ITEMTABLE )
			item:SetItem( v, mask )
		end
		self:Resize(#items)
	end,

	AddVote = function( self, ply, item )
		for k, v in pairs(self.IconLayout:GetChildren()) do
			if (v.Item == item) then
				for kk, vv in pairs(v.VotersLayout:GetChildren()) do
					if (vv.Player == ply) then
						return
					end
				end
			end
		end
	
		for k, v in pairs(self.IconLayout:GetChildren()) do
			if (v.Item == item) then
				local t = v.VotersLayout:Add( VOTERTABLE )
				t:SetItem(ply, item)
			end
		end
	end,
	
	ExcludeVote = function( self, ply )
	
	end,
	
	AddVoteAgainst = function( self, ply, item )
	
	end,
	
	Resize = function( self, itemcount )
		local lines = math.min(math.ceil(itemcount / MAX_ITEMS_LINE), MAX_LINES)
		--local rows = (itemcount % MAX_ITEMS_LINE)
		local rows = math.min(MAX_ITEMS_LINE, itemcount)
		
		local h = scale(HEADER_SIZE * 2 + 5 + (lines * 3) + (ITEMSIZE + 8) * lines)
		local w = scale((ITEMSIZE + 8) * rows + rows + 30)
		
		self:SetSize(w, h)
	end,
	
	Init = function( self )
		local mainPanel = self
		self.StartTime = SysTime()
		self:SetSize( scale(1212), scale(624) )
		
		self.Header = self:Add("DPanel")
		self.Header:Dock( TOP )
		self.Header:SetTall( scale(HEADER_SIZE) )
		self.Header.Paint = function( self, w, h )		
			surface.DisableClipping( true )
			surface.SetDrawColor( Color( 0, 0, 0, 96 ) )
			surface.DrawRect( 0, h, w, scale(4) )
			surface.DisableClipping( false )
			surface.SetDrawColor( Color( 160, 127, 0, 255 ) )
			surface.DrawRect( 0, 0, w, h )
		end
		
		self.Branding = self.Header:Add("DPanel")
		self.Branding:Dock( LEFT )
		self.Branding:SetWide( scale(80) )
		self.Branding.Paint = function( self, w, h )
			surface.SetDrawColor( Color( 200, 160, 0, 255 ) )
			surface.DrawRect( 0, 0, w, h )
		end
		
		self.BrandingText = self.Branding:Add("DLabel")
		self.BrandingText:SetFont( "AzVote Branding" )
		self.BrandingText:SetTextColor( Color( 255, 255, 255 ))
		self.BrandingText:Dock(FILL)
		self.BrandingText:SetContentAlignment( 5 )
		self.BrandingText:SetExpensiveShadow(1, Color( 0, 0, 0, 200 ))
		self.BrandingText:SetText( "AzVote" )
		
		self.Footer = self:Add("DPanel")
		self.Footer:Dock( BOTTOM )
		self.Footer:SetTall( scale(HEADER_SIZE) )
		self.Footer.Paint = function( self, w, h )		
			surface.SetDrawColor( Color( 160, 127, 0, 255 ) )
			surface.DrawRect( 0, 0, w, h )
			
			surface.DisableClipping( true )
			surface.SetDrawColor( Color( 0, 0, 0, 96 ) )
			surface.DrawRect( 0, -4, w, 4 )
			surface.DisableClipping( false )
		end
		
		self.VotersCount = self.Footer:Add("DLabel")
		self.VotersCount:SetFont( "AzVote Branding" )
		self.VotersCount:SetTextColor( Color( 255, 255, 255 ))
		self.VotersCount:DockMargin(0, 0, scale(4), 0)
		self.VotersCount:Dock(FILL)
		self.VotersCount:SetContentAlignment( 6 )
		self.VotersCount:SetExpensiveShadow(1, Color( 0, 0, 0, 200 ))
		self.VotersCount:SetText( "" )
		function self.VotersCount:Think()
			local count = GetGlobalInt("AzVote VotersCount")
		end
		
		self.BrandingText = self.Footer:Add("DLabel")
		self.BrandingText:SetFont( "AzVote Branding" )
		self.BrandingText:SetTextColor( Color( 255, 255, 255 ))
		self.BrandingText:DockMargin(0, 0, scale(4), 0)
		self.BrandingText:Dock(FILL)
		self.BrandingText:SetContentAlignment( 6 )
		self.BrandingText:SetExpensiveShadow(1, Color( 0, 0, 0, 200 ))
		self.BrandingText:SetText( "AZCO" )
		
		self.CloseButton = self.Header:Add("DButton")
		self.CloseButton:SetFont("marlett")
		self.CloseButton:SetText("r")
		self.CloseButton:Dock( RIGHT )
		self.CloseButton:SetWide( scale(HEADER_SIZE) )
		self.CloseButton:SetContentAlignment(5)
		self.CloseButton.Paint = function( self, w, h )
			local mult = 1
			surface.SetDrawColor( Color( 220 * mult, 127 * mult, 0, 255 ) )
			surface.DrawRect( 0, 0, w, h )
		end
		self.CloseButton.DoClick = function()
			self:Hide()
		end
		
		self.TimeOut = self.Header:Add("DPanel")
		self.TimeOut:DockMargin(0, 0, scale(HEADER_SIZE), 0)
		self.TimeOut:Dock( RIGHT )
		self.TimeOut:SetWide( scale(40) )
		self.TimeOut.Paint = function( self, w, h )
			surface.SetDrawColor( Color( 200, 160, 0, 255 ) )
			surface.DrawRect( 0, 0, w, h )
		end
		
		self.TimeOutText = self.TimeOut:Add("DLabel")
		self.TimeOutText:SetFont( "AzVote Branding" )
		self.TimeOutText:Dock(FILL)
		self.TimeOutText:SetContentAlignment(5)
		self.TimeOutText:SetTextColor( Color( 255, 255, 255 ))
		self.TimeOutText:SetText("")
		self.TimeOutText:SetExpensiveShadow(2, Color(0, 0, 0, 200) )
		function self.TimeOutText:Think()
			if (mainPanel.EndTime) then
				local text = os.date("!%X", mainPanel.EndTime - CurTime()):gsub("00:", ""):gsub("^(0+)", "")
				text = text == "" and "0" or text
				self:SetText(text)
			end
		end
		
		self.HeaderText = self.Header:Add("DLabel") 
		self.HeaderText:SetFont( "AzVote Branding" ) 
		self.HeaderText:SetTextColor( Color( 255, 220, 220, 255 ) )
		self.HeaderText:Dock( FILL )
		self.HeaderText:DockMargin(scale(8), 0, scale(8), 0)
		self.HeaderText:SetContentAlignment( 4 )
		self.HeaderText:SetExpensiveShadow( 1, Color( 0, 0, 0, 200 ) )
		self.HeaderText:SetText( "" )	
		
		self.Body = self:Add("DScrollPanel")
		self.Body:Dock( FILL )
		self.Body:DockMargin(scale(4),scale(2),scale(4),scale(4))
		self.Body.Paint = function(self, w, h)
			surface.SetDrawColor( Color( 0, 0, 0, 128 ) )
		
			-- Upper button ghost
			local triangle = {
				{ x = w - 15 + 15/2, y = 0 },
				{ x = w - 15 + 15,   y = 15 },
				{ x = w - 15 + 0,   y = 15 }
			}
			draw.NoTexture()
			surface.DrawPoly( triangle )
			
			-- Bar ghost
			surface.DrawRect( w - 15, 15, 15, h - 30 )
			
			-- Lower button ghost
			local triangle = {
				{ x = w - 15, y = h - 15 },
				{ x = w - 15 + 15,   y = h - 15 },
				{ x = w - 15 + 15/2, y = h }
			}
			draw.NoTexture()
			surface.DrawPoly( triangle )
		end
		
		self.Body:GetVBar().Paint = function( self, w, h )

		end

		self.Body:GetVBar().btnUp.Paint = function(self, w, h)
			local triangle = {
				{ x = w/2, y = 0 },
				{ x = w,   y = h },
				{ x = 0,   y = h }
			}
			surface.SetDrawColor(Color( 220, 127, 0, 255 ) )
			draw.NoTexture()
			surface.DrawPoly( triangle )
		end

		self.Body:GetVBar().btnGrip.Paint = function(self, w, h)
			surface.SetDrawColor(Color( 200, 107, 0, 200 ) )
			surface.DrawRect(0, 0, w, h)
		end

		self.Body:GetVBar().btnDown.Paint = function(self, w, h)
			local triangle = {
				{ x = 0,   y = 0 },
				{ x = w,   y = 0 },
				{ x = w/2, y = h }
			}

			surface.SetDrawColor(Color( 220, 127, 0, 255 ) )
			draw.NoTexture()
			surface.DrawPoly( triangle )
		end
		
		self.IconLayout = self.Body:Add("DIconLayout")
		self.IconLayout:Dock( FILL ) 
		self.IconLayout:DockMargin(0,0,0,0)
		self.IconLayout:DockPadding(0,0,0,0)
		self.IconLayout:SetBorder( scale(2) )
		self.IconLayout:SetSpaceX( scale(1) )
		self.IconLayout:SetSpaceY( scale(1) )
	end,

	Paint = function( self, w, h )
		Derma_DrawBackgroundBlur( self, self.StartTime ) 
		local border = scale(2)
		
		surface.SetDrawColor( Color( 32, 32, 32, 255-64 ) )
		surface.DrawRect(border, border, w - border * 2, h - border * 2)
	end,
	
	PerformLayout = function( self ) 
		self:Center()
	end,

	Think = function( self ) 
	end
}