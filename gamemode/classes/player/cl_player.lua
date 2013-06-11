--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]


function SF.Player:Think()
	SF.Client = LocalPlayer()
end

netstream.Hook("ovPlayerFaction", function(data)
	local faction = SF.Faction:GetByNetKey(data)
	SF.Client:SetFaction(faction)
	SF:Call("PostSetFaction")
end)

netstream.Hook("ovFactionCreated", function(data)
	SF.Faction:Create(data) --Add it to our buffer! :)
end)

SF:RegisterClass("clPlayer", SF.Player)
