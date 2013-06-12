ENT.BuildTime = 10
ENT.BuildTicks = 10

ENT.OviasName = "NIGGER"

-- A function to get a table of general info
function ENT:GetInfo()
	return {
		["hideSpawn"] = true,
		["category"] = "Dev",
		["desc"] = ""
	}
end

-- A function to return a requirements object
function ENT:SetupRequirements(req)
	req:AttachBuilding(self)

	--Requires to be inside a territory?
	req:SetRequiresTerritory(false)
	
	--Add an obtainable resource
	req:AddResource("wood", 10)

	--Requires moneh
	req:AddGold(20)
	
	--Example of a function that runs during requirements
	req:AddFunction(function(faction, trace, ghost)
		return true
	end)
end

-- A function to grab the model the building uses
function ENT:GetOviasModel()
	return ""
end

-- Called before a building starts being built
function ENT:PreBuild()
end

-- Called per-tick during the build stage
function ENT:Build()
end

-- Called after the building has been completed
function ENT:PostBuild()
end

-- Called before the building is demolished
function ENT:PreDestruction()
end

-- Called after the building has been demolished
function ENT:PostDestruction()
end

