--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

function SF.PlayerMeta:GetEyeTrace()
	local vAngles = self.ov_ViewAngles
	local vOrigin = self.ov_ViewOrigin

	local trace = {}

	local newFov = SF.Util:FovFix(90, self.ScrW/self.ScrH)
	trace.start = vOrigin
	trace.endpos = trace.start + SF.Util:ScreenToAimVector(self.ov_MouseX, self.ov_MouseY, self.ScrW, self.ScrH, vAngles, math.rad(newFov))*32766
	trace.filter = self.ovCamera

	return util.TraceLine(trace)
end

function SF.PlayerMeta:CancelBuildMode()
	SF.BuildMode:Cancel(self)
end

function SF.PlayerMeta:SpawnBuilding(type)
	self:CreateBuilding(type, self:GetEyeTrace())
end

function SF.PlayerMeta:HasInitialized()
	if (!self.playerInit) then return false end -- Check to see if the client says we're alive
	if (!IsValid(self.ovCamera)) then return false end -- Check to see if camera is here
	return self.playerInit
end

function SF.PlayerMeta:CreateBuilding(type, trace)

	local ent = ents.Create("building_"..type)

	local success, msg = ent:GetRequirements():Check(self:GetFaction(), trace)
	if (!success) then
		ent:Remove()
		self:ChatPrint("Error! "..msg)
	else
		ent:SetFaction(self:GetFaction())

		ent:SetOwner(self)
		ent:SetPos(trace.HitPos)
		ent:SetAngles(self.buildAngles or Angle(0, 0, 0))
		ent:Spawn()
	end

end


function SF.PlayerMeta:SpawnUnit(type)
	self:CreateUnit(type, self:GetEyeTrace())
end

function SF.PlayerMeta:CreateUnit(type, trace)

	local success, msg = ent:GetRequirements():Check(self:GetFaction(), trace)

	if (!success) then
		self:ChatPrint("Error! "..msg)
	else
		local ent = SF.Units:NewUnit(type, self:GetFaction(), trace.HitPos, self.buildAngles or Angle(0, 0, 0))
	end
end

netstream.Hook("ovSpawnBuilding", function(ply, data)
	ply:CreateBuilding(data.building, ply:GetEyeTraceNoCursor())
end)

function SF.Player:OnFactionCreated(faction)
	netstream.Start(player.GetAll(), "ovFactionCreated", faction:GetNetKey())
end

function SF.Player:PlayerInit(ply)
	--Update le buildings & units
	for k, v in next, ents.FindByClass("building_*") do
		if (v.NewPlayer) then
			v:NewPlayer(ply)
		end
	end

	self.ovCamera = ents.Create("ov_camera")
	self.ovCamera:SetPos(Vector(0, 0, 0))
	self.ovCamera:Spawn()

	timer.Simple(0.5, function() drive.PlayerStartDriving(ply, self.ovCamera, "drive_ovias") end)
end

SF:RegisterClass("svPlayer", SF.Player)
