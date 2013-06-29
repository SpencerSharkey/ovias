--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
--]]


netstream.Hook("ovZoomLevel", function(ply, data)
	ply.ov_ZoomLevel = data.zoom
	ply.ScrW = data.ScrW
	ply.ScrH = data.ScrH
end)

netstream.Hook("ovCamDetails", function(ply, data) --unused
	ply.ov_ViewOrigin = data.origin
	ply.ov_ViewAngles = data.angles
end)

function SF.PlayerMeta:GetPos()
	return self.ov_ViewOrigin
end

function SF.PlayerMeta:ViewAngles()
	local ang = self:EyeAngles()
	ang.pitch = 45
	return ang
end

function SF.Camera:PlayerThink(ply)
	local vAngles = ply:EyeAngles()
	local vCamPos = ply.ovCamera:GetPos()
	local vOrigin = Vector()

	vAngles.pitch = 45

	// Make a copy of the angles so we can find the distance we want
	local oang = Angle(vAngles.p, vAngles.y, vAngles.r)
	oang.pitch = 0

	// Get the distance from the ground
	local tr = util.TraceLine({
		startpos = vCamPos,
		filter = ply.ovCamera,
		endpos = vCamPos - Vector(0, 0, 32766)
	})

	local groundDist = vCamPos.z - tr.HitPos.z // Distance from the ground ('c' in the triangle drawing)
	local b = ply.ov_ZoomLevel
	vOrigin = vCamPos - oang:Forward()*groundDist // Set the distance for the camera to be away from. Half the height!

	// Trace in all directions so we dont't hit walls.
	local tr = util.TraceLine({
		startpos = vOrigin,
		filter = self.Entity,
		endpos = vOrigin + oang:Forward()*-5 + oang:Right()*5
	})
			
	if (tr.Fraction < 1) then
		vOrigin = tr.HitPos + tr.HitNormal*5
	end

	ply.ov_ViewOrigin = vOrigin
	ply.ov_ViewAngles = vAngles
end

function SF.Camera:SetupMove(ply, movedata)
	local cmd = ply:GetCurrentCommand()
	ply.ov_MouseX = cmd:GetMouseX()
	ply.ov_MouseY = cmd:GetMouseY()
end


SF:RegisterClass("svCamera", SF.Camera)