--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
]]--

SF.Camera = {}

function SF.Camera:PlayerInitialSpawn(player)
	self.ovCamera = ents.Create("ov_camera")
	self.ovCamera:SetPos(Vector(0, 0, 0))
	self.ovCamera:Spawn()

	timer.Simple(0.5, function() drive.PlayerStartDriving(player, self.ovCamera, "drive_ovias") end)
end


SF:RegisterClass("svCamera", SF.Camera)