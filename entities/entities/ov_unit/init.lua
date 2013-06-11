--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetNoDraw(true)
end

function ENT:InitUnit(Unit)
	self.Unit = Unit

	local size = Unit("size")/2
	local cMin = Vector(-size, -size, 0)
	local cMax = Vector(size, size, size*2)

	self:SetModel(Unit("model"))
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionBounds(cMin, cMax)
	self:PhysicsInitSphere(size)
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)

	local phys = self:GetPhysicsObject()
	phys:EnableGravity(false)
	
	phys:SetBuoyancyRatio(0)
	phys:SetMass(100)
	phys:SetMaterial("gmod_silent")
	phys:Activate()

	self:SetNoDraw(false)
end