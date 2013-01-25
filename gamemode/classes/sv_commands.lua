
concommand.Add("spawnsies", function(ply, cmd, args)
	local unit = Unit:Spawn("unit_base");
	unit:SetPos(ply:GetEyeTrace().HitPos + Vector(0, 0, 5))
end)