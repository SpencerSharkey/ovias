--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

local UnitCircle = Material("sassilization/circle")

function SF.Units:Think()
	for id, ent in next, self:FindUnitEnts() do
		if (!ent.mergedFunctions) then
			local files, folders = file.Find("ovias/*", "LUA", "namedesc")
			ENT = ent
			include("ovias/entities/entities/base_nextbot_ovias/shared.lua")
			ent = ENT
			ent.mergedFunctions = true
		else
			if (ent.tempFaction) then
				ent:SetFaction(ent.tempFaction)
			end
			ent.tempFaction = nil
		end
		ent.previewSelection = false
	end

	self:HandleSelection()
end

function SF.Units:PostDrawOpaqueRenderables()
	self:DrawUnits()

	self:DrawSelection()
end

local VectorMeta = FindMetaTable("Vector")
function VectorMeta:Midpoint(b)
	return Vector((self.x + b.x)/2, (self.y + b.y)/2, (self.z + b.z)/2)
end

-- Handle Selection...

function SF.Units:DuringSelection(pos, radius)


	for k, ent in pairs(ents.FindInSphere(pos, radius)) do
		print(ent:GetClass())
		if (string.find(ent:GetClass(), "unit_")) then
			print("WTF")
			ent.previewSelection = true
		end
	end
end

function SF.Units:CompleteSelection(pos, radius)

end


function SF.Units:HandleSelection()
	/*if (input.IsMouseDown(MOUSE_LEFT)) then
		local trace = SF.Client:GetEyeTrace()
		if (!self.selectingEnt) then
			self.selectingEnt = ClientsideModel("models/sassilization/viewtools/debug_sphere.mdl", RENDERGROUP_TRANSLUCENT)
			self.selectingEnt:SetModel("models/sassilization/viewtools/debug_sphere.mdl")
			self.selectingEnt:SetPos(trace.HitPos)
			self.selectionStart = trace.HitPos
			local col = SF.Client:GetFaction():GetColor()
			col.a = 50
			self.selectingEnt:SetColor(col)
			self.selectingEnt:SetNoDraw(true)
		end
		self.selectionEnd = trace.HitPos
		self.selectionRadius = math.Clamp(self.selectionStart:Distance(self.selectionEnd)/2, 0, 128)

		if (self.selectionRadius >= 128) then
			self.selectionEnd = self.selectionStart + (self.selectionEnd-self.selectionStart):GetNormalized()*256
			self.selectionRadius = math.Clamp(self.selectionStart:Distance(self.selectionEnd)/2, 0, 128)
		end

		self.selectingEnt:SetPos(self.selectionStart:Midpoint(self.selectionEnd))

		self.circlePoints = {}
		local vOffset = Vector()
		local centerPos = self.selectingEnt:GetPos()
		self.selectionInvalid = false
		for i = 0, math.pi*2, math.pi/16 do
			vOffset.x = math.cos(i)
			vOffset.y = math.sin(i)

			local startPos = centerPos + vOffset*self.selectionRadius + Vector(0, 0, 1000)
			local endPos = startPos - Vector(0, 0, 2000)

			local tr = SF.Util:SimpleTrace(startPos, endPos)
			if (tr.Hit) then
				local id = table.insert(self.circlePoints, tr.HitPos + Vector(0, 0, 2))

				
				if (self.circlePoints[id-1]) then
					local difference = math.abs(tr.HitPos.z-self.circlePoints[id-1].z)
					if (difference >= 30) then
						self.selectionInvalid = true
					end
				end
			end
		end
		table.insert(self.circlePoints, self.circlePoints[1])

		self.centerPos = centerPos
		self:DuringSelection(self.centerPos, self.selectionRadius)
	else
		if (self.selectingEnt) then
			self.selectingEnt:Remove()
			self.selectingEnt = nil
			self:CompleteSelection(self.centerPos, self.selectionRadius)
		end
	end*/
end


--Draw selection
local mBoundary = CreateMaterial("selectionBeam5", "UnlitGeneric", {
	["$baseTexture"] = "color/white",
	["$color"] = 1,
	["$vertexcolor"] = 1
})

local colorRed = Color(255, 0, 0)
function SF.Units:DrawSelection()
	if (self.selectingEnt) then

		--Selection Sphere
		render.SuppressEngineLighting(true)
			local col = self.selectingEnt:GetColor()
			render.SetColorModulation(col.r/255, col.g/255, col.b/255, col.a/255)
			render.SetBlend(col.a/255)
			local scale = self.selectionRadius

			self.selectingEnt:SetModelScale(scale, 0)

			self.selectingEnt:DrawModel()
			render.SetBlend(1)
			render.SetColorModulation(1, 1, 1, 1)
		render.SuppressEngineLighting(false)


		--Selection Ring
		local color = SF.Client:GetFaction():GetColor()
		if (self.selectionInvalid) then
			color = colorRed
		end

		render.SuppressEngineLighting(true)
		render.SetColorModulation(color.r/255, color.g/255, color.b/255)
		render.SetMaterial(mBoundary)
		render.StartBeam(#self.circlePoints)
			for k, p in next, self.circlePoints do
				render.AddBeam(p, 2, k/#self.circlePoints, color)
			end
		render.EndBeam()
		render.SetColorModulation(1, 1, 1)
		render.SuppressEngineLighting(false)
		
	end
end

SF.Units.flatCircle = ClientsideModel( "models/sassilization/flatcircle.mdl" )
SF.Units.flatCircle:SetNoDraw( true )
local constScale = Vector(1, 1, 1)
local matWhite = CreateMaterial("whiteBlank1", "UnlitGeneric", {["$basetexture"] = "vgui/white"})
function SF.Units:DrawUnits()


	for id, ent in next, self:FindUnitEnts() do
		if (ent.previewSelection) then
			ent:DrawFlatCircle(ent:GetSize()*1.8)
		end
	end
	--Selection Preview thingz
	/*if (self.selectingEnt) then
		cam.Start3D(EyePos(), EyeAngles())
		render.ClearStencil()
		render.SetStencilEnable(true)
		render.SetStencilFailOperation(STENCILOPERATION_KEEP)
		render.SetStencilZFailOperation(STENCILOPERATION_REPLACE)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
		render.SetStencilReferenceValue(1)

			

		render.SetStencilReferenceValue(2)

			for id, ent in next, self:FindUnitEnts() do
				if (ent.previewSelection) then
					ent:DrawFlatCircle(ent:GetSize()*1.2)
				end
			end

		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
		render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
		render.SetStencilReferenceValue(1)

		render.SetMaterial(matWhite)
		render.DrawScreenQuad()

		render.SetStencilEnable(false)
		cam.End3D()
	end*/


	for id, ent in next, self:FindUnitEnts() do
		if (!ent.mergedFunctions or !ent:GetFaction()) then continue end

		ent:Draw()
	end
end

netstream.Hook("ovUnitFaction", function(data)
	local faction = SF.Faction:GetByNetKey(data.fid)
	local ent = Entity(data.ent)
	ent.tempFaction = faction
end)

SF:RegisterClass("clUnits", SF.Units)