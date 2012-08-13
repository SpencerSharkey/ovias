--[[
	Ovias
	Copyright © Slidefuse LLC - 2012

	Unit: base
]]--


function UNIT:Init()
	self("model", "models/roller.mdl")
	self("size", 8)
	self("speed", 5)

	self.Ent = ents.Create("ov_unit")
	self.Ent:InitUnit(self)
end

function UNIT:GetPos()
	return self.Ent:GetPos()
end

function ENT:GetAngles()
	return self.Ent:GetAngles()
end

function UNIT:SetPos(v)
	if (!IsValid(self.Ent)) then return end
	self.Ent:SetPos(v)
end

function UNIT:SetAngles(a)
	self.Ent:SetAngles(a)
end

function UNIT:SetColor(c)
	self.Ent:SetColor(c)
end
