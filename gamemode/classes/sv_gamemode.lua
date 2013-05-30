--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
]]--


function SF.Gamemode:Initialize()
	self.CurrentState = self.STATE_WAITING
end

function SF.Gamemode:SetState(state)
	local oldState = self.CurrentState
	self.CurrentState = state
	SF:Msg("Changing Gamemode State: "..self:GetStateName(oldState).."->"..self:GetStateName(self.CurrentState))
	netstream.Start(player.GetAll(), "updateGameState", self.CurrentState)
	SF:Call("OviasGameStateChanged", oldState, self.CurrentState)
end

function SF.Gamemode:Think()
	self.playerCount = 0
	for _, ply in pairs(player.GetAll()) do
		if (ply:IsConnected()) then
			self.playerCount = self.playerCount + 1
		end
	end

	if (self.playerCount > 1 and self:GetState() == self.STATE_WAITING and !self.startPlayTime) then
		self.startPlayTime = CurTime() + 10
		self:SendCountdown()
		SF:Msg("Players ready. Starting countdown.")

	end

	if (self:GetState() == self.STATE_WAITING and self.startPlayTime and CurTime() >= self.startPlayTime) then
		self:SetState(self.STATE_PLAYING)
		self.startPlayTime = nil
	end
end

function SF.Gamemode:SendCountdown(ply)
	if (!ply) then
		ply = player.GetAll()
	end

	local ret = false
	if (SF.Gamemode.startPlayTime) then
		ret = SF.Gamemode.startPlayTime - CurTime()
	end
	netstream.Start(ply, "receiveCountdown", ret)
end

netstream.Hook("requestGameState", function(ply, data)
	netstream.Start(ply, "updateGameState", SF.Gamemode.CurrentState)
	SF:Msg("Sending player "..ply:Nick().." Game State")
end)

netstream.Hook("requestCountdown", function(ply, data)
	SF.Gamemode:SendCountdown(ply)
end)

SF:RegisterClass("svGamemode", SF.Gamemode)