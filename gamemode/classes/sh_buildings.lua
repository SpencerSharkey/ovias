--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

SF.Buildings = {}
SF.Buildings.stored = {}
SF.Buildings.buffer = {}

--[[
	Buildings loading and registering
--]]

function SF.Buildings:LoadBuildings()
	SF:Msg("###############################################")
	SF:Msg("# Loading Buildings...")
	local files, folders = file.Find(SF.LoaderDir.."/buildings/*", "LUA", "namedesc")

	for k, v in next, files do
		if (v != ".." and v != ".") then

			local baseName = string.sub(v, 1, -5)

			ENT = {Base = "base_building", Folder = SF.LoaderDir.."/buildings"}

			if (SERVER) then
				AddCSLuaFile(SF.LoaderDir.."/buildings/"..v)	
			end
			include(SF.LoaderDir.."/buildings/"..v)

			SF:Msg("Loading Building: "..baseName, 1)
			scripted_ents.Register(ENT, "building_"..baseName)
			
			ENT.typeID = baseName
			self.stored[baseName] = table.Merge(scripted_ents.Get("base_building"), ENT)

			ENT = nil
		end

		
	end
	SF:Msg("###############################################")
	SF:Call("InitPostBuildings")
end

function SF.Buildings:GetBuildings()
	return self.stored
end

function SF.Buildings:Get(id)
	return self.stored[id]
end

function SF.Buildings:InitPostEntity()
	self:LoadBuildings()
end

SF:RegisterClass("shBuildings", SF.Buildings)
