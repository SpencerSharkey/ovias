surface.CreateFont("debug", {
	font = "Arial",
	size = 12,
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
})
/*
--	Ovias
--	Copyright © Slidefuse LLC - 2012
*/


SF.Territory = {}
SF.Territory.org = false
SF.Territory.points = {};

function SF.Territory:PostDrawOpaqueRenderables()

	render.SetMaterial(Material("models/white"))
	for k, v in pairs(self.points) do
		render.DrawBox(v, Angle(0, 0, 0), Vector(-2, -2, -2), Vector(2, 2, 2), Color(255, 0, 0), true)
		render.DrawLine(self.org, v, Color(0, 255, 0), true)
	end

	for k, v in pairs(self.points) do
		
	end
end

function SF.Territory:HUDPaint()
	for k, v in pairs(self.points) do
		local p = v:ToScreen()
		draw.SimpleTextOutlined(k, "debug", p.x, p.y, Color(255, 255, 255), 0, 0, 1, Color(0, 0, 0))
	end
end



SF:NetHook("territoryTest", function(data)
	SF.Territory.org = data["org"]
	SF.Territory.points = data["points"]
end)

SF:RegisterClass("clTerritory", SF.Territory)