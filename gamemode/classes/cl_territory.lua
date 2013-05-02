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

local mat = Material("effects/laser_tracer")
function SF.Territory:PostDrawOpaqueRenderables()

	render.SetMaterial(mat)

	for k, v in pairs(self.stored) do
		v:Draw()
	end

	/*
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
	*/

end

function SF.Territory:HUDPaint()
	local tr = LocalPlayer():GetEyeTraceNoCursor()
	for k, v in pairs(self.stored) do
		//print(v:PredictTriangle(tr.HitPos))
		debugoverlay.Text(tr.HitPos+Vector(0, 0, 10), v:PredictTriangle(tr.HitPos), FrameTime())
		break
	end
end


netstream.Hook("territoryStream", function(data)
	local t = SF.Territory:CreateRaw()
	t:LoadNetworkTable(data)
	table.insert(SF.Territory.stored, t)
end)

SF:RegisterClass("clTerritory", SF.Territory)