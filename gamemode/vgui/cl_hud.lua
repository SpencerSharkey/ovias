--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

SF.Hud = {}

surface.CreateFont( "plyInfo", {
	font = "Trebuchet24",
	size = ScreenScale(13),
	weight = 900,
	blursize = 0,
	scanlines = 0,
	antialias = false,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
} )

function SF.Hud:PostSetFaction()
	self.panel = vgui.Create("sfCreation")

	self.hotBar = vgui.Create("sfMenuBar")
end

local exclude = {"CHudHealth", "CHudBattery"}
function SF.Hud:HUDShouldDraw(name)
	for k, v in next, exclude do
		if name == v then return false end
	end
	return true 
end

local mGradDown = Material("gui/gradient_down.png")
local mGradUp = Material("gui/gradient_up.png")
local mGold = Material("ovias/gold.png")
local mWood = Material("ovias/wood.png")

function SF.Hud:HUDPaint()

	if (!SF.Client:GetFaction()) then return end

	if (SF.Client:GetFaction()) then
		surface.SetDrawColor(SF.Client:GetFaction():GetColor())
		surface.DrawRect(0, 0, ScrW(), 4)
	end	

	local iconwidth = 10
	local barwidth = 80 + surface.GetTextSize("0") * 2 + 80

	-- Too lazy to make my own
	surface.SetMaterial(mGradDown)
	surface.SetDrawColor(51, 204, 255)
	surface.DrawTexturedRect(- 10, 70, barwidth, 40)

	surface.SetMaterial(mGradUp)
	surface.SetDrawColor(0, 138, 184)
	surface.DrawTexturedRect(- 10, 70, barwidth, 40)
	-- End of lazyness

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetFont("plyInfo")
	surface.SetTextPos(50, 72)
	surface.DrawText("0")

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetFont("plyInfo")
	surface.SetTextPos(iconwidth + 42 * 3, 72)
	surface.DrawText("0")

	surface.SetMaterial(mGold)
	surface.SetDrawColor(255, 255, 255)
	surface.DrawTexturedRect(2, 72.5, 40, 33)

	surface.SetMaterial(mWood)
	surface.SetDrawColor(255, 255, 255)
	surface.DrawTexturedRect(iconwidth * 7 + surface.GetTextSize("0"), 72.5, 40, 33)

	
	draw.RoundedBox(1, 5, 10, 250, 40, Color(0,0,0,190))
	draw.SimpleText("Faction: Colour HERE" ,"TargetID", 25, 30, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	draw.SimpleText("Faction Gold: N/A" ,"TargetID", 25, 45, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

end

function SF.Hud:OnSpawnMenuOpen()
	BuildingMenu:MoveTo(0, ScrH() - 120, 0.5, 0, 1)
end

function SF.Hud:OnSpawnMenuClose()
	BuildingMenu:MoveTo(0, ScrH(), 0.5, 0, 1)
end

SF:RegisterClass("clHud", SF.Hud)

local PANEL = {}

function PANEL:Init()
	self:SetSize(400, 120)
	self:SetPos(0, ScrH())

	BuildingMenu = self

	self.sheet = vgui.Create("DPropertySheet", self)
	self.sheet:StretchToParent(1, 1, 1, 1)

	self.buildings = {}

	self.tabs = {}
	for k, v in pairs(SF.Buildings:GetBuildings()) do
		if (v:PollInfo("hideSpawn")) then continue end

		local cat = v:PollInfo("category")
		if (!self.tabs[cat]) then
			self.tabs[cat] = vgui.Create("DPanelList", self.sheet)
			self.tabs[cat]:EnableHorizontal(true)
			local tab = self.sheet:AddSheet(cat, self.tabs[cat], "icon16/bell.png", false, false, cat)
            if (cat == "Kingdom") then
                self.sheet:SetActiveTab(tab.Tab)
            end
		end

		local icon = vgui.Create("SpawnIcon")
		icon.building = v
		icon:SetModel(v:GetOviasModel())
		icon.DoClick = function(p)
			SF.BuildMode:StartBuild(k)
		end
		self.tabs[cat]:AddItem(icon)
		table.insert(self.buildings, icon)

	end
end

function PANEL:Think()
	for k, v in pairs(self.buildings) do
		v:SetVisible(v.building:GetRequirements():CanView())
	end
end

function PANEL:Paint(w, h)

end

vgui.Register("sfCreation", PANEL, "DPanel")
