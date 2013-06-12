ENT.BuildTime = 400
ENT.BuildTicks = 4

ENT.OviasName = "Home 2"
ENT.OviasModel = "models/mrgiggles/sassilization/house02.mdl"
ENT.OviasInfo = {
	["category"] = "Population",
	["desc"] = "Cater to your populace!"
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
