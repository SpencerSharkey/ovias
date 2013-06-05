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
	self.key = SF.Util:Random()
	self.smartnet = SF.SmartNet:New(key)

	self.players = {}
	self.territories = {}
	self.buildings = {}
	self.manors = {}
	self.gold = 0

	
	if (SERVER) then
		self.smartnet:AddObject("gold")
		self.smartnet:AddObject("players")
		self.smartnet:AddObject("territories")
		self.smartnet:AddObject("buildings")
		self.smartnet:AddObject("color")
		self:AssociateColor()
	end

	if (CLIENT) then
		self.smartnet:AddCallback(function()
			if (data["gold"]) then
				self.gold = data["gold"]
			end

			if (data["players"]) then
				self.players = data["players"]
			end

			if (data["territories"]) then
				self.territories = data["territories"]
			end

			if (data["buildings"]) then
				self.buildings = data["buildings"]
				for _, ent in pairs(self.buildings) do
					if (ent:GetClass() == "building_towncenter") then
						table.insert(self.manors, ent)
					end
				end
			end

			if (data["color"]) then
				self:SetColor(data["color"])
			end
		end)
	end

end

function SF.Faction.metaClass:Destroy()
	self:DisassociateColor()
end

function SF.Faction.metaClass:GetBuildings()
	return self.buildings
end

function SF.Faction.metaClass:AddBuilding(building)
	table.insert(self.buildings, building)
	if (building:GetClass() == "building_towncenter") then
		table.insert(self.manors, building)
	end
end

function SF.Faction.metaClass:GetManors()
	return self.manors
end

function SF.Faction.metaClass:GetGold()
	return self.gold
end

function SF.Faction.metaClass:SetGold(gold)
	self.gold = gold

	if (SERVER) then
		self.smartnet:UpdateObject("gold", self.gold, true)
	end
end

function SF.Faction.metaClass:TakeGold(amount)
	self:SetGold(self:GetGold() - amount)
	return self:GetGold()
end

function SF.Faction.metaClass:GiveGold(amount)
	self:SetGold(self:GetGold() + amount)
	return self:GetGold()
end

function SF.Faction.metaClass:HasGold(amount)
	return (self:GetGold() >= amount)
end

function SF.Faction.metaClass:AssociateColor()
	local found = false
	while (found == false) do
		for name, tbl in pairs(SF.Faction:GetColors()) do
			if (!tbl[2]) then
				found = true
				self:SetColor(name)
				if (SERVER) then
					self.smartnet:UpdateObject("color", name)
				end

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

	local plytable = {}
	for ply, add in pairs(self.players) do
		if (!add) then continue end
		table.insert(plytable, ply)
	end
	self.smartnet:SetPlayers(plytable)

	--Update the player with the low-down ;)
	self.smartnet:Transfer(ply)
end

function SF.Faction.metaClass:RemovePlayer(ply)
	self.players[ply] = nil

	if (table.Count(self.players) <= 0) then
		SF:Msg("Faction has no players, destroying.")
		self:Destroy()
	else
		local plytable = {}
		for ply, add in pairs(self.players) do
			if (!add) then continue end
			table.insert(plytable, ply)
		end
		self.smartnet:SetPlayers(plytable)
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
