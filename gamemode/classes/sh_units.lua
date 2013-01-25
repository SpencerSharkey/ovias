--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
]]--

SF.Units = {}
SF.Units.stored = {}
SF.Units.buffer = {}

SF.Units.stored_dir = {}
SF.Units.buffer_dir = {}

/* 
	Methods to loading units
*/

function SF.Units:LoadUnits()
	SF:Msg("Loading Units", 2)
	local _, dirs = file.Find(SF.LoaderDir.."/units/*", "LUA")
	for _, unitClass in pairs(dirs) do	
		self:LoadUnit(unitClass)
	end
end

function SF.Units:LoadUnit(unitClass)
	SF:Msg("Loading Unit: "..unitClass, 3)

	UNIT = {}
	SF:IncludeDirectoryRel("units/"..unitClass, "../units/"..unitClass, 3, false)
	self:RegisterUnit(unitClass, UNIT)
	UNIT = nil
end

function SF.Units:RegisterUnit(unitClass, unitTable)
	self.stored[unitClass] = unitTable
end

function SF.Units:GetData(unitClass)
	if (!self.stored[unitClass]) then return false end
	local unitTable = self.stored[unitClass]

	local base = {}
	if (unitTable.baseClass) then
		base = self:GetData(unitTable.baseClass)
	end

	return table.Merge(base, unitTable)
end

/*
	Methods to creating new unit instances
*/

function SF.Units:New(unitClass, uid)
	local uid = uid or table.Count(self.buffer) + 1
	local u = self:GetData(unitClass)

	setmetatable(u, u)
	u:SetID(uid)

	self.buffer[uid] = u

	if (SERVER) then
		self:NetworkUnit(uid)
	end

	return u
end

function SF.Units:Get(uid)
	if (self.buffer[uid]) then
		return self.buffer[uid]
	end
	return nil
end

/* Netwokring */

function SF.Units:NetworkUnit(uid)
	local Unit = self:Get(uid)
	local netTable = {
		uid = uid,
		class = Unit("class")
	}

	SF:NetAll("networkUnit", netTable)
end


/*
	Methods to loading directives
*/

function SF.Units:LoadDirectives()
	SF:Msg("Loading Directives", 2)
	for _, dirFile in pairs(file.Find(SF.LoaderDir.."/directives/sh_*.lua", "LUA")) do
		DIRECTIVE = {}
		if (SERVER) then
			AddCSLuaFile("../directives/"..dirFile)
		end
		include("../directives/"..dirFile)
		local dirName = string.sub(dirFile, 4, string.len(dirFile)-4)
		self:RegisterDirective(dirName, DIRECTIVE)
		DIRECTIVE = nil
	end
end

function SF.Units:RegisterDirective(dirClass, dirTable)
	SF:Msg("Registered Unit Directive: "..dirClass, 3)
	self.stored_dir[dirClass] = dirTable

end

function SF.Units:GetDirectiveData(dirClass)
	if (!self.stored_dir[dirClass]) then return false end
	local dirTable = self.stored_dir[dirClass]

	local base = {}
	if (dirTable.baseClass) then
		base = self:GetDirectiveData(dirTable.baseClass)
	end

	return table.Merge(base, dirTable)
end

/* 
	Methods to creating new Directive instances 
*/


function SF.Units:NewDirective(dirClass)
	local id = table.Count(self.buffer_dir) + 1
	local d = self:GetDirectiveData(dirClass)

	setmetatable(d, d)
	d:SetID(id)

	self.buffer[id] = d

	return d
end

function SF.Units:GetDirective(id)
	if (self.buffer[id]) then
		return self.buffer[id]
	end
	return nil
end

/* Functions for spawning new units */

function SF.Units:Spawn(type)
	local un = self:New(type)
	return un;
end

SF:RegisterClass("shUnits", SF.Units)

SF.Units:LoadUnits()
SF.Units:LoadDirectives()