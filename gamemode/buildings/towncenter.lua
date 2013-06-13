ENT.BuildTime = 10
ENT.BuildTicks = 30

ENT.OviasName = "Manor Hall"
ENT.OviasModel = "models/mrgiggles/sassilization/TownCenter.mdl"
ENT.OviasInfo = {
		["category"] = "Kingdom",
		["desc"] = "The control point of a manor in your kingdom."
	}

--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

-- A function to return a requirements object
function ENT:SetupRequirements(req)
	req:AttachBuilding(self)

	req:SetRequiresTerritory(true)
	//req:AddResource("wood", 10)
	//req:AddResource("iron", 8)
	//req:AddGold(20)

	req:AddFunction(function(faction, trace, ghost)
		for _, manor in next, faction:GetBuildingsOfType("towncenter") do
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

