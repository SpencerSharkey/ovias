--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

local mBoundary = Material("effects/laser_tracer")
function SF.Territory:PostDrawOpaqueRenderables()
	render.SetMaterial(mBoundary)
	for k, v in next, self.stored do
		if (!v.drawCache) then
			v:CreateDrawCache()
		end
		v:Draw()
	end

end

function SF.Territory.metaClass:CreateDrawCache()
	self.drawCache = {}

	for k, point in next, self.points do
		if (table.HasValue(self.pointsExcluded, k)) then continue end
		local normal
		local endPoint = point + (point-self.position):Angle():Forward()*5 + Vector(0, 0, 2)
		local tr = SF.Util:SimpleTrace(point, endPoint)
		if (!tr) then
			normal = (point - self.position):Angle():Right()
		else
			normal = tr.HitNormal:Angle():Right()
		end
		
		self.drawCache[k] = {point - normal*2, point + normal*2, normal}
	end
end

--Draw selection
local mBoundary = CreateMaterial("territoryBoundary1", "UnlitGeneric", {
	["$baseTexture"] = "color/white",
	["$color"] = 1,
	["$vertexcolor"] = 1
})
function SF.Territory.metaClass:Draw()
	local amount = #self.drawCache - #self.pointsExcluded
	local color = self:GetFaction():GetColor()
	render.SuppressEngineLighting(true)
	render.SetColorModulation(color.r/255, color.g/255, color.b/255)
	render.SetMaterial(mBoundary)
	render.StartBeam(amount)
	local i = 0
	for k, pointData in next, self.drawCache do
		if (table.HasValue(self.pointsExcluded, k)) then
			render.EndBeam()
		end
		render.AddBeam(pointData[1], 2, i/amount, color)
		i = i + 1
	end
	render.EndBeam()
	render.SetColorModulation(1, 1, 1)
	render.SuppressEngineLighting(false)
	
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
	SF.Territory.boundaries = data
end)

SF:RegisterClass("clTerritory", SF.Territory)
