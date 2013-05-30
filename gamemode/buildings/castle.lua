
function ENT:GetOviasModel()
	return "mmodels/roller"
end

function ENT:GetBuildTime()
	return 15
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