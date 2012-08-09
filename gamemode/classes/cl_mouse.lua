--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
]]--

if (SERVER) then return end

SF.Mouse = {}

SF.Mouse.ent = ClientsideModel("models/roller.mdl")
SF.Mouse.ent:Spawn()
SF.Mouse.ent:Activate()

gui.EnableScreenClicker(true)

local lastX = 0
local lastY = 0
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
		cmd:SetSideMove(ScrW()*5*-deltaX)
		cmd:SetForwardMove(ScrH()*5*deltaY)
	end

	/* Manual Deltas */
	lastX = x
	lastY = y
end

SF:RegisterClass("clMouse", SF.Mouse)