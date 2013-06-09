--[[
	Ovias
	Copyright © Slidefuse LLC - 2013
]]--


SF.Hud = {}

function SF.Hud:PostSetFaction()
	self.panel = vgui.Create("sfCreation")
end

function SF.Hud:HUDPaint()
	if (SF.Client:GetFaction()) then
		surface.SetDrawColor(SF.Client:GetFaction():GetColor())
		surface.DrawRect(0, 0, ScrW(), 4)
	end
end

function SF.Hud:OnSpawnMenuOpen()
	RestoreCursorPosition()
	gui.EnableScreenClicker(true)
end

function SF.Hud:OnSpawnMenuClose()
	RememberCursorPosition()
	gui.EnableScreenClicker(false)
end

SF:RegisterClass("clHud", SF.Hud)

local PANEL = {}

function PANEL:Init()
	self:SetSize(400, 120)
	self:SetPos(0, ScrH()-120)

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
			self.sheet:AddSheet(cat, self.tabs[cat], "icon16/bell.png", false, false, cat)
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