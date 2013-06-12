--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]
include("shared.lua")

function ENT:Initialize()
	self:SharedInit()
end

local UnitCircle = Material("sassilization/circle")

function ENT:Draw()
	render.SetMaterial(UnitCircle)
	render.DrawQuadEasy(self:GetGroundPos() + vector_up * 0.1, self:GetGroundNormal(), self:GetSize(), self:GetSize(), self:GetFaction():GetColor())

	//self:DrawModel()
end

netstream.Hook("ovUnitFaction", function(data)
	data.ent:SetFaction(SF.Faction:GetByNetKey(data.fid))
end)