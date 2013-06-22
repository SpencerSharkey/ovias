--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

SF.Selection = {}

local mLine = CreateMaterial("selectionBeam5", "UnlitGeneric", {
	["$baseTexture"] = "color/white",
	["$color"] = 1,
	["$vertexcolor"] = 1
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
end

function SF.Selection:PostDrawOpaqueRenderables()
	if (self.selecting) then
		local color = SF.Client:GetFaction():GetColor()
		if (self.selectionInvalid) then
			color = colorRed
		end

		render.SuppressEngineLighting(true)
		render.SetColorModulation(color.r/255, color.g/255, color.b/255)
		render.SetMaterial(mLine)
		render.StartBeam(#self.points+1)
			for k, p in next, self.points do
				render.AddBeam(p, 2, k/#self.points+1, color)
			end
			render.AddBeam(self.points[1], 2, 1, color)
		render.EndBeam()
		render.SetColorModulation(1, 1, 1)
		render.SuppressEngineLighting(false)
	end
end

SF:RegisterClass("clSelection", SF.Selection)