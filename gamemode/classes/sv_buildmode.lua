--[[
	Ovias
	Copyright © Slidefuse LLC - 2013
]]--


SF.BuildMode = {}

function SF.BuildMode:Cancel(ply)
	netstream.Start(ply, "ovCancelBuildMode", true)
end

netstream.Hook("ovPlaceBuilding", function(ply, data)
	local building = SF.Buildings:Get(data)
	if (!building) then error("Not the right building fgt") end
	ply:SpawnBuilding(data)
	ply:CancelBuildMode()
end)

SF:RegisterClass("svBuilMode", SF.BuildMode)