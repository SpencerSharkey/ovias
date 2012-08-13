--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
]]--

SF.Units = {}
SF.Units.stored = {}
SF.Units.buffer = {}

/* 
	Methods to loading units
*/

function SF.Units:LoadUnits()
	SF:Msg("Loading Units", 2)
	local _, dirs = file.Find(SF.LoaderDir.."/units/*", LUA_PATH)
	for _, unitClass in pairs(dirs) do	
		self:LoadUnit(unitClass)
	end
end

function SF.Units:LoadUnit(unitClass)
	SF:Msg("Loading Unit: "..unitClass, 3)

	UNIT = {}
	SF:IncludeDirectoryRel("units/"..unitClass, "../units/"..unitClass, 3)
	self:RegisterUnit(unitClass, UNIT)
	UNIT = nil
end

function SF.Units:RegisterUnit(unitClass, unitTable)
	self.stored[unitClass] = unitTable
end

function SF.Units:GetData(unitClass)
	if (!self.stored[unitClass]) then return false end

	local base = {}
	if (unitClass.baseClass) then
		base = self:GetData()
	end

	return table.Merge(base, self.stored[unitClass])
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

/* Network Hooks */ 

function SF.Units:SetupNetHooks()

	if (CLIENT) then
		SF:NetHook("networkUnit", function(data)
			SF.Units:New(data.class, uid)
		end)

		SF:NetHook("unitMeta", function(data)
			local uid = data.uid
			local metaData = data.data
			local Unit = SF.Units:Get(uid)
			if (!Unit) then Error("Unit value is nil") end

			// Overwrite meta data, who cares nigguh
			Unit.metaData = table.Merge(Unit.metaData, metaData)
		end)

	end

end

SF:RegisterClass("shUnits", SF.Units)


SF.Units:LoadUnits()