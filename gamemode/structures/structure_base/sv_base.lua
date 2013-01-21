--[[
	Ovias
	Copyright © Slidefuse LLC - 2012

	Unit: base
]]--


function STRUCTURE:Init()
	self("model", "models/roller.mdl")
	self("size", 8)
	self("speed", 5)

	self.Ent = ents.Create("ov_unit")
	self.Ent:InitUnit(self)
end

function STRUCTURE:GetPos()
	return self.Ent:GetPos()
end

function STRUCTURE:GetAngles()
	return self.Ent:GetAngles()
end

function STRUCTURE:SetPos(v)
	if (!IsValid(self.Ent)) then return end
	self.Ent:SetPos(v)
end

function STRUCTURE:SetAngles(a)
	self.Ent:SetAngles(a)
end

function STRUCTURE:SetColor(c)
	self.Ent:SetColor(c)
end
