--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self:EnableCustomCollisions(true)
	self:GetPhysicsObject():EnableMotion(false)
end