--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

function ENT:GetOviasModel()
	return "models/mrgiggles/sassilization/swordsman.mdl"
end

function ENT:BehaveAct()
end

function ENT:BehaveUpdate(interval)
	if (!self.BehaveThread) then return end

	local ok, message = coroutine.resume(self.BehaveThread)
	if (ok == false) then
		self.BehaveThread = nil
		Msg(self, "OviasBotError: \n\t"..message.."\n")
	end
end

function ENT:RunBehaviour()
	self.loco:SetDesiredSpeed(40)
	self.loco:SetJumpHeight(50)
	self.loco:SetStepHeight(15)

	while ( true ) do
		self.buildingEnt = nil
		for k, v in pairs(self.faction:GetAllBuildings()) do
			if (!v:GetBuilt()) then
				self:MoveToPos(v:FindUnitPosition(self), {lookahead = 5, repath = 0.5, tolerance = 20})
				self.buildingEnt = v
				break;
			end
		end
		if (!self.buildingEnt) then
			self:MoveToPos(self.faction:GetCastle():FindUnitPosition(self), {lookahead = 5, repath = 0.5, tolerance = 20})
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
			self.nextBuildTick = CurTime() + math.Rand(0.75, 1.25)
		end
	end
end

function ENT:SetTarget(pos)
	self.target = pos;
end