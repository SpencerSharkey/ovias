--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
]]--

if (SERVER) then return end

local CLASS = {}

local e = ClientsideModel("models/roller.mdl")
e:Spawn()
e:Activate()

CLASS.Rotating = true



function CLASS:Think()
	e:SetAngles(Angle(0, CurTime()*150, 0))
	if (input.IsMouseDown(MOUSE_MIDDLE)) then
		if (!self.Rotating) then
			gui.EnableScreenClicker(false)
			self.Rotating = true
			RememberCursorPosition()
		end
	else
		if (self.Rotating) then
			gui.EnableScreenClicker(true)
			RestoreCursorPosition()
			self.Rotating = false
		end
		gui.EnableScreenClicker(true)
	end
	local tr = LocalPlayer():GetEyeTrace()
	//print(tr.HitPos)
	e:SetPos(tr.HitPos + Vector(0, 0, 0))
	//e:SetAngles(tr.HitNormal:Angle())
end

SF:RegisterClass("clMouse", CLASS)