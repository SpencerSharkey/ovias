--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]


function SF.Units:PreDrawOpaqueRenderables()
	print("srsly")
	for id, ent in next, self:FindUnitEnts() do
		print("id: ", id, ent)
		local UnitCircle = Material("sassilization/circle")
		render.SetMaterial(UnitCircle)
		render.DrawQuadEasy(ent:GetGroundPos() + vector_up * 0.1, ent:GetGroundNormal(), ent:GetSize(), ent:GetSize(), ent:GetFaction():GetColor())
		ent:DrawModel()
	end
end

SF:RegisterClass("clUnits", SF.Units)
