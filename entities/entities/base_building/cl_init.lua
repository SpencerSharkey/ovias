--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

include("shared.lua")

function ENT:Initialize()

	self.foundationMatrix = Matrix()
	self.modifyMatrix = Matrix()
	self:CalculateFoundation()

	self.modelMins, self.modelMaxs = self:OBBMins(), self:OBBMaxs()
	self.isBuilding = true
	self.isBuilt = false
	self.buildProgress = 0
	self.buildTicks = 0




	self:SharedInit()

	SF.Entity:ClientsideInit(self)
end

local mFoundation = CreateMaterial("ovFoundation1", "VertexLitGeneric", {
	["$basetexture"] = "nature/dirtwall001a",
	["$model"] = 1
})

local mBuilder = CreateMaterial("ovBuildMesh5", "VertexLitGeneric", {
	["$basetexture"] = "ovias/buildframe",
	["$translucent"] = 1,
	["$model"] = 1,
	["$alpha"] = 0.5
})

local mWire = Material("models/wireframe")

local up = Vector(0, 0, 1)

local down = Vector(0, 0, -1)

function ENT:Draw()

	--Draw foundation
	render.SetMaterial(mFoundation)

	self.foundationMatrix:SetAngles(self:GetAngles())
	self.foundationMatrix:SetTranslation(self:GetPos())

	render.SuppressEngineLighting(true)
	cam.PushModelMatrix(self.foundationMatrix)
		self.foundationMesh:Draw()
	cam.PopModelMatrix()
	render.SuppressEngineLighting(false)

	--Building Rendering
	if (self.isBuilding) then



		local buildProgress = self.buildProgress
		local height = self.modelMaxs.z
		local clipHeight = (buildProgress/100)*height

		local pos = self:GetPos()
		pos.z = pos.z + clipHeight
		pos.x = 0
		pos.y = 0


		local distance = down:Dot(pos)
		render.MaterialOverride("")
		render.EnableClipping(true)
			render.PushCustomClipPlane(down, distance)
			render.CullMode(MATERIAL_CULLMODE_CW)
			self:DrawModel()
			render.CullMode(MATERIAL_CULLMODE_CCW)
			self:DrawModel()

			render.PopCustomClipPlane()

			distance = up:Dot(pos)
			render.MaterialOverride(mBuilder)
			render.SetColorModulation(1, 1, 1, 1)
			render.PushCustomClipPlane(up, distance)

			render.CullMode(MATERIAL_CULLMODE_CW)
			render.SuppressEngineLighting(true)
			render.SetColorModulation(0.5, 0.5, 0.5, 1)
			self:DrawModel()

			render.SetColorModulation(1, 1, 1, 1)
			render.SuppressEngineLighting(false)
			render.CullMode(MATERIAL_CULLMODE_CCW)
			self:DrawModel()

			render.PopCustomClipPlane()
		render.EnableClipping(false)
		render.MaterialOverride(false)

	else
		self:DrawModel()

	end

end

function ENT:Think()
	if (self.isBuilding) then
        self.buildProgress = (self.buildTicks/self:GetBuildTicks()) * 100
	end
end

function ENT:ProgressBuild(data)
	if (!self.isBuilding) then return end
	if (self.buildTicks >= self:GetBuildTicks()) then 
		self.isBuilding = false
		self.isBuilt = true
	end
    SF:Call("BuildingProgressBuild", self)
	self.buildTicks = data
end

netstream.Hook("ovB_ProgressBuild", function(data)
	local ent = data.ent
	ent:ProgressBuild(data.buildTicks)
end)

netstream.Hook("ovB_StartBuild", function(data)
	local ent = data.ent
	ent.startBuildTime = CurTime()
	ent.isBuilding = true
end)

netstream.Hook("ovB_FinishBuild", function(data)
    local ent = data.ent
	ent.endBuildTime = CurTime()
	ent.isBuilding = false
end)