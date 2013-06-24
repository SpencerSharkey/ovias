--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

SF.Selection = {}

local mLine = CreateMaterial("selectionBeam55", "UnlitGeneric", {
	["$baseTexture"] = "color/white",
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1
})

function SF.Selection:Think()
	if (input.IsMouseDown(MOUSE_LEFT)) then
		local trace = SF.Client:GetEyeTrace()
		if (!self.selecting) then
			self.selecting = true
			self.startPos = trace.HitPos
			self.points = {}
		end
		
		if (!table.HasValue(self.points, trace.HitPos)) then
			table.insert(self.points, trace.HitPos)
		end

	else
		if (self.selecting) then
			local trace = SF.Client:GetEyeTrace()
			self.selecting = false
			self.points = {}
			self.endPos = trace.HitPos
		end
	end

	if (self.selecting) then
		for id, ent in next, SF.Units:FindUnitEnts() do
			local pos = ent:GetPos()
			if (self:PointInPolygon(self.points, pos)) then
				ent.isSelected = true
			else
				ent.isSelected = false
			end
		end
		
	end
end

function SF.Selection:PointInPolygon(pointList, p)
	local pointList = table.Copy(pointList)
	table.insert(pointList, pointList[1])
	local counter = 0
	local i = 0
	local xinters = 0
	local p1
	local p2 
	local n = #pointList
	p1 = pointList[1]
	for i = 1, n do
		p2 = pointList[(i % n) + 1]
		if (p.y > math.Min(p1.y, p2.y)) then
			if (p.y  <= math.Max(p1.y, p2.y)) then
				if (p.x <= math.Max(p1.x, p2.x)) then
					if (p1.y != p2.y) then
						xinters = (p.y - p1.y) * (p2.x - p1.x) / (p2.y - p1.y) + p1.x
						if (p1.x == p2.x || p.x <= xinters) then
							counter = counter + 1
						end
					end
				end
			end
		end
		p1 = p2
	end
	if (counter % 2 == 0) then
		return false
	end
	return true
end


function SF.Selection:PostDrawOpaqueRenderables()
	if (self.selecting) then

		local color = Color(255, 216, 0)
		local i = 0
		local c = false
		render.SetMaterial(mLine)
		render.StartBeam(#self.points)
			for k, p in next, self.points do
				i = i + 1
				if (i >= 3) then
					if (!c) then
						color = Color(255, 50, 0, 150)
					else
						color = Color(255, 216, 0, 150)
					end
					c = !c
					i = 0
				end

				render.AddBeam(p, 2, k/#self.points, color)
			end
		render.EndBeam()

	end
end

SF:RegisterClass("clSelection", SF.Selection)