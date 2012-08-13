--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
]]--

if (SERVER) then return end

local worldPanel = vgui.GetWorldPanel()
SF.Mouse = {}

SF.Mouse.ent = ClientsideModel("models/roller.mdl")
SF.Mouse.ent:Spawn()
SF.Mouse.ent:Activate()

gui.EnableScreenClicker(true)

local lastX = 0
local lastY = 0
local dragAncor, dragTime
function SF.Mouse:CreateMove(cmd)
	local x, y = gui.MousePos()
	local deltaX = x-lastX
	local deltaY = y-lastY

	/* Rotation */
	local angle = cmd:GetViewAngles()
	if (input.IsMouseDown(MOUSE_MIDDLE)) then
		angle.yaw = angle.yaw + deltaX/((ScrW()/360)*1) //The division cleans it up for different monitors.
		cmd:SetViewAngles(angle)
	end

	/* Movement /w Right Click + Drag */
	if (input.IsMouseDown(MOUSE_RIGHT)) then
		local tr
		if (dragAnchor) then //Override the pos with the anchor, so we can be pinpoint :)
			tr = LocalPlayer():GetEyeTraceAnchor(dragAnchor)
			//print(tr.HitPos)
		else
			tr = LocalPlayer():GetEyeTrace()
			dragAnchor = tr.HitPos
			self.ent:SetPos(dragAnchor)
			dragTime = CurTime()
		end

		local deltaTime = CurTime() - dragTime
		local deltaPos = tr.HitPos - dragAnchor
		print(deltaPos)
		LocalPlayer().ov_DragDelta = Vector(math.Round(deltaPos.x), math.Round(deltaPos.y), math.Round(deltaPos.z))
		//print(deltaTime, LocalPlayer().ov_DragDelta)
	else
		dragAnchor = nil
		LocalPlayer().ov_DragDelta = nil
		dragtime = nil
		self.ent:SetPos(Vector(0))
	end

	/* Manual Deltas */
	lastX = x
	lastY = y
end


function worldPanel:OnMouseWheeled(delta)
	if (!LocalPlayer().ov_ZoomDelta) then
		LocalPlayer().ov_ZoomDelta = 0
	end
	LocalPlayer().ov_ZoomDelta =  LocalPlayer().ov_ZoomDelta + delta*-1 * 12
end

SF:RegisterClass("clMouse", SF.Mouse)