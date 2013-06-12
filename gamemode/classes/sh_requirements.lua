--[[
    Ovias
    Copyright © Slidefuse LLC - 2012
--]]


SF.Requirements = {}

SF.Requirements.reqMeta = {}
SF.Requirements.reqMeta.__index = SF.Requirements.reqMeta
AccessorFunc(SF.Requirements.reqMeta, "requiresTerritory", "RequiresTerritory", FORCE_BOOL)

function SF.Requirements.reqMeta:Init()
    self.building = false
	self.resources = {}
	self.functions = {}
	self.vFunctions = {}
	self.gold = 0
	self:SetRequiresTerritory(true)
end

function SF.Requirements.reqMeta:AttachBuilding(ent)
	//if (!IsValid(ent)) then error("AttachBuilding Entity is '"..type(ent).."' Expected Entity") end
	self.building = ent
end

function SF.Requirements.reqMeta:AddResource(name, amount)
	self.resources[name] = amount
end

function SF.Requirements.reqMeta:AddGold(amount)
	self.gold = amount
end

function SF.Requirements.reqMeta:AddFunction(func)
	table.insert(self.functions, func)
end

function SF.Requirements.reqMeta:AddViewFunction(func)
	table.insert(self.vFunctions, func)
end

function SF.Requirements.reqMeta:CanView()
	if (table.Count(self.vFunctions) <= 0) then return true end

	for _, func in next, self.vFunctions do
		local pass = func(SF.Client:GetFaction())
		if (pass == false) then
			return false
		end
	end

	return true
end

function SF.Requirements.reqMeta:Check(faction, trace, ghost)

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

function SF.Requirements:New()
	local o = setmetatable({}, self.reqMeta)
	o:Init()
	return o
end

SF:RegisterClass("shRequirements", SF.Requirements)