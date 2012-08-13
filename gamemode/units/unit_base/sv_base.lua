--[[
	Ovias
	Copyright © Slidefuse LLC - 2012

	Unit: base
]]--


function UNIT:Init()
	self.Ent = ents.Create("ov_unit")
	self.Ent:SetUnit(self)

	self("model", "models/roller.mdl")
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
