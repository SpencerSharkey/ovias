--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

function SF.PlayerMeta:CancelBuildMode()
	SF.BuildMode:Cancel(self)
end

function SF.PlayerMeta:SpawnBuilding(type)
	self:CreateBuilding(type, self:GetEyeTrace())
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

SF:RegisterClass("svPlayer", SF.Player)
