--[[
	Ovias
	Copyright © Slidefuse LLC - 2013
]]--


SF.BuildMode = {}

function SF.BuildMode:StartBuild(type)
	self.building = true
	self.building = SF.Buildings:Get(type)
end

function SF.BuildMode:StopBuild()
	self.building = false
end

function SF.BuildMode:Think()
	if (self.building) then
		if (!self.ghostEnt) then
			self.ghostEnt = ClientsideModel(self.building:GetOviasModel(), RENDERGROUP_OTHER)
			self.ghostEnt:SetModel(self.building:GetOviasModel())
			local c = SF.Util:SetColorAlpha(SF.Client:GetFaction():GetColor(), 255*0.75)
			self.ghostEnt:SetColor(c)
			self.ghostEnt:SetNoDraw(true)
		end
		local trace = SF.Client:GetEyeTrace()
		self.ghostEnt:SetPos(trace.HitPos)
	else
		if (self.ghostEnt) then
			self.ghostEnt:Remove()
			self.ghostEnt = nil
		end
	end
end

function SF.BuildMode:PostDrawOpaqueRenderables()
	if (self.ghostEnt) then
	render.SuppressEngineLighting(true)
		local col = self.ghostEnt:GetColor()
		render.SetBlend(0.75)
		render.SetColorModulation(col.r/255, col.g/255, col.b/255, col.a/255)
		self.ghostEnt:DrawModel()
		render.SetBlend(1)
	render.SuppressEngineLighting(false)
	end
end

SF:RegisterClass("shBuilMode", SF.BuildMode)