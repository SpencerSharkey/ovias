--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

SF.Units = {}
SF.Units.stored = {}
SF.Units.buffer = {}

/* 
	Unit loading and registering
*/

function SF.Units:LoadUnits()
	SF:Msg("Loading Units...", 2)
	local files, folders = file.Find(SF.LoaderDir.."/units/*", "LUA", "namedesc")

	for k, v in next, files do
		if (v != ".." and v != ".") then

			local baseName = string.sub(v, 1, -5)

			ENT = {Base = "base_nextbot_ovias", Folder = SF.LoaderDir.."/units"}

			if (SERVER) then
				AddCSLuaFile(SF.LoaderDir.."/units/"..v)	
			end
			include(SF.LoaderDir.."/units/"..v)

			SF:Msg("Loading Unit: "..baseName, 3)
			scripted_ents.Register(ENT, "unit_"..baseName)
			
			self.stored[baseName] = ENT

			ENT = nil
		end
	end
end

SF:RegisterClass("shUnits", SF.Units)

SF.Units:LoadUnits()