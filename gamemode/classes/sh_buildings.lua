--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
]]--

SF.Buildings = {}
SF.Buildings.stored = {}
SF.Buildings.buffer = {}

/* 
	Buildings loading and registering
*/

function SF.Buildings:LoadBuildings()
	SF:Msg("Loading Buildings...", 2)
	local files, folders = file.Find(SF.LoaderDir.."/buildings/*", "LUA", "namedesc")

	for k, v in pairs(files) do
		if (v != ".." and v != ".") then

			local baseName = string.sub(v, 1, -5)

			ENT = {Base = "base_building", Folder = SF.LoaderDir.."/buildings"}

			if (SERVER) then
				AddCSLuaFile(SF.LoaderDir.."/buildings/"..v)	
			end
			include(SF.LoaderDir.."/buildings/"..v)

			SF:Msg("Loading Building: "..baseName, 3)
			scripted_ents.Register(ENT, "building_"..baseName)
			
			self.stored[baseName] = ENT

			ENT = nil
		end
	end
end

//function SF.Buildings:

SF:RegisterClass("shBuildings", SF.Buildings)

SF.Buildings:LoadBuildings()