--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
]]--

DEFINE_BASECLASS( "drive_base" );

SF:Msg("** Registering drive_ovias **", 3)

local overrideCalcOrigin = Vector(0)

local A = 90
local sinA = math.sin(math.rad(90))
local cosA = math.cos(math.rad(90))

drive.Register( "drive_ovias", 
{
	// Clientside CalcView
	CalcView =  function( self, view )
		if (!self.Player.ov_ViewAngles or !self.Player.ov_ViewOrigin) then
			self.Player.ov_ViewAngles = view.angles
			self.Player.ov_ViewOrigin = view.origin
		end
		// the math for calculating the angle is here: http://4stor.com/images/AfPu.png

		view.angles.pitch = 45

		// Make a copy of the angles so we can find the distance we want
		local oang = Angle(view.angles.p, view.angles.y, view.angles.r)
		oang.pitch = 0

		// Get the distance from the ground
		local tr = util.TraceLine({
			startpos = view.origin,
			filter = self.Entity,
			endpos = view.origin - Vector(0, 0, 2000)
		})


		local groundDist = view.origin.z - tr.HitPos.z // Distance from the ground ('c' in the triangle drawing)
		
		local b = self.Player.ov_ZoomLevel
	
		view.origin = view.origin - oang:Forward()*groundDist // Set the distance for the camera to be away from. Half the height!

		// Trace in all directions so we dont't hit walls.
		local tr = util.TraceLine({
			startpos = view.origin,
			filter = self.Entity,
			endpos = view.origin + oang:Forward()*-5 + oang:Right()*5
		})
				
		if (tr.Fraction < 1) then
			view.origin = tr.HitPos + tr.HitNormal*5
		end

		// Set some global player variables, so we can use them in other areas of the gamemode (getting the mouse->world pos)
		self.Player.ov_ViewAngles = view.angles
		self.Player.ov_ViewOrigin = view.origin

	end,

	// Before Movement, setting shit up here.
	StartMove =  function( self, mv, cmd )
		if (!self.Player.ovCamera) then
			self.Player.ovCamera = self.Entity
		end
		local ma = mv:GetMoveAngles()
		ma.pitch = 50
		mv:SetMoveAngles(ma)

		if (!self.Player.ov_ZoomLevel) then
			self.Player.ov_ZoomLevel = 48
		end
		
		if (self.Player.ov_ZoomDelta != nil) then
			self.Player.ov_ZoomLevel = math.Clamp(self.Player.ov_ZoomLevel + self.Player.ov_ZoomDelta, 48, 220)
			self.Player.ov_ZoomDelta = nil
			netstream.Start("ovZoomLevel", {
				zoom = self.Player.ov_ZoomLevel,
				ScrW = ScrW(),
				ScrH = ScrH()
			})
		end

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
		
		//pos.z = self.Player.ov_ZoomLevel

		if (tr.HitWorld) then
			pos.z = math.Round(Lerp(0.05, pos.z, tr.HitPos.z + self.Player.ov_ZoomLevel))
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

SF.Camera = {}