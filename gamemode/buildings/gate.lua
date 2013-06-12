ENT.BuildTime = 600
ENT.BuildTicks = 6

ENT.OviasName = "Portcullis"
ENT.OviasModel = "models/mrgiggles/sassilization/gate.mdl"
ENT.OviasInfo = {
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


	--Requires moneh
	//req:AddGold(500)
	
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

-- Called after the building has been demolished
function ENT:PostDestruction()

end
