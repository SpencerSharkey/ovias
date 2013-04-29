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


	for k, v in pairs(self.trigs) do
		for kk, vv in pairs(v) do
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
			surface.SetTexture(surface.GetTextureID("vgui/white"))

			if (SF.Territory:TriangleTest(trr.HitPos, vv)) then
				surface.SetDrawColor(Color(0, 0, 100, 255))
				surface.DrawPoly(poly)

				surface.SetDrawColor(Color(255, 255, 0))
				surface.DrawLine(p.x, p.y, pp.x, pp.y)
				surface.DrawLine(pp.x, pp.y, ppp.x, ppp.y)
				surface.DrawLine(ppp.x, ppp.y, p.x, p.y)

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