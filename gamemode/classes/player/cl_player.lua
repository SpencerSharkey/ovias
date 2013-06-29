--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]


function SF.Player:Think()
	SF.Client = LocalPlayer()
end

function SF.PlayerMeta:GetEyeTrace()

	local vAngles = self.ov_ViewAngles
	local vOrigin = self.ov_ViewOrigin

	local trace = {}
	local mposx, mposy = gui.MouseX(), gui.MouseY()
	local sw, sh = ScrW(), ScrH()

	local newFov = SF.Util:FovFix(90)
	trace.start = vOrigin
	trace.endpos = trace.start + SF.Util:ScreenToAimVector(mposx, mposy, sw, sh, vAngles, math.rad(newFov))*32766
	trace.filter = self.ovCamera

	return util.TraceLine(trace)
end

function SF.PlayerMeta:HasInitialized()
	return (self:GetFaction() == nil)
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
