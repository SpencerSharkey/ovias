--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]


function SF.Gamemode:Initialize()
	self.CurrentState = self.STATE_NONE
end

function SF.Gamemode:PlayerInit()
	self:RequestState()
	netstream.Start("playerReady", true)
end

function SF.Gamemode:SetState(state)
	local oldState = self.CurrentState or -1

	self.CurrentState = state
	SF:Msg("Changing Gamemode State: "..self:GetStateName(oldState).."->"..self:GetStateName(self.CurrentState), 1)

	if (oldState != self.CurrentState) then
		SF:Call("OviasGameStateChanged", oldState, self.CurrentState)
	end

end

function SF.Gamemode:RequestState()
	netstream.Start("requestGameState", true)
end

function SF.Gamemode:RequestCountdown()
	netstream.Start("requestCountdown", true)
end

netstream.Hook("receiveCountdown", function(data)
	if (data != false) then
		SF.Gamemode.countdownEnabled = true
		SF.Gamemode.countdownStart = CurTime()
		SF.Gamemode.countdownEnd = CurTime() + data
	end
end)

netstream.Hook("updateGameState", function(data)
	SF.Gamemode:SetState(data)
end)

function SF.Gamemode:Think()

	if (!self.playerInit and IsValid(LocalPlayer())) then
		if (!self.playerInit) then
			SF:Call("PlayerInit")
			self.playerInit = true
		end
	end

	if (self.countdownEnabled and CurTime() <= SF.Gamemode.countdownEnd) then
		self.countdownTime = self.countdownEnd - CurTime()
		if (self.countdownTime <= 0) then
			self.countdownEnabled = false
		end
	end
end

function SF.Gamemode:GetCountdown()
	return math.ceil(self.countdownTime or 0)
end

function SF.Gamemode:OviasGameStateChanged(old, new)
	if (new == self.STATE_WAITING) then
		self:RequestCountdown()
	end
end

SF:RegisterClass("clGamemode", SF.Gamemode)