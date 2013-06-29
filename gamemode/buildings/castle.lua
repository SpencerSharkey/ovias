--[[
    Ovias
    Copyright © Slidefuse LLC - 2012
--]]

ENT.BuildTicks = 3

ENT.OviasName = "Kingdom Castle"
ENT.OviasModel = "models/roller.mdl"
ENT.OviasInfo = {
		["category"] = "Kingdom",
		["desc"] = "The central hub of your your territory."
	}

-- A function to return a requirements object
function ENT:SetupRequirements(req)

	req:SetRequiresTerritory(false)

	req:AddFunction(function(faction, trace, ghost)
		if (table.Count(faction:GetBuildingsOfType("castle")) > 0) then
			return false, "Already have a castle"
		end
	end)

	req:AddViewFunction(function(faction)
		if (table.Count(faction:GetBuildingsOfType("castle")) > 0) then
			return false
		end
	end)
end

-- Called before a building starts being built
function ENT:PreBuild()
end

-- Called per-tick during the build stage
function ENT:Build()
    --this is so we don't need builder units to build the castle - it jsut goes up automatically
    if (!self:GetBuilt()) then
        if (!self.nextBuildTick) then
            self.nextBuildTick = CurTime()
        end
        if (CurTime() >= self.nextBuildTick) then

            self:ProgressBuild()
            self.nextBuildTick = CurTime() + 0.75
        end
    end
end

-- Called after the building has been completed
function ENT:PostBuild()
	if (SERVER) then
		self.territory = SF.Territory:Create(self:GetFaction(), self:GetPos(), 240)
		self.territory:Calculate()

		for i=1,4 do
			self:SpawnUnit("builder")
		end
	end
end

-- Called before the building is demolished
function ENT:PreDestruction()
end

-- Called after the building has been demolished
function ENT:PostDestruction()
	self.territory:Remove()
end
