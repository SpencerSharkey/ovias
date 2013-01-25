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