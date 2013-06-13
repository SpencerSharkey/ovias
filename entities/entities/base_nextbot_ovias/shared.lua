--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

if (SERVER) then
	ENT.Base = "base_nextbot"
else
	ENT.Type = "anim"
	ENT.Base = "base_anim"
end

function ENT:GetSize()
	if (!self.size) then
		self.modelMins, self.modelMaxs = self:OBBMins(), self:OBBMaxs()
    	self.size = self.modelMaxs.x
	end

    return self.size
end

function ENT:SetFaction(faction)
    self.faction = faction
	if (SERVER) then
		netstream.Start(player.GetAll(), "ovUnitFaction", {ent = self:EntIndex(), fid = self:GetFaction():GetNetKey()})
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

