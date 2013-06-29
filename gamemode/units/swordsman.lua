--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

function ENT:Initialize()
	self:SetModel( "models/mrgiggles/sassilization/swordsman.mdl" );
end

function ENT:BehaveAct()
end


function ENT:RunBehaviour()
	while ( true ) do
		-- walk somewhere random
		self:SetSequence( self:LookupSequence("run") )                            -- walk anims
		self.loco:SetDesiredSpeed( 25 )                        -- walk speeds
		self:MoveToPos( self.target ) -- walk to a random place within about 200 units (yielding)
		self:StartActivity( self:LookupSequence("idle") )        -- revert to idle activity
		coroutine.wait(2)
		coroutine.yield()
	end
end

function ENT:SetTarget(pos)
	self.target = pos;
end