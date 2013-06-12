--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

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
SF.Faction.netBuffer = {}

SF.Faction.metaClass = {}
SF.Faction.metaClass.__index = SF.Faction.metaClass

function SF.Faction.metaClass:Init(keyO)
	self.key = keyO or SF.Util:Random()
	SF.Faction.netBuffer[self.key] = self

	self.smartnet = SF.SmartNet:New(self.key)
	self.smartnet:SetObject(self)

	self.players = {}
	self.territories = {}
	self.buildings = {}
	self.units = {}
    self.resources = {}
	self.gold = 0

	
	if (SERVER) then
		self.smartnet:AddObject("gold", 0)
		self.smartnet:AddObject("players", {})
		self.smartnet:AddObject("territories", {})
		self.smartnet:AddObject("units", {})
		self.smartnet:AddObject("buildings", {})
		self.smartnet:AddObject("color", Color(0, 0, 0))
        self.smartnet:AddObject("resources", {})
		self:AssociateColor()
	end

	if (CLIENT) then
		self.territoryBuffer = {}
		self.smartnet:AddCallback(function(data, faction)
			if (data.gold) then
				faction.gold = data.gold
			end

			if (data.player) then
				faction.players = data.players
			end

			if (data.territories) then
				faction.territoryBuffer = table.Merge(faction.territoryBuffer, data.territories)
			end

			if (data.buildings) then
				faction.buildings = data.buildings
			end

			if (data.units) then
				faction.units = data.units
			end
            
            if (data.resources) then
                faction.resources = data.resources
            end

			if (data.color) then
				faction:SetColor(data.color)
			end
		end)
	end

end

function SF.Faction.metaClass:UpdateTerritoryBuffer(territory)
	local id = territory.index

	for nKey, netID in next, self.territoryBuffer do
		if (netID == id) then
			self:AddTerritory(territory)
			self.territoryBuffer[nKey] = nil
		end
	end

end

function SF.Faction.metaClass:GetNetKey()
	return self.key
end

function SF.Faction.metaClass:Destroy()
	self:DisassociateColor()
end

function SF.Faction.metaClass:GetBuildings()
	return self.buildings
end

function SF.Faction.metaClass:GetBuildingsOfType(type)
	if (!self.buildings[type]) then return {} end
	return self.buildings[type]
end

function SF.Faction.metaClass:AddBuilding(building)
	local btype = building:GetTypeID()
	if (!self.buildings[btype]) then
		self.buildings[btype] = {}
	end

	table.insert(self.buildings[btype], building)

	if (SERVER) then
		self.smartnet:UpdateObject("buildings", self.buildings, true)
	end
end

function SF.Faction.metaClass:GetUnits()
	return self.units
end

function SF.Faction.metaClass:GetUnitsOfType(type)
	if (!self.units[type]) then return {} end
	return self.units[type]
end

function SF.Faction.metaClass:AddUnit(unit)
	local utype = unit:GetTypeID()
	if (!self.units[utype]) then
		self.units[utype] = {}
	end

	table.insert(self.units[utype], unit)

	if (SERVER) then
		self.smartnet:UpdateObject("units", self.units, true)
	end
end

function SF.Faction.metaClass:GetResources()
    return self.resources
end

function SF.Faction.metaClass:GetResource(rtype)
    if (self.resources[rtype]) then
        return self.resources[rtype]
    end
    return 0
end

function SF.Faction.metaClass:SetResource(rtype, amount)
    self.resources[rtype] = amount
    
    if (SERVER) then
        self.smartnet:UpdateObject("resources", self.resources, true)
    end
end

function SF.Faction.metaClass:AddResource(rtype, amount)
    self:SetResource(rtype, self.resources[rtype] + amount)
end

function SF.Faction.metaClass:TakeResource(rtype, amount)
    self:SetResource(rtype, self.resources[rtype] - amount)
end

function SF.Faction.metaClass:GetGold()
	return self.gold
end

if SERVER then
	function SF.Faction.metaClass:SetGold(gold)
		self.gold = gold

		if SERVER then
			self.smartnet:UpdateObject("gold", self.gold, true)
		end
	end
