--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

local UnitCircle = Material("sassilization/circle")

function SF.Units:Think()
	for id, ent in next, self:FindUnitEnts() do
		if (!ent.mergedFunctions) then

			local files, folders = file.Find("ovias/*", "LUA", "namedesc")
			PrintTable(files)
			PrintTable(folders)

			print("merging entity with real funcs manually...")
			ENT = ent
			include("ovias/entities/entities/base_nextbot_ovias/shared.lua")
			ent = ENT

			ent.mergedFunctions = true
		end
	end
end

function SF.Units:PostDrawOpaqueRenderables()
	for id, ent in next, self:FindUnitEnts() do

		render.SetMaterial(UnitCircle)
		render.DrawQuadEasy(ent:GetGroundPos() + Vector(0, 0, 1) * 0.1, ent:GetGroundNormal(), ent:GetSize(), ent:GetSize(), ent:GetFaction():GetColor())

	end
end

netstream.Hook("ovUnitFaction", function(data)
	local faction = SF.Faction:GetByNetKey(data.fid)
	print("Setting unitID to faction ent")
	Entity(data.ent):SetFaction(faction)
end)

SF:RegisterClass("clUnits", SF.Units)
