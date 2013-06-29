

PANEL = {}

function PANEL:Init()
	self:SetSize(256, 32)
	self:SetPos(ScrW()-256, ScrH()-32)
	self.buttons = {}
	SF:Call("UpdateMenuButtons", self)
end

function PANEL:AddButton(name, callback)

	self.buttons[name] = vgui.Create("DButton", self)
	self.buttons[name]:SetPos((table.Count(self.buttons)-1)*32, 0)
	self.buttons[name]:SetText(name)
	self.buttons[name].DoClick = callback
	self.buttons[name]:SetSize(32, 32)
end

function PANEL:Think()
end

vgui.Register("sfMenuBar", PANEL, "DPanel")