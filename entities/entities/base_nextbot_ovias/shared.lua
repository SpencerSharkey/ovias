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

local mCircle = Material("sassilization/circle")
function ENT:Draw()
	self:DrawCircle(self:GetSize())
end

function ENT:DrawCircle(size, color)
	render.SetMaterial(mCircle)
	local color = color or self:GetFaction():GetColor()
	if (self.isSelected)then
		color = Color(255, 0, 0)
	end
	render.DrawQuadEasy(self:GetGroundPos() + Vector(0, 0, 1) * 0.1, self:GetGroundNormal(), size, size, color)
end

function ENT:DrawFlatCircle(size)
	SF.Units.flatCircle:SetPos(self:GetGroundPos() + Vector(0, 0, 1) * 0.1)
	SF.Units.flatCircle:SetModelScale(size, 0)
	local ang = self:GetGroundNormal():Angle()
	ang:RotateAroundAxis(Vector(1, 0, 0), -90)
	
	SF.Units.flatCircle:SetAngles()
	SF.Units.flatCircle:DrawModel()
	//render.DrawQuadEasy(, self:GetGroundNormal(), size, size, self:GetFaction():GetColor())
end