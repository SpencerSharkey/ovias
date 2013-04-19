--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
]]--

SF.Units = {}
SF.Units.stored = {}
SF.Units.buffer = {}

SF.Units.stored_dir = {}
SF.Units.buffer_dir = {}

/* 
	Methods to loading units
*/

function SF.Units:LoadUnits()
	SF:Msg("Loading Units", 2)
	local files, entityFolders = file.Find(SF.LoaderDir.."/units/*", "LUA", "namedesc");

	for k, v in pairs(entityFolders) do
		if (v != ".." and v != ".") then
			ENT = {Type = "anim", Folder = SF.LoaderDir.."/units/"..v};

			if (SERVER) then
				if (file.Exists("gamemodes/"..directory.."/entities/entities/"..v.."/init.lua", "GAME")) then
					include(directory.."/entities/entities/"..v.."/init.lua");
				elseif (file.Exists("gamemodes/"..directory.."/entities/entities/"..v.."/shared.lua", "GAME")) then
					include(directory.."/entities/entities/"..v.."/shared.lua");
				end;

				if (file.Exists("gamemodes/"..directory.."/entities/entities/"..v.."/cl_init.lua", "GAME")) then
					AddCSLuaFile(directory.."/entities/entities/"..v.."/cl_init.lua");
				end;
			elseif (_file.Exists(directory.."/entities/entities/"..v.."/cl_init.lua", "LUA")) then
				include(directory.."/entities/entities/"..v.."/cl_init.lua");
			elseif (_file.Exists(directory.."/entities/entities/"..v.."/shared.lua", "LUA")) then
				include(directory.."/entities/entities/"..v.."/shared.lua");
			end;
			
			if (SERVER) then
				

			scripted_ents.Register(ENT, v); ENT = nil;
		end;
	end;
end

SF:RegisterClass("shUnits", SF.Units)

SF.Units:LoadUnits()
SF.Units:LoadDirectives()
