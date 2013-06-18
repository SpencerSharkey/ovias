--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(self:GetOviasModel())

	
    self.modelMins, self.modelMaxs = self:OBBMins(), self:OBBMaxs()
    self.size = self.modelMaxs.x*2

    self:SetCollisionBounds(self.modelMins, self.modelMaxs)
    //self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
end

function ENT:BehaveAct()
end

function ENT:RunBehaviour()
	while ( true ) do
		coroutine.yield()
	end
end