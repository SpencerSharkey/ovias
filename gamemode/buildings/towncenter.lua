
function ENT:GetOviasModel()
	return "models/mrgiggles/sassilization/TownCenter.mdl"
end

function ENT:GetBuildTime()
	return 15
end

--Towncenters have territories!
function ENT:PostBuild()
	self.territory = SF.Territory:Create(self:GetFaction(), self:GetPos(), 128) --We'll update the radius later
	print("Building Territory")
	self.territory:Calculate()
end

function ENT:PostDestruction()
	self.territory:Remove()
end

function ENT:PreBuild()

end