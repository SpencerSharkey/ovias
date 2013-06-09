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
		if (!v.drawCache) then
			v:CreateDrawCache()
		end
		v:Draw()
	end

end

function SF.Territory.metaClass:CreateDrawCache()
	self.drawCache = {}

	for k, point in pairs(self.points) do
		if (table.HasValue(self.pointsExcluded, k)) then continue end
		local normal
		local endPoint = point + (point-self.position):Angle():Forward()*5 + Vector(0, 0, 2)
		local tr = SF.Util:SimpleTrace(point, endPoint)
		if (!tr) then
			normal = (point - self.position):Angle():Right()
		else
			normal = tr.HitNormal:Angle():Right()
		end
		
		self.drawCache[k] = {point, normal}
	end
end

function SF.Territory.metaClass:Draw()
	for k, pointData in pairs(self.drawCache) do
		if (table.HasValue(self.pointsExcluded, k)) then continue end
		local point = pointData[1]
		local normal = pointData[2]
		local testPoint = pointData[3]
		render.DrawBeam(point - normal*2, point + normal*2, 3, 0.5, 0.75, self:GetFaction():GetColor())
	end
end

netstream.Hook("territoryRemove", function(data)
	SF.Territory.stored[data]:Remove()
end)

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
	print("Receiving new boundary update...")
	SF.Territory.boundaries = data
end)

SF:RegisterClass("clTerritory", SF.Territory)
