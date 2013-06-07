--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
]]--


function SF.PlayerMeta:CreateTown(position, angles)
	return self:CreateBuilding("towncenter", {pos = position, ang = angles})
end

function SF.PlayerMeta:CreateBuilding(type, data)
	--Check requirements

	local ent = ents.Create("building_"..type)
	ent:SetFaction(self:GetFaction())
	ent:SetPos(data.pos)
	ent:SetAngles(data.ang)
	ent:Spawn()


end

concommand.Add("spawnTown", function(ply, cmd, args)
	print("making town!")
	local tr = ply:GetEyeTraceNoCursor()
	ply:CreateTown(tr.HitPos, Angle(0, 0, 0))
end)

function SF.Player:OnFactionCreated(faction)
	local key = faction:GetNetKey()
	netstream.Start(player.GetAll(), "ovFactionCreated", faction:GetNetKey())
end

SF:RegisterClass("svPlayer", SF.Player)
