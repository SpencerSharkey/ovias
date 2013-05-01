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
SF.Territory.tabs = {}
SF.Territory.org = false
SF.Territory.points = {};
SF.Territory.trigs = {}

function SF.Territory:PostDrawOpaqueRenderables()

	render.SetMaterial(Material("vgui/white"))

	local trr = LocalPlayer():GetEyeTraceNoCursor()
	for k, tr in pairs(self.buffer) do
		local v = tr.triangles
		for kk, vv in pairs(tr.points) do

			render.DrawLine(tr.position, vv, Color(0, 255, 0), true)

			if (!table.HasValue(tr.excludePoints, kk)) then
				render.DrawBox(vv, Angle(0, 0, 0), Vector(-2, -2, -2), Vector(2, 2, 2), Color(255, 0, 0), true)
			end

		end
	end

end

function SF.Territory:HUDPaint()

	local f = false;
	local trr = LocalPlayer():GetEyeTraceNoCursor()
	for k, tr in pairs(self.buffer) do
		local v = tr.triangles
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
			surface.SetDrawColor(Color(255, 0, math.random(0, 150), 100))


		end
	end

	surface.SetDrawColor(Color(255,255,255))
	surface.DrawRect(ScrW()/2 - 8, ScrH()/2 - 8, 16, 16)


end
gui.EnableScreenClicker(false)


netstream.Hook("territoryStream", function(data)
	local t = SF.Territory:CreateRaw()
	t:LoadNetworkTable(data)
	table.insert(SF.Territory.buffer, t)
end)

SF:RegisterClass("clTerritory", SF.Territory)