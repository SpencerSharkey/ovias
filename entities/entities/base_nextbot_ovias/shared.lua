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