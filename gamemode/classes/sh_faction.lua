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
	self.manors = {}
	self.gold = 0

	
	if (SERVER) then
		self.smartnet:AddObject("gold", 0)
		self.smartnet:AddObject("players", {})
		self.smartnet:AddObject("territories", {})
		self.smartnet:AddObject("buildings", {})
		self.smartnet:AddObject("color", Color(0, 0, 0))
		self:AssociateColor()
	end

	if (CLIENT) then
		self.territoryBuffer = {}
		self.smartnet:AddCallback(function(data, faction)
			SF:Msg("Receving callback for faction: "..faction:GetNetKey(), 3)
			if (data["gold"]) then
				faction.gold = data["gold"]
			end

			if (data["players"]) then
				faction.players = data["players"]
			end

			if (data["territories"]) then
				faction.territoryBuffer = table.Merge(faction.territoryBuffer, data["territories"])
			end

			if (data["buildings"]) then
				faction.buildings = data["buildings"]
				print("got sent a new building table!")
			end

			if (data["color"]) then
				faction:SetColor(data["color"])
			end
		end)
	end

end

function SF.Faction.metaClass:UpdateTerritoryBuffer(territory)
	local id = territory.index
	

	for nKey, netID in pairs(self.territoryBuffer) do
		if (netID == id) then
			self:AddTerritory(territory)
			self.territoryBuffer[nKey] = nil
			print("Got a territory I guess...", id)
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
	--Bruteforce the colors.
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

function SF.Faction.metaClass:GetName()
	return self:GetColorName().." Kingdom"
end

function SF.Faction.metaClass:GetColor()
	return self.color
end

function SF.Faction.metaClass:SetColor(name)
	self.color = SF.Faction:GetColorFromName(name)
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
	self.territories[territory.index] = territory

	if (SERVER) then
		local netTable = {}
		for index, territory in pairs(self.territories) do
			table.insert(netTable, index)
		end

		self.smartnet:UpdateObject("territories", netTable, true)
		print("Sending ova these niggaS:")
		PrintTable(netTable)
	end
end

function SF.Faction.metaClass:RemoveTerritory(territory)
	if (type(territory) == "number") then
		if (self.territries[territory]) then
			self.territories[territory] = nil
		else
			error("Tried removing territory but value was nil")
		end
	else
		local index = territory.index
		self.territories[index] = nil
	end
end

function SF.Faction.metaClass:GetTerritory(index)
	return self.territories[index]
end

function SF.Faction.metaClass:GetTerritories()
	return self.territories
end

function SF.Faction.metaClass:PointInInfluence(point)
	for _, territory in pairs(self:GetTerritories()) do
		if (territory:PointInArea(point)) then
			return true, territory
		end
	end
	return false
end

/* End */

function SF.Faction:OnTerritoryNetworked(territory)
	--Assuming the territory was added to the faction... lets add it finally since we have the data :)
	local faction = territory:GetFaction()
	faction:UpdateTerritoryBuffer(territory)
end

function SF.Faction:Create(keyO)
	local o = table.Copy(SF.Faction.metaClass)
	setmetatable(o, SF.Faction.metaClass)
	table.insert(self.buffer, o)
	o:Init(keyO)
	SF:Call("OnFactionCreated", o)
	print("New Faction Created, ID: "..o:GetNetKey())
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
	local colTable = self.Colors[name]
	return colTable[1]
end

SF:RegisterClass("shFaction", SF.Faction)
