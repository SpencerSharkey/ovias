--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

ENT.Type = "anim";

function ENT:GetTypeID()
	return self.typeID
end

function ENT:SharedInit()
	self:InitializeRequirements()
end

function ENT:InitializeRequirements()
	self.req = SF.Buildings:NewRequirements()

	if (self.SetupRequirements) then
		self:SetupRequirements(self.req)
	end
end

function ENT:GetRequirements()
	if (!self.req) then
		self:InitializeRequirements()
	end
	return self.req
end

function ENT:PollInfo(key)
	local info = self:GetInfo()
	return info[key] or false
end

function ENT:SetupDataTables()
	self.DT = {}

	if (self.PostSetupDTVars) then
		self.PostSetupDTVars()
	end
end

function ENT:SetFaction(faction)
	self.faction = faction
	self:SetColor(self:GetFaction():GetColor())
end

function ENT:GetFaction(faction)
	return self.faction
end

function ENT:GetBuilt()
	return self.isBuilt
end

function ENT:SetBuilt(t)
	self.isBuilt = true
end

function ENT:CalculateFoundation()

	local tri = {}

	local mins, maxs = self:OBBMins(), self:OBBMaxs()
	local topZ = mins.z
	local bottomZ = mins.z - (maxs.z*2)
	local top = {
		Vector(mins.x, maxs.y, topZ),
		Vector(maxs.x, maxs.y, topZ),
		Vector(mins.x, mins.y, topZ),
		Vector(maxs.x, mins.y, topZ)
	}
	local bottom = {
		Vector(mins.x-30, maxs.y+30, bottomZ),
		Vector(maxs.x+30, maxs.y+30, bottomZ),
		Vector(mins.x-30, mins.y-30, bottomZ),
		Vector(maxs.x+30, mins.y-30, bottomZ)
	}

	-- Top
	local UP = Vector(0, 0, 1)
	SF.Util:Quad(tri, top[1], top[2], top[3], top[4])

	--Front
	SF.Util:Quad(tri, top[3], top[4], bottom[3], bottom[4])
	--Back
	SF.Util:Quad(tri, top[2], top[1], bottom[2], bottom[1])
	--Left
	SF.Util:Quad(tri, top[4], top[2], bottom[4], bottom[2])
	--Right
	SF.Util:Quad(tri, top[1], top[3], bottom[1], bottom[3])
		
	if (CLIENT) then
		self.foundationMesh = Mesh()
		self.foundationMesh:BuildFromTriangles(tri)
	end

	local physMesh = {}
	table.Add(physMesh, top)
	table.Add(physMesh, bottom)
	self.foundationPhysicsMeshTable = physMesh

	self.foundationMeshTabe = tri

end