--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

surface.CreateFont( "pregameCountdown", {
	font = "Arial",
	size = 72,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = true
} )


SF.Pregame = {}

function SF.Pregame:HUDPaint()
	if (SF.Gamemode:GetState() == SF.Gamemode.STATE_WAITING and SF.Gamemode.countdownEnabled) then
		surface.SetDrawColor(Color(21, 21, 21))
		surface.DrawRect(0, 0, ScrW(), ScrH())

		draw.SimpleText(SF.Gamemode:GetCountdown(), "pregameCountdown", ScrW()/2, ScrH()/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	elseif (SF.Gamemode:GetState() == SF.Gamemode.STATE_WAITING) then
		surface.SetDrawColor(Color(21, 21, 21))
		surface.DrawRect(0, 0, ScrW(), ScrH())

		draw.SimpleText("Waiting for Players", "pregameCountdown", ScrW()/2, ScrH()/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

SF:RegisterClass("clPregame", SF.Pregame)