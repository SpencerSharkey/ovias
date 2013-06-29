--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
--]]

if (!SF.WorldPanel) then
	SF.WorldPanel = vgui.GetWorldPanel()
end

SF.Camera.ent = ClientsideModel("models/roller.mdl")
SF.Camera.ent:Spawn()
SF.Camera.ent:Activate()

local lastX = 0
local lastY = 0
function SF.Camera:CreateMove(cmd)
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

	cmd:SetMouseX(gui.MouseX())
	cmd:SetMouseY(gui.MouseY())
end

function SF.Camera:Initialize()
	gui.EnableScreenClicker(true)
end

function SF.WorldPanel:OnMouseWheeled(delta)
	if (!SF.Client.ov_ZoomDelta) then
		SF.Client.ov_ZoomDelta = 0
	end
	SF.Client.ov_ZoomDelta = SF.Client.ov_ZoomDelta + delta* -1 * 12
end

function SF.Camera:GUIMousePressed(mc, dir)
	print("WTF")
	if (mc == MOUSE_LEFT) then
		SF:Call("OviasLeftMousePress")
	elseif (mc == MOUSE_RIGHT) then
		SF:Call("OviasRightMousePress")
	end
end

function SF.Camera:GUIMouseReleased(mc)
	if (mc == MOUSE_LEFT) then
		SF:Call("OviasLeftMouseRelease")
	elseif (mc == MOUSE_RIGHT) then
		SF:Call("OviasRightMouseRelease")
	end
end


SF:RegisterClass("clCamera", SF.Camera)