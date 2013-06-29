--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]


/* 
	Unit loading and registering
*/


function SF.Units:NewUnit(type, faction, pos, ang)
	local ent = ents.Create("unit_"..type)
		ent:SetFaction(faction)

		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:Spawn()
	print(ent:EntIndex(), "ID")
	if (!self.buffer[type]) then self.buffer[type] = {} end
	self.buffer[type] = ent
	return ent
end


SF:RegisterClass("svUnits", SF.Units)

