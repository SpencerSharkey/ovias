--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

SF.BuildMode = {}

function SF.BuildMode:Cancel(ply)
	netstream.Start(ply, "ovCancelBuildMode", true)
end

netstream.Hook("ovPlaceBuilding", function(ply, data)
	assert(SF.Buildings:Get(data), "Player "..ply:Nick().." sent a building that does't exist.")

	ply:SpawnBuilding(data)
	ply:CancelBuildMode()
end)

SF:RegisterClass("svBuilMode", SF.BuildMode)