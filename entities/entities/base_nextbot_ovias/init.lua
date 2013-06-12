--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

ENT.Base = "base_nextbot"


function ENT:Initialize()
	self:SetModel(self:GetOviasModel())
	self:SetNoDraw(true)
	
    self.modelMins, self.modelMaxs = self:OBBMins(), self:OBBMaxs()
    self.size = self.modelMaxs.x*2
    
	self:SharedInit()
end

function ENT:GetSize()
    return self.size
end

function ENT:SetFaction(faction)
    self.faction = faction
	if (SERVER) then
		netstream.Start("ovUnitFaction", {ent = self, fid = self:GetFaction():GetNetKey()})
	end
end

function ENT:GetFaction()
	return self.faction
end

function ENT:GetGroundTrace()
	return util.TraceLine({
		start = self:GetPos() + vector_up * 64,
		endpos = self:GetPos() + vector_up*-512,
		filter = self
	})
end

function ENT:GetGroundPos()
	return self:GetGroundTrace().HitPos
end

function ENT:GetGroundNormal()
	return self:GetGroundTrace().HitNormal
end

function ENT:BehaveAct()
end


function ENT:RunBehaviour()
	while ( true ) do
		//whatever
		coroutine.yield()
	end
end