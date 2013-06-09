-- A function to grab the name
function ENT:GetOviasName()
	return "Manor Hall"
end

-- A function to get a table of general info
function ENT:GetInfo()
	return {
		["category"] = "Kingdom",
		["desc"] = "The control point of a manor in your kingdom."
	}
end

-- A function to return a requirements object
function ENT:SetupRequirements(req)
	req:AttachBuilding(self)

	req:SetRequiresTerritory(true)
	//req:AddResource("wood", 10)
	//req:AddResource("iron", 8)
	//req:AddGold(20)

	req:AddFunction(function(faction, trace, ghost)
		for _, manor in pairs(faction:GetBuildingsOfType("towncenter")) do
			if (trace.HitPos:Distance(manor:GetPos()) <= 64) then
				return false, "Too close to existing Manor"
			end
		end
		return true
	end)

	req:AddViewFunction(function(faction)
		if (table.Count(faction:GetBuildingsOfType("castle")) > 0) then
			return true
		end
		return false
	end)
end

-- A function to grab the model the building uses
function ENT:GetOviasModel()
	return "models/mrgiggles/sassilization/TownCenter.mdl"
end

-- A function to grab the time it takes to build the building in seconds
function ENT:GetBuildTime()
	return 3
end

-- Called before a building starts being built
function ENT:PreBuild()
end

-- Called per-tick during the build stage
function ENT:Build()
end

-- Called after the building has been completed
function ENT:PostBuild()
	--We create the territory manually
	print(self:GetFaction():GetName())
	self.territory = SF.Territory:Create(self:GetFaction(), self:GetPos(), 128) --We'll update the radius later
	self.territory:Calculate()
end

-- Called before the building is demolished
function ENT:PreDestruction()
end

-- Called after the building has been demolished
function ENT:PostDestruction()
	self.territory:Remove()
end

