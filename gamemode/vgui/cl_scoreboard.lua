local PANEL = {}

function PANEL:Init( )

	Scoreboard = self

end

function PANEL:Paint( )

end

function PANEL:PermformLayout( )

end

vgui.Register( "ovias_scoreboard", PANEL, "Panel" )

function GM:ScoreboardShow( )
	gui.EnableScreenClicker( true )

	oviasScoreboard = vgui.Create( "ovias_scoreboard" )
	oviasScoreboard:SetVisible( true )
end

function GM:ScoreboardHide( )
	gui.EnableScreenClicker( false )

	oviasScoreboard:SetVisible( false )
end