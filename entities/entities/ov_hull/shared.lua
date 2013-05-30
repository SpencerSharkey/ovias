--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
]]--

ENT.Type = "anim";

function ENT:ApplyPhysicsMesh(meshTable)
	self:PhysicsInitConvex(meshTable)
	self:EnableCustomCollisions(true)
	self:GetPhysicsObject():Wake()
end
