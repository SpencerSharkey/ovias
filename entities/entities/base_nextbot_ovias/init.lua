--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
]]--

function ENT:Initialize()
	self:SetModel(self.data.model)

	local r = self.data.size/2
	self:PhysicsInitSphere(r)
	self:SetCollisionBounds(Vector(-r, -r, -r), Vector(r, r, r))
end


function ENT:BehaveAct()
end


function ENT:RunBehaviour()
	while ( true ) do
		//whatever
		coroutine.yield()
	end
end