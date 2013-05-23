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

	render.SetMaterial(mat)

	for _, boundary in pairs(self.boundaries) do
		render.StartBeam(table.Count(boundary))
		print(table.Count(boundary))
		for _, pointData in pairs(boundary) do
			local p = self.stored[pointData[1]].points[pointData[2]]
			print(p)
			render.AddBeam(p, 3, CurTime(), Color(255, 255, 0))
		end
		render.EndBeam()
	end

end

function SF.Territory.metaClass:Draw()
	for k, point in pairs(self.points) do

		if (table.HasValue(self.pointsExcluded, k)) then continue end
		local normal = (point - self.position):Angle():Right()
		render.DrawBeam(point - normal*2, point + normal*2, 3, 0.5, 0.75, Color(255, 255, 0))

	end
end


netstream.Hook("territoryStream", function(data)
	print("Receiving new territory: "..data.index)
	if (!SF.Territory.stored[data.index]) then
		local t = SF.Territory:CreateRaw()
		t:LoadNetworkTable(data)
		SF.Territory.stored[data.index] = t
	else
		local t = SF.Territory.stored[data.index]
		t:LoadNetworkTable(data)
	end
	
end)

netstream.Hook("boundaryStream", function(data)
	print("Receiving new boundary update")
	PrintTable(data)
	SF.Territory.boundaries = data
end)

SF:RegisterClass("clTerritory", SF.Territory)