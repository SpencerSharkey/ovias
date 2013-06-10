--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
]]--

SF.Buildings = {}
SF.Buildings.stored = {}
SF.Buildings.buffer = {}

/* 
	Buildings loading and registering
*/

function SF.Buildings:LoadBuildings()
	SF:Msg("###############################################")
	SF:Msg("# Loading Buildings...")
	local files, folders = file.Find(SF.LoaderDir.."/buildings/*", "LUA", "namedesc")

	for k, v in next, files do
		if (v != ".." and v != ".") then

			local baseName = string.sub(v, 1, -5)

			ENT = {Base = "base_building", Folder = SF.LoaderDir.."/buildings"}

			if (SERVER) then
				AddCSLuaFile(SF.LoaderDir.."/buildings/"..v)	
			end
			include(SF.LoaderDir.."/buildings/"..v)

			SF:Msg("Loading Building: "..baseName, 1)
			scripted_ents.Register(ENT, "building_"..baseName)
			
			ENT.typeID = baseName
			self.stored[baseName] = table.Merge(scripted_ents.Get("base_building"), ENT)

			ENT = nil
		end

		
	end
	SF:Msg("###############################################")
	SF:Call("InitPostBuildings")
end

function SF.Buildings:GetBuildings()
	return self.stored
end

function SF.Buildings:Get(id)
	return self.stored[id]
end

SF.Buildings.reqMeta = {}
SF.Buildings.reqMeta.__index = SF.Buildings.reqMeta
AccessorFunc(SF.Buildings.reqMeta, "requiresTerritory", "RequiresTerritory", FORCE_BOOL)

function SF.Buildings.reqMeta:Init()
	self.building = false
	self.resources = {}
	self.functions = {}
	self.vFunctions = {}
	self.gold = 0
	self:SetRequiresTerritory(true)
end

function SF.Buildings.reqMeta:AttachBuilding(ent)
	//if (!IsValid(ent)) then error("AttachBuilding Entity is '"..type(ent).."' Expected Entity") end
	self.building = ent
end

function SF.Buildings.reqMeta:AddResource(name, amount)
	self.resources[name] = amount
end

function SF.Buildings.reqMeta:AddGold(amount)
	self.gold = amount
end

function SF.Buildings.reqMeta:AddFunction(func)
	table.insert(self.functions, func)
end

function SF.Buildings.reqMeta:AddViewFunction(func)
	table.insert(self.vFunctions, func)
end

function SF.Buildings.reqMeta:CanView()
	if (table.Count(self.vFunctions) <= 0) then return true end

	for _, func in next, self.vFunctions do
		local pass = func(SF.Client:GetFaction())
		if (pass == false) then
			return false
		end
	end

	return true
end

function SF.Buildings.reqMeta:Check(faction, trace, ghost)

	if (self:GetRequiresTerritory()) then
		if (!faction:PointInInfluence(trace.HitPos)) then
			return false, "Position not in your influece"
		end
	end

	for _, func in next, self.functions do
		local pass, msg = func(faction, trace, ghost)
		if (pass == false) then
			return false, msg
		end
	end

	for res, amnt in next, self.resources do
		if (!faction:HasResource(res, amnt)) then
			return false, "Not enough "..res
		end
	end

	if (!faction:HasGold(self.gold)) then
		return false, "Not enough Gold"
	end

	return true
end

function SF.Buildings:NewRequirements()
	local o = setmetatable({}, SF.Buildings.reqMeta)
	o:Init()
	return o
end

function SF.Buildings:InitPostEntity()
	self:LoadBuildings()
end

SF:RegisterClass("shBuildings", SF.Buildings)
