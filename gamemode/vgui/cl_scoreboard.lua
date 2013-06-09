--[[
	Ovias
	Copyright © Slidefuse LLC - 2013
]]--

surface.CreateFont( "ScoreboardNorm", {
	font = "Trebuchet24",
	size = ScreenScale(8),
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
	outline = false
} )

local PANEL = {}

function PANEL:Init( )

	self.PlayerHeight = 0

	self:SetSize(800, ScrH() - 100) -- Pretty much the parent size.
	self:Center() -- Pretty much the parent pos.

	self.PlayerList = vgui.Create("DPanelList", self)
	self.PlayerList:SetSize(self:GetWide(), self:GetTall())
	self.PlayerList:SetPos(10, self:GetTall() / 5)
	self.PlayerList:SetSpacing(5)
	self.PlayerList:EnableHorizontal( false )
	self.PlayerList:EnableVerticalScrollbar( true )

	for k, v in pairs(player.GetAll()) do
		self.PlayerCard = vgui.Create("ovias_playercard", self.PlayerList)
		self.PlayerCard:Choose(v)
		self.PlayerCard:SetPos(5, 20 + self.PlayerHeight)
		self.PlayerCard:SetSize(500, 20)

		self.PlayerHeight = self.PlayerHeight + 20
	end

	self.HostName = vgui.Create("DLabel", self)
	self.HostName:SetText( GetHostName() )
	self.HostName:SetFont("ScoreboardNorm")
	self.HostName:SetPos(15, 10)
	self.HostName:SizeToContents()

end

function PANEL:Paint( )

	surface.SetDrawColor(0, 0, 0, 255)
	surface.DrawRect(0, 0, self:GetWide(), self:GetTall())

	surface.SetDrawColor(SF.Client:GetFaction():GetColor())
	surface.DrawRect(5, 5, self:GetWide() - 10, self:GetTall() - 10)

	surface.SetDrawColor(50, 50, 50, 255)
	surface.DrawRect(10, 10, self:GetWide() - 20, self:GetTall() / 5)

	surface.SetDrawColor(40, 40, 40, 255)
	surface.DrawRect(10, self:GetTall() / 4.5, self:GetWide() - 20, self:GetTall() / 1.31)

end

function PANEL:Think( ) end

function PANEL:PermformLayout( w, h )

end

vgui.Register( "ovias_scoreboard", PANEL )

function GM:ScoreboardShow( )
	gui.EnableScreenClicker( true )

	oviasScoreboard = vgui.Create( "ovias_scoreboard" )
	oviasScoreboard:SetVisible( true )
end

function GM:ScoreboardHide( )
	gui.EnableScreenClicker( false )

	oviasScoreboard:SetVisible( false )
end









local PANEL = {}

function PANEL:Init()

	self.HostName = vgui.Create("DLabel", self	)
	self.HostName:SetFont( "ScoreboardNorm" )

end

function PANEL:Choose( ply )

	self.Player = ply
	self:UpdatePlayerData()

end

function PANEL:UpdatePlayerData()

	if !self.Player then return end
	if !self.Player:IsValid() then return end

	self.HostName:SetText( self.Player:Nick() )
	self.HostName:SizeToContents()
	
	self:InvalidateLayout()

end

function PANEL:Think()

	if self.PlayerUpdate && self.PlayerUpdate > CurTime() then return end
	self.PlayerUpdate = CurTime() + 0.25
	
	self:UpdatePlayerData()

end

function PANEL:PerformLayout()

	surface.SetDrawColor(255, 0, 0, 255)
	surface.DrawRect(5, 5, self:GetWide() - 10, self:GetTall() - 10)

end

function PANEL:Paint()
	return true
end


vgui.Register( "ovias_playercard", PANEL )