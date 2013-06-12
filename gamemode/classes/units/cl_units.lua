--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

local UnitCircle = Material("sassilization/circle")
function SF.Units:PostDrawOpaqueRenderables()
	//print("srsly")
	for id, ent in next, self:FindUnitEnts() do
		//print("id: ", id, ent)
		//render.SetMaterial(UnitCircle)
		//render.DrawQuadEasy(ent:GetGroundPos() + vector_up * 0.1, ent:GetGroundNormal(), ent:GetSize(), ent:GetSize(), ent:GetFaction():GetColor())
		//print(ent:GetGroundPos())
		//ent:DrawModel()
	end
end

SF:RegisterClass("clUnits", SF.Units)
