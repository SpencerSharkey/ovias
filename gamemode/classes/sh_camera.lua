--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
]]--

DEFINE_BASECLASS( "drive_base" );

SF:Msg("\t\t\t** Registering drive_ovias **\n")


drive.Register( "drive_ovias", 
{
	// Clientside CalcView
	CalcView =  function( self, view )
		view.angles.pitch = 40
		view.angles.roll = 0

		local oang = Angle(0, view.angles.yaw, 0)

		view.origin = view.origin - oang:Forward()*100

		self.Player.ov_ViewAngles = view.angles
		self.Player.ov_ViewOrigin = view.origin
	end,

	// Before Movement, setting shit up here.
	StartMove =  function( self, mv, cmd )

		local ma = mv:GetMoveAngles()
		ma.pitch = 40
		mv:SetMoveAngles(ma)

		local vOrigin = self.Entity:GetNetworkOrigin()

		mv:SetOrigin( vOrigin )
		mv:SetVelocity( self.Entity:GetAbsVelocity() )
	end,

	// Actual Movement
	Move = function( self, mv )

		local speed = 0.0095 * FrameTime()
		if ( mv:KeyDown( IN_SPEED ) ) then speed = 0.015 * FrameTime() end

		local ang = mv:GetMoveAngles()
		local pos = mv:GetOrigin()
		local vel = mv:GetVelocity()
		ang.pitch = 0


		local trace = {
			start = pos + Vector(0, 0, 5000),
			endpos = pos - Vector(0, 0, 5000),
			filter = self.Entity
		}
		local tr = util.TraceLine(trace)
		if (tr.HitWorld) then
			pos.z = Lerp(0.05, pos.z, tr.HitPos.z + 150)
		end

		vel = vel + ang:Forward() * mv:GetForwardSpeed() * speed
		vel = vel + ang:Right() * mv:GetSideSpeed() * speed
		vel = vel + ang:Up() * mv:GetUpSpeed() * speed

		// Air resistance
		vel = vel * 0.90

		pos = pos + vel

		mv:SetVelocity( vel )
		mv:SetOrigin( pos )

	end,

	// Updates our entity with the finished move info
	FinishMove =  function( self, mv )

		self.Entity:SetNetworkOrigin( mv:GetOrigin() )
		self.Entity:SetAbsVelocity( mv:GetVelocity() )
		self.Entity:SetAngles( mv:GetMoveAngles() )


		if ( SERVER && IsValid( self.Entity:GetPhysicsObject() ) ) then

			self.Entity:GetPhysicsObject():EnableMotion( true )
			self.Entity:GetPhysicsObject():SetPos( mv:GetOrigin() );
			self.Entity:GetPhysicsObject():Wake()
			self.Entity:GetPhysicsObject():EnableMotion( false )

		end

	end,

}, "drive_base" );