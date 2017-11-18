exdraw = exdraw or {}
-- Draws an arc on your screen.
-- startang and endang are in degrees, 
-- radius is the total radius of the outside edge to the center.
-- cx, cy are the x,y coordinates of the center of the arc.
-- roughness determines how many triangles are drawn. Number between 1-360; 2 or 3 is a good number.
function exdraw.Arc(cx,cy,radius,thickness,startang,endang,roughness,color)
	surface.SetDrawColor(color)
	draw.NoTexture()
	exdraw.DrawArc(exdraw.PrecacheArc(cx,cy,radius,thickness,startang,endang,roughness))
end

function exdraw.PrecacheArc(cx,cy,radius,thickness,startang,endang,roughness)
	local triarc = {}
	-- local deg2rad = math.pi / 180
	
	-- Define step
	local roughness = math.max(roughness or 1, 1)
	local step = roughness
	
	-- Correct start/end ang
	local startang,endang = startang or 0, endang or 0
	
	if startang > endang then
		step = math.abs(step) * -1
	end
	
	-- Create the inner circle's points.
	local inner = {}
	local r = radius - thickness
	for deg=startang, endang, step do
		local rad = math.rad(deg)
		-- local rad = deg2rad * deg
		local ox, oy = cx+(math.cos(rad)*r), cy+(-math.sin(rad)*r)
		table.insert(inner, {
			x=ox,
			y=oy,
			u=(ox-cx)/radius + .5,
			v=(oy-cy)/radius + .5,
		})
	end
	
	
	-- Create the outer circle's points.
	local outer = {}
	for deg=startang, endang, step do
		local rad = math.rad(deg)
		-- local rad = deg2rad * deg
		local ox, oy = cx+(math.cos(rad)*radius), cy+(-math.sin(rad)*radius)
		table.insert(outer, {
			x=ox,
			y=oy,
			u=(ox-cx)/radius + .5,
			v=(oy-cy)/radius + .5,
		})
	end
	
	
	-- Triangulize the points.
	for tri=1,#inner*2 do -- twice as many triangles as there are degrees.
		local p1,p2,p3
		p1 = outer[math.floor(tri/2)+1]
		p3 = inner[math.floor((tri+1)/2)+1]
		if tri%2 == 0 then --if the number is even use outer.
			p2 = outer[math.floor((tri+1)/2)]
		else
			p2 = inner[math.floor((tri+1)/2)]
		end
	
		table.insert(triarc, {p1,p2,p3})
	end
	
	-- Return a table of triangles to draw.
	return triarc
	
end

function exdraw.DrawArc(arc) //Draw a premade arc.
	for k,v in ipairs(arc) do
		surface.DrawPoly(v)
	end
end

-- concommand.Add("test_arc", function()
	-- hook.Remove("HUDPaint", "arcTest")
	
	-- local arcs = {}
	
	-- local function AddArc()
		-- local r = math.Rand(10,250)
		-- table.insert(arcs, {
			-- r = r,
			-- t = math.Clamp(r - math.Rand(r-5,r-100),5,r-8),
			-- x = math.random(ScrW()),
			-- y = math.random(ScrH()),
			-- sa = math.random(358), 
			-- ea = math.random(358),
			-- rough = math.random(25),
			-- c = Color(math.random(255),math.random(255),math.random(255),math.random(200,255))
		-- })
	-- end
	-- timer.Create("AddArc", .5,0,AddArc)
	
	-- hook.Add("HUDPaint", "arcTest", function()
		-- for k,arc in pairs(arcs)do
			-- arc.sa = arc.sa + 5
			-- arc.ea = arc.ea + 5
			-- draw.Arc(arc.x,arc.y,arc.r,arc.t,arc.sa,arc.ea,arc.rough,arc.c)
		-- end
	-- end)
-- end)

-- local h = 100
-- hook.Add("HUDPaint","Draw Arc Healthbar",function()
	-- local x,y = 200,200
	-- local radius = 100
	-- local thickness = 20
	
	-- h = math.max(h-.1, 0)
	
	-- local startAng,endAng = 180, ( math.Round(100-h) / 100 ) * 180
	
	-- draw.Arc(x+200,y,radius,thickness,startAng,endAng,1,Color(0,255,0))
	
	-- surface.SetTextPos(x,y)
	-- surface.SetTextColor(255,255,0,255)
	-- surface.SetFont("DermaLarge")
	-- surface.DrawText(math.Round(h))
-- end)