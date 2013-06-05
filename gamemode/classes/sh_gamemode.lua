--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
]]--

SF.Gamemode = {}

SF.Gamemode.STATE_NONE = -1;
SF.Gamemode.STATE_WAITING = 0;
SF.Gamemode.STATE_PLAYING = 1;
SF.Gamemode.STATE_ENDGAME = 2;

SF.Gamemode.StateNames = {
	[SF.Gamemode.STATE_NONE] = "None",
	[SF.Gamemode.STATE_WAITING] = "Waiting",
	[SF.Gamemode.STATE_PLAYING] = "Playing",
	[SF.Gamemode.STATE_ENDGAME] = "End Game"
}

function SF.Gamemode:GetState()
	return self.CurrentState
end

function SF.Gamemode:GetStateName(state)
	return self.StateNames[state] or state
end

//Registered in scope-specific files