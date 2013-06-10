
--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
]]--

SF.Entity = {}

if (CLIENT) then
	function SF.Entity:ClientsideInit(ent)
		netstream.Start("ovClientsideInit", ent:EntIndex())
	end
end

if (SERVER) then
	netstream.Hook("ovClientsideInit", function(ply, data)
		Entity(data):PostClientsideInit()
	end)
end

SF:RegisterClass("shEntity", SF.Entity)
