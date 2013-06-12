--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel(self:GetOviasModel())
	self:SetNoDraw(true)
	
	self:SharedInit()
end


function ENT:BehaveAct()
end


function ENT:RunBehaviour()
	while ( true ) do
		//whatever
		coroutine.yield()
	end
end