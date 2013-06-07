--[[
	Ovias
	Copyright © Slidefuse LLC - 2013
]]--


SF.Hud = {}

function SF.Hud:Initialize()
	self.panel = vgui.Create("sfCreation")
end

function SF.Hud:HUDPaint()
	if (SF.Client:GetFaction()) then
		//print()
		surface.SetDrawColor(SF.Client:GetFaction():GetColor())
		surface.DrawRect(0, 0, ScrW(), 4)
	end
end

SF:RegisterClass("clHud", SF.Hud)

local PANEL = {}

function PANEL:Init()
	self:SetSize(400, 200)
	self:SetPos(0, ScrH()-200)

	self.sheet = vgui.Create("DPropertySheet", self)
	self.sheet:StretchToParent(1, 1, 1, 1)

	self.tabs = {}
	/*for k, v in pairs(SF.Buildings) do
		if (!self.tabs[v.category]) then
			self.tabs[v.category] = vgui.Create("DPanelList", self.sheet)
			self.tabs[v.category]:EnableHorizontal(true)
			self.sheet:AddSheet(v.category, self.tabs[v.category], "icon16/bell.png", false, false, v.category)
		end

		local icon = vgui.Create("SpawnIcon")
		icon:SetModel(v.model)
		icon.DoClick = function(p)
			RunConsoleCommand("sfCreate", k)
		end
		self.tabs[v.category]:AddItem(icon)

	end*/
end

function PANEL:Paint(w, h)

end

vgui.Register("sfCreation", PANEL, "DPanel")