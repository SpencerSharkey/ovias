--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
]]--

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetMoveType(MOVETYPE_NOCLIP)
	self:SetSolid(SOLID_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)

	self:DrawShadow(false)
end

function ENT:GetEntityDriveMode(player)
	return "drive_ovias"
end