--[[
	Ovias
	Copyright © Slidefuse LLC - 2012

	Unit: base
]]--


UNIT.metaData = {}
UNIT.metaNet = {}

/* Some shared Base functions for units to use */

function UNIT:__call(key, val, network)
	if (!val and self.metaData[key]) then
		return self.metaData[key]
	else
		self.metaData[key] = val
		if (network and SERVER) then
			self.metaNet[key] = network // Can alwasy pass false incase you wanna turn netwokring off. I guess.
			self:NetworkMeta(key)
		end
	end
end

function UNIT:GetID()
	return self.UID
end

function UNIT:SetID(id)
	self.UID = id
end

function UNIT:NetworkMeta(key)
	if (self.metaData[key]) then
		local val = self.metaData[key]
		SF:Net("unitMeta", {uid = self:GetID(), data = {key = val}})
	end
end

function UNIT:NetworkAllMeta()
	local netTable = {}
	for key, send in pairs(self.meatNet) do
		if (!send) then continue end
		netTable[key] = self.metaData[key]
	end
	SF:Net("unitMeta", {uid = self:GetID(), data = netTable})
end