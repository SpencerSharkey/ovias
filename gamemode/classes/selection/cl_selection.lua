--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

SF.Selection = {}
SF.Selection.selectionType = "box"

local mLine = CreateMaterial("selectionBeam55", "UnlitGeneric", {
	["$baseTexture"] = "color/white",
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1
})

function SF.Selection:UpdateMenuButtons(panel)
	panel:AddButton("B", function()
		SF.Selection:ChangeSelectionMode("box")
	end)
	panel:AddButton("L", function()
		SF.Selection:ChangeSelectionMode("lasso")
	end)
end

function SF.Selection:ChangeSelectionMode(type)
	self.selectionType = type
	print("Changing selection type")
end

function SF.Selection:Think()

	if (self.selectionType == "box") then
		if (input.IsMouseDown(MOUSE_LEFT)) then
			self.selecting = true
			if (!self.boxStart) then
				self.boxStart = {x = gui.MouseX(), y = gui.MouseY()}
			end
			
			self.boxEnd = {x = gui.MouseX(), y = gui.MouseY()}

			for id, ent in next, SF.Units:FindUnitEnts() do
				local min = ent:GetPos() + ent:OBBMins()
				local max = ent:GetPos() + ent:OBBMaxs()
				local checkpoints = {
					Vector(min.x, min.y, min.z):ToScreen(),
					Vector(max.x, min.y, min.z):ToScreen(),
					Vector(min.x, max.y, min.z):ToScreen(),
					Vector(max.x, max.y, min.z):ToScreen(),
					Vector(min.x, min.y, max.z):ToScreen(),
					Vector(max.x, min.y, max.z):ToScreen(),
					Vector(min.x, max.y, max.z):ToScreen(),
					Vector(max.x, max.y, max.z):ToScreen()
				}

				local boxMin = checkpoints[1]
				local boxMax = checkpoints[8]
				for _, point in pairs(checkpoints) do
					boxMin.x = math.min(point.x, boxMin.x)
					boxMin.y = math.min(point.y, boxMin.y)
					boxMax.x = math.max(point.x, boxMax.x)
					boxMax.y = math.max(point.y, boxMax.y)
				end
				if (self:BoxCollision(boxMin, boxMax, {x = self.boxposX, y = self.boxposY}, {x = self.boxposX + self.boxWidth, y = self.boxposY + self.boxHeight})) then
					ent.isSelected = true
				else
					ent.isSelected = false
				end
			end
		else
			self.selecting = false
			self.boxStart = nil
			self.boxEnd = nil
		end
	end

	if (self.selectionType == "lasso") then
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
end

function SF.Selection:PointInBox(pos)
	local spos = pos:ToScreen()
	return (spos.x >= self.boxposX and spos.x <= self.boxposX+self.boxWidth and spos.y >= self.boxposY and spos.y <= self.boxposY+self.boxHeight)
end

function SF.Selection:BoxCollision(boxAmin, boxAmax, boxBmin, boxBmax)
	return (boxAmin.x < boxBmax.x and boxAmax.x > boxBmin.x and boxAmin.y < boxBmax.y and boxAmax.y > boxBmin.y)
end

function SF.Selection:HUDPaint()
	surface.SetDrawColor(Color(255, 255, 0, 200))
	if (self.selectionType == "box") then
		if (self.boxStart and self.boxEnd) then
			self.boxposX = 0
			self.boxposY = 0
			self.boxWidth = 0
			self.boxHeight = 0
			if (self.boxEnd.x < self.boxStart.x and self.boxEnd.y < self.boxStart.y) then
				self.boxposX = self.boxEnd.x
				self.boxposY = self.boxEnd.y
				self.boxWidth = self.boxStart.x-self.boxEnd.x
				self.boxHeight = self.boxStart.y-self.boxEnd.y
			elseif (self.boxEnd.x > self.boxStart.x and self.boxEnd.y < self.boxStart.y) then
				self.boxposX = self.boxStart.x
				self.boxposY = self.boxEnd.y
				self.boxWidth = self.boxEnd.x-self.boxStart.x
				self.boxHeight = self.boxStart.y-self.boxEnd.y
			elseif (self.boxEnd.x < self.boxStart.x and self.boxEnd.y > self.boxStart.y) then
				self.boxposX = self.boxEnd.x
				self.boxposY = self.boxStart.y
				self.boxWidth = self.boxStart.x-self.boxEnd.x
				self.boxHeight = self.boxEnd.y-self.boxStart.y
			else
				self.boxposX = self.boxStart.x
				self.boxposY = self.boxStart.y
				self.boxWidth = self.boxEnd.x-self.boxStart.x
				self.boxHeight = self.boxEnd.y-self.boxStart.y
			end
			surface.DrawOutlinedRect(self.boxposX, self.boxposY, self.boxWidth, self.boxHeight)
			surface.DrawOutlinedRect(self.boxposX+1, self.boxposY+1, self.boxWidth-2, self.boxHeight-2)
			surface.DrawOutlinedRect(self.boxposX+2, self.boxposY+2, self.boxWidth-4, self.boxHeight-4)
			surface.SetDrawColor(Color(255, 255, 0, 20))
			surface.DrawRect(self.boxposX, self.boxposY, self.boxWidth, self.boxHeight)
			//surface.DrawOutlinedRect(self.boxposX+3, self.boxposY+3, self.boxWidth-6, self.boxHeight-6)
		end
	end

end

function SF.Selection:PostDrawOpaqueRenderables()
	if (self.selectionType == "lasso") then
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


SF:RegisterClass("clSelection", SF.Selection)