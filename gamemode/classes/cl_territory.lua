surface.CreateFont("debug", {
	font = "Arial",
	size = 48,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})
/*
--	Ovias
--	Copyright © Slidefuse LLC - 2012
*/

if (!SF.Territory) then
	SF.Territory = {}
end

SF.Territory.tabs = {}
SF.Territory.org = false
SF.Territory.points = {};
SF.Territory.trigs = {}

function SF.Territory:PostDrawOpaqueRenderables()

	render.SetMaterial(Material("vgui/white"))

	local trr = LocalPlayer():GetEyeTraceNoCursor()
	for k, v in pairs(self.trigs) do
		for kk, vv in pairs(v) do

			local drawLines = true
			for k2, v2 in pairs(self.trigs) do
				if (k2 == k) then continue end
				for kk2, vv2 in pairs(v2) do
					local A = Vector(vv2[1].x, vv2[1].y, 0)
					local B = Vector(vv2[2].x, vv2[2].y, 0)
					if (vv2[3]) then
						local C = Vector(vv2[3].x, vv2[3].y, 0)
						if (SF.Territory:PointInTriangle(vv[1], A, B, C)) then
							drawLines = false

							break
						end
					end
				end
			end

			if (drawLines) then
				local p2 = vv[1]
				if (v[3]) then
					p2 = vv[3]
				end
				render.DrawLine(vv[1], vv[2], Color(0, 180, 0), true)
				if (p2) then
					render.DrawLine(vv[1], p2, Color(0, 255, 0), true)
				end
				render.DrawBox(vv[1], Angle(0, 0, 0), Vector(-2, -2, -2), Vector(2, 2, 2), Color(255, 0, 0), true)
			end
			
			
		end
	end

end

function SF.Territory:HUDPaint()

	local f = false;
	local trr = LocalPlayer():GetEyeTraceNoCursor()
	for k, v in pairs(self.trigs) do
		for kk, vv in pairs(v) do
			local p = vv[1]:ToScreen()
			local pp = vv[2]:ToScreen()
			
			local ppp = vv[2]:ToScreen()

			if (vv[3]) then
				ppp = vv[3]:ToScreen()
			end


			
			local poly = {
				[1] = {x = p.x, y = p.y},
				[2] = {x = pp.x, y = pp.y},
				[3] = {x = ppp.x, y = ppp.y}
			}

			local A = Vector(vv[1].x, vv[1].y, 0)
			local B = Vector(vv[2].x, vv[2].y, 0)
			if (!vv[3]) then continue end
			local C = Vector(vv[3].x, vv[3].y, 0)


			

			surface.SetTexture(surface.GetTextureID("vgui/white"))

			if (SF.Territory:PointInTriangle(trr.HitPos, A, B, C)) then
				surface.SetDrawColor(Color(0, 0, math.random(100, 200), 255))
				surface.DrawPoly(poly)

				if (!f) then
					draw.SimpleText("HIT! (T:1 - TRI:"..kk..")", "debug", ScrW()/2, ScrH()/2 - 180, Color(255, 255, 255), 1, 1)

					f = true
				end
			else
				surface.SetDrawColor(Color(0, 0, 100, 50))
				surface.DrawPoly(poly)
			end

		end
	end

	surface.SetDrawColor(Color(255,255,255))
	surface.DrawRect(ScrW()/2 - 8, ScrH()/2 - 8, 16, 16)


end
gui.EnableScreenClicker(false)


netstream.Hook("territoryTest", function(data)
	local key = CurTime()
	SF.Territory.tabs[key] = data
	local trig = {}
	local tid = 1
	data.points[#data.points+1] = data.points[1]
    for k, v in pairs(data.points) do
        trig[tid] = {
            v,
            data.org,
            data.points[k+1]
        }
        tid = tid + 1

    end

    SF.Territory.trigs[key] = trig
end)

SF:RegisterClass("clTerritory", SF.Territory)