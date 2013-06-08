--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
]]--


function SF.PlayerMeta:CreateTown(trace)
	
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

netstream.Hook("ovSpawnBuilding", function(ply, data)
	local buildtype = data["building"]
	local trace = ply:GetEyeTraceNoCursor()
	local building = ply:CreateBuilding(buildtype, trace)
	--we try.
end)

function SF.Player:OnFactionCreated(faction)
	local key = faction:GetNetKey()
	netstream.Start(player.GetAll(), "ovFactionCreated", faction:GetNetKey())
end

SF:RegisterClass("svPlayer", SF.Player)
