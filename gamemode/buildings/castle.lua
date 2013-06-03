
function ENT:GetOviasModel()
	return "mmodels/roller.mdl"
end

function ENT:GetBuildTime()
	return 30
end

-- A function to return a requirements object
function ENT:SetupRequirements(req)
	req:AttachBuilding(self)

	req:AddFunction(function(faction, trace, ghost)
		if (table.Count(faction:GetBuildings()) <= 0) then
			return false, "Already have a castle"
		end
	end)
end

--Towncenters have territories!
function ENT:PostBuild()
	self.territory = SF.Territory:Create(self:GetFaction(), self:GetPos(), 240)
end

function ENT:PostDestruction()
	self.territory:Remove()
end

function ENT:PreBuild()

end