else
	function SF.Faction.metaClass:SetGold(gold)
		self.gold = gold
	end
end

function SF.Faction.metaClass:TakeGold(amount)
	self:SetGold(self.gold - amount)
end

function SF.Faction.metaClass:GiveGold(amount)
	self:SetGold(self.gold + amount)
end

function SF.Faction.metaClass:HasGold(amount)
	return (self.gold >= amount)
end

function SF.Faction.metaClass:AssociateColor()
	--Bruteforce the colors. Worst code in gamemode.
	while (true) do
		local tbl = table.Random(SF.Faction:GetColors())
		local name = table.KeyFromValue(SF.Faction:GetColors(), tbl)
		if (!tbl[2]) then
			self:SetColor(name)
			if (SERVER) then
				self.smartnet:UpdateObject("color", name)
			end
			break
		end
	end
end

function SF.Faction.metaClass:DisassociateColor()
	self:GetColorTable()[2] = false
end

function SF.Faction.metaClass:GetColorTable()
	return SF.Faction.Colors[self:GetColorName()]
end

function SF.Faction.metaClass:GetColorName()
	return self.colorName
end

function SF.Faction.metaClass:GetName()
	return self:GetColorName().." Kingdom"
end

function SF.Faction.metaClass:GetColor()
	return table.Copy(self.color)
end

function SF.Faction.metaClass:SetColor(name)
	self.color = SF.Faction:GetColorFromName(name)
	self.colorName = name
end

function SF.Faction.metaClass:AddPlayer(ply)
	self.players[ply] = true
	self:UpdateSmartnetPlayers()
	self.smartnet:Transfer(ply)
end

function SF.Faction.metaClass:RemovePlayer(ply)
	self.players[ply] = nil

	if (table.Count(self.players) <= 0) then
		SF:Msg("Faction has no players, destroying.")
		self:Destroy()
	else
		self:UpdateSmartnetPlayers()
	end
end

function SF.Faction.metaClass:UpdateSmartnetPlayers()
	local plytable = {}
	for ply in next, self.players do
		table.insert(plytable, ply)
	end
	self.smartnet:SetPlayers(plytable)
end

function SF.Faction.metaClass:GetPlayers()
	local ret = {}
	for k in next, self.players do
		ret[#ret+1] = k
	end
	return ret
end


--Territory styff
function SF.Faction.metaClass:AddTerritory(territory)
	self.territories[territory.index] = territory

	if (SERVER) then
		local netTable = {}
		for index in next, self.territories do
			netTable[#netTable+1] = index
		end

		self.smartnet:UpdateObject("territories", netTable, true)
	end
end

function SF.Faction.metaClass:RemoveTerritory(territory)
	if (type(territory) == "number") then
		self.territories[territory] = nil
	else
		self.territories[territory.index] = nil
	end
end

function SF.Faction.metaClass:GetTerritory(index)
	return self.territories[index]
end

function SF.Faction.metaClass:GetTerritories()
	return self.territories
end

function SF.Faction.metaClass:PointInInfluence(point)
	for _, territory in next, self.territories do
		if (territory:PointInArea(point)) then
			return true, territory
		end
	end
	return false
end

/* End */

function SF.Faction:OnTerritoryNetworked(territory)
	--Assuming the territory was added to the faction... lets add it finally since we have the data :)
	territory:GetFaction():UpdateTerritoryBuffer(territory)
end

function SF.Faction:Create(keyO)
	local o = setmetatable({}, SF.Faction.metaClass)
	table.insert(self.buffer, o)
	o:Init(keyO)
	SF:Call("OnFactionCreated", o)
	return o
end

function SF.Faction:GetByNetKey(key)
	return self.netBuffer[key]
end

function SF.Faction:GetFactions()
	return self.buffer
end

function SF.Faction:GetColors()
	return self.Colors
end

function SF.Faction:GetColorFromName(name)
	return self.Colors[name][1]
end

SF:RegisterClass("shFaction", SF.Faction)
