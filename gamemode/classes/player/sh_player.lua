--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

SF.Player = {}
SF.PlayerMeta = FindMetaTable("Player")

function SF.PlayerMeta:SetFaction(faction)
	self.ovFaction = faction
	
	if (SERVER) then
		netstream.Start(self, "ovPlayerFaction", faction:GetNetKey())
	end
end

function SF.PlayerMeta:GetFaction()
	return self.ovFaction or false
end