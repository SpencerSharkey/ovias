ENT.BuildTime = 10
ENT.BuildTicks = 10

ENT.OviasName = "Wall"
ENT.OviasModel = "models/mrgiggles/sassilization/wall.mdl"
ENT.OviasRuinModel = "models/mrgiggles/sassilization/wall_destroyed01.mdl"
ENT.OviasInfo =  {
		["category"] = "Defence",
		["desc"] = "To protect your kingdom!"
	}


-- A function to return a requirements object
function ENT:SetupRequirements(req)
	req:AttachBuilding(self)

	--Requires to be inside a territory?
	req:SetRequiresTerritory(true)
	
	--Add an obtainable resource
	//req:AddResource("wood", 10)
	//req:AddResource("stone", 10)

	--Requires moneh
	//req:AddGold(350)
	
	--Example of a function that runs during requirements
	req:AddFunction(function(faction, trace, ghost)
		return true
	end)
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