--[[
    Ovias
	Copyright © Slidefuse LLC - 2013
--]]


SF.BuildMode = {}

function SF.BuildMode:StartBuild(type)
	self.isBuilding = true
	self.building = SF.Buildings:Get(type)
	self.refreshBuilding = true
end

function SF.BuildMode:StopBuild()
	self.isBuilding = false
end

function SF.BuildMode:Think()
	if (self.isBuilding) then
		if (!self.ghostEnt or self.refreshBuilding) then
			self.ghostEnt = ClientsideModel(self.building:GetOviasModel(), RENDERGROUP_OTHER)
			self.ghostEnt:SetModel(self.building:GetOviasModel())
			local c = SF.Util:SetColorAlpha(SF.Client:GetFaction():GetColor(), 255*0.75)
			self.ghostEnt:SetColor(c)
			self.ghostEnt:SetNoDraw(true)
			self.refreshBuilding = false
		end

		local trace = SF.Client:GetEyeTrace()

		local req = self.building:GetRequirements()

		self.canPlace, self.canPlaceError = req:Check(SF.Client:GetFaction(), trace, true)
		self.placePos = trace.HitPos

		self.ghostEnt:SetPos(trace.HitPos)
		local angle = (SF.Client:GetPos() - trace.HitPos):Angle()
		self.ghostEnt:SetAngles(angle)
	else
		if (self.ghostEnt) then
			self.ghostEnt:Remove()
			self.ghostEnt = nil
		end
	end
end

function SF.BuildMode:OviasLeftMousePress()
	print("WFEWFEAFEWA")
	if (self.isBuilding) then
		netstream.Start("ovPlaceBuilding", self.building:GetTypeID())
		self:StopBuild()
		return true
	end
end

netstream.Hook("ovCancelBuildMode", function(data)
	SF.BuildMode:StopBuild()
end)

function SF.BuildMode:PostDrawOpaqueRenderables()
	if (self.isBuilding and self.ghostEnt and self.canPlace) then
		render.SuppressEngineLighting(true)
			local col = self.ghostEnt:GetColor()
			render.SetBlend(0.75)
			render.SetColorModulation(col.r/255, col.g/255, col.b/255, col.a/255)
			self.ghostEnt:DrawModel()
			render.SetBlend(1)
		render.SuppressEngineLighting(false)
	end
end

function SF.BuildMode:HUDPaint()
	if (self.isBuilding and !self.canPlace and self.placePos) then
		local pos = self.placePos:ToScreen()
		surface.SetDrawColor(255, 0, 0, 255)
		surface.DrawRect(pos.x-10, pos.y-10, 20, 20)
	end
end

SF:RegisterClass("shBuilMode", SF.BuildMode)