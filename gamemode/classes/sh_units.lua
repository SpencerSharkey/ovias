--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
]]--

SF.Units = {}
SF.Units.stored = {}
SF.Units.buffer = {}

function SF.Units:Initialize()
	self:LoadUnits()
end

/* 
	Methods to loading units
*/

function SF.Units:LoadUnits()
	SF:Msg("Loading Units", 2)
	local _, dirs = file.Find(self.LoaderDir.."/units")
	for _, unitName in pairs(dirs) do	
		self:LoadUnit(unitName)
	end
end

function SF.Units:LoadUnit(unitName)
	SF:Msg("Loading Unit: "..unitName, 3)
	UNIT = {}
	SF:IncludeDirectory("units/"..unitName)
	self:RegisterUnit(unitName, UNIT)
end

function SF.Units:RegisterUnit(unitName, unitTable)
	self.stored[unitName] = unitTable
end

function SF.Units:GetData(unitName)
	if (!self.stored[unitName]) then return false end

	local base = {}
	if (unitName:MetaData("base")) then
		base = self:GetData()
	end

	return table.Merge(base, self.stored[unitName])
end

/*
	Methods to creating new unit instances
*/

function SF.Units:New(unitName, uid)
	local uid = uid or table.Count(self.buffer) + 1
	local u = self:GetData(unitName)

	setmetatable(u, u)

	self.buffer[uid] = u
	return u
end