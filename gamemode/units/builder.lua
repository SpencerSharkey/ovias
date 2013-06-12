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
	while ( true ) do
		-- walk somewhere random
	
		self:StartActivity( self:LookupSequence("idle") )        -- revert to idle activity
		coroutine.wait(2)
		coroutine.yield()
	end
end

function ENT:SetTarget(pos)
	self.target = pos;
end