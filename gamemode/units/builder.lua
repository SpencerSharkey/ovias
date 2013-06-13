--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

function ENT:GetOviasModel()
	return "models/mrgiggles/sassilization/swordsman.mdl"
end

function ENT:BehaveAct()
end

function ENT:RunBehaviour()
	self.loco:SetDesiredSpeed(20)
	self.loco:SetJumpHeight(3)
	self.loco:SetStepHeight(2)

	while ( true ) do
		self.buildingEnt = nil
		for k, v in pairs(self.faction:GetAllBuildings()) do
			if (!v:GetBuilt()) then
				self:MoveToPos(v:GetUnitPos(self), {repath = 2, tolerance = 20})
				self.buildingEnt = v
				break;
			end
		end
		if (!self.buildingEnt) then
			self:MoveToPos(self.faction:GetCastle():GetUnitPos(self), {repath = 2, tolerance = 20})
		end
		
		self:StartActivity(self:LookupSequence("idle"))
		coroutine.yield()
	end
end

function ENT:Think()
	if (self.buildingEnt and !self.buildingEnt:GetBuilt() and self:GetPos():Distance(self.buildingEnt:GetPos()) <= 60) then
		if (!self.nextBuildTick) then
			self.nextBuildTick = CurTime() + math.Rand(0, 1)
		end
		if (CurTime() >= self.nextBuildTick) then
			self.buildingEnt:ProgressBuild()
			print("Progressssing")
			self.nextBuildTick = CurTime() + math.Rand(0.75, 1.25)
		end
	end
end

function ENT:SetTarget(pos)
	self.target = pos;
end