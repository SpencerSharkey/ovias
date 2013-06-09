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

	self.PlayerList = vgui.Create("DScrollPanel", self)
	self.PlayerList:SetSize(self:GetWide() - 20, self:GetTall() / 1.32)
	self.PlayerList:SetPos(10, self:GetTall() / 5 + 20)

	for k, v in pairs(player.GetAll()) do
		self.PlayerCard = vgui.Create("ovias_playercard", self.PlayerList)
		self.PlayerCard:Choose(v)
		self.PlayerCard:SetPos(5, 0 + self.PlayerHeight)

		self.PlayerHeight = self.PlayerHeight + 50
	end

	self.HostName = vgui.Create("DLabel", self)
	self.HostName:SetText( GetHostName() )
	self.HostName:SetFont("ScoreboardNorm")
	self.HostName:SetPos(self:GetWide() / 3 + 30, 10)
	self.HostName:SizeToContents()

end

function PANEL:Paint( )

	surface.SetDrawColor(0, 0, 0, 255)
	surface.DrawRect(0, 0, self:GetWide(), self:GetTall())

	surface.SetDrawColor(50, 50, 50, 255)
	surface.DrawRect(10, 10, self:GetWide() / 3, self:GetTall() / 5)		

	surface.SetDrawColor(50, 50, 50, 255)
	surface.DrawRect(self:GetWide() / 3 + 20, 10, self:GetWide() / 1.585, self:GetTall() / 5)

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

	self:SetSize(770, 45)
	self:SizeToContents()

	self.Card = vgui.Create("DPanel", self)
	self.Card:SetSize(self:GetWide(), self:GetTall())	
	self.Card.Paint = function()
		if self.Player:IsBot() then
			draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(0, 100, 0, 255))
		else
			draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), self.Player:GetFaction():GetColor())
		end
	end

	self.PlayerName = vgui.Create("DLabel", self.Card)
	self.PlayerName:SetFont( "ScoreboardNorm" )

	self.PlayerAvatar = vgui.Create("AvatarImage", self.Card)

end

function PANEL:Choose( ply )

	self.Player = ply
	self:UpdatePlayerData()

	self.PlayerAvatar:SetPlayer(self.Player)

end

function PANEL:UpdatePlayerData()

	if !self.Player then return end
	if !self.Player:IsValid() then return end

	self.PlayerName:SetText( self.Player:Nick() )
	
	//self:InvalidateLayout()

end

function PANEL:Paint()

end

function PANEL:Think()

	if self.PlayerUpdate && self.PlayerUpdate > CurTime() then return end
	self.PlayerUpdate = CurTime() + 0.25
	
	self:UpdatePlayerData()

end

function PANEL:PerformLayout()

	self.PlayerName:SetPos(50, 0)
	self.PlayerName:SizeToContents()

	self.PlayerAvatar:SetPos(2, 2)
	self.PlayerAvatar:SetSize(40, 40)

end

function PANEL:Paint()
	return true
end


vgui.Register( "ovias_playercard", PANEL, "Panel" )