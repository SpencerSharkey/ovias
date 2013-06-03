--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
]]--

SF.Faction = {}
SF.Faction.Colors = {
	["Red"] = {Color(255, 0, 0), false},
	["Pink"] = {Color(255, 0, 255), false},
	["Purple"] = {Color(125, 0, 255), false},
	["Blue"] = {Color(0, 0, 255), false},
	["Light Blue"] = {Color(0, 255, 255), false}, 
	["Green"] = {Color(0, 255, 0), false},
	["Yellow"] = {Color(255, 255, 0), false},
	["Orange"] = {Color(255, 125, 0), false}
}
SF.Faction.buffer = {}

SF.Faction.metaClass = {}
SF.Faction.metaClass.__index = SF.Faction.metaClass

function SF.Faction.metaClass:Init()
	self.players = {}
	self.territories = {}
	self.buildings = {}
	self.manors = {}

	self:AssociateColor()
end

function SF.Faction.metaClass:Destroy()
	self:DisassociateColor()
end

function SF.Faction:GetBuildings()
	return self.buildings
end

function SF.Faction:AddBuilding(building)
	table.insert(self.buildings, building)
	if (building:GetClass() == "building_towncenter") then
		table.insert(self.manors, building)
	end
end

function SF.Faction:GetManors()
	return self.manors
end

function SF.Faction.metaClass:AssociateColor()
	local found = false
	while (found == false) do
		for name, tbl in pairs(SF.Faction:GetColors()) do
			if (!tbl[2]) then
				found = true
				self:SetColor(name)
				break;
			end
		end
	end
end

function SF.Faction.metaClass:DisassociateColor()
	local colorTable = self:GetColorTable()
	colorTable[2] = false
	return true
end

function SF.Faction.metaClass:GetColorTable()
	return SF.Faction.Colors[self:GetColorName()]
end

function SF.Faction.metaClass:GetColorName()
	return self.colorName
end

function SF.Faction.metaClass:GetColor()
	return self.color
end

function SF.Faction.metaClass:SetColor(name, raw)
	self.color = SF.Faction:GetColorFromName(raw)
	self.colorName = name
end

function SF.Faction.metaClass:AddPlayer(ply)
	self.players[ply] = true
end

function SF.Faction.metaClass:RemovePlayer(ply)
	self.players[ply] = nil
	if (table.Count(self.players) <= 0) then
		SF:Msg("Faction has no players, destroying.")
		self:Destroy()
	end
end

function SF.Faction.metaClass:GetPlayers()
	local ret = {}
	for k, v in pairs(self.players) do
		if (!v) then continue end
		table.insert(ret, k)
	end
	return ret
end

--Territory styff

function SF.Faction.metaClass:AddTerritory(territory)
	self.territories[territory] = true
end

function SF.Faction.metaClass:RemoveTerritory(territory)
	self.territories[territory] = nil
end

/* End */

function SF.Faction:Create()
	local o = table.Copy(SF.Faction.metaClass)
	setmetatable(o, SF.Faction.metaClass)
	SF:Call("OnFactionCreated", o)
	table.insert(self.buffer, o)
	return o
end

function SF.Faction:GetFactions()
	return self.buffer
end

function SF.Faction:GetColors()
	return self.Colors
end

function SF.Faction:GetColorFromName(name)
	return self.Colors[name]
end

SF:RegisterClass("shFaction", SF.Faction)
