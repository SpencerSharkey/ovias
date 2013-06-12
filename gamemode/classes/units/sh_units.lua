--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

SF.Units = {}
SF.Units.stored = {}
SF.Units.buffer = {}

function SF.Units:LoadUnits()
	SF:Msg("###############################################")
	SF:Msg("# Loading Units...")
	local files, folders = file.Find(SF.LoaderDir.."/units/*", "LUA", "namedesc")

	for k, v in next, files do
		if (v != ".." and v != ".") then

			local baseName = string.sub(v, 1, -5)
			
			ENT = {Base = "base_nextbot_ovias", Folder = SF.LoaderDir.."/units"}

			if (SERVER) then
				AddCSLuaFile(SF.LoaderDir.."/units/"..v)	
			end
			include(SF.LoaderDir.."/units/"..v)

			SF:Msg("Loading Unit: "..baseName, 1)
			if (SERVER) then

				scripted_ents.Register(ENT, "unit_"..baseName)
			else
				local tbl = table.Merge(scripted_ents.Get("base_nextbot_ovias"), ENT)
				scripted_ents.Register(tbl, "unit_"..baseName)
			end

			ENT.typeID = baseName

			self.stored[baseName] = table.Merge(scripted_ents.Get("base_nextbot_ovias"), ENT)


			ENT = nil
		end
	end
	SF:Msg("###############################################")
	SF:Call("InitPostUnits")
end

function SF.Units:InitPostEntity()
	self:LoadUnits()
end

function SF.Units:FindUnitEnts()
	return ents.FindByClass("unit_*")
end
