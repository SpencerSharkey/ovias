--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
]]--

GM.Name			= "Ovias"
GM.Author		= "Slidefuse LLC"
GM.Email 		= "spencer@sf-n.com"
GM.Website 		= "slidefuse.com"

SF = {}
SF.CLASSES = {}

SF.TEAM_CONNECTED = 2
SF.TEAM_SPEC = 1
SF.TEAM_JOINING = 0

if (SERVER) then
	require("json")
end

function GM:CreateTeams()
	team.SetUp(SF.TEAM_CONNECTED, "Connected", Color(200, 0, 200, 255))

	team.SetUp(SF.TEAM_JOINING, "Joining", Color(20, 20, 20, 255))
	team.SetSpawnPoint(SF.TEAM_JOINING, "info_player_counterterrorist")
end

function GM:GetGameDescription()
	return "Ovias"
end

function GM:GetGamemodeDescription()
	return self:GetGameDescription()
end

function SF:Msg(s)
	Msg(s)
end

function SF:Print(s)
	print(s)
end

local oldHook = hook.Call
function hook.Call(name, gamemode, ...)
	if (CLIENT) then
		SF.Client = LocalPlayer()
	end
	local returnvalue = true
	for _, v in pairs(SF.CLASSES) do
		if (v[name]) then
			returnvalue = v[name](v, ...)
		end
		if (v["HookCall"]) then
			returnvalue = v:HookCall(name, gamemode, ...)
		end
	end

	if (returnvalue) then
		//print(name)
		returnvalue = oldHook(name, gamemode, ...)
	end

	return returnvalue
end

function SF:Call(name, ...)
	return hook.Call(name, self, ...)
end

function SF:RandomString(length, sHaystack)
	local haystack = sHaystack or "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
	local returnval = ""
	for i = 1, length do
		returnval = returnval..haystack[math.random(1, string.len(haystack))]
	end
	return returnval
end

function SF:RegisterClass(s, t)
	if (!self.CLASSES[s]) then
		self.CLASSES[s] = t
		self:Msg("\t\t\tRegistering Class: "..s.."\n")
	end
end

function SF:GetSides()
	if(SERVER) then
		return {"sh_", "sv_", "cl_"} // Include cl_ for now to make autoupdate work
	else
		return {"sh_", "cl_"}
	end
end

function SF:Include(Dir, File)
	include(Dir.."/"..File)
end

function SF:IncludeCS(Dir)
	self:Msg("\tAdding Client Folder: ["..self.LoaderDir.."/"..Dir.."]\n")
	for k, File in pairs(file.Find(self.LoaderDir.."/"..Dir.."/cl_*.lua", LUA_PATH)) do
		self:Msg("\t\tFound Client File: "..File.."\n")
		AddCSLuaFile(Dir.."/"..File)
	end

	for k, File in pairs(file.Find(self.LoaderDir.."/"..Dir.."/sh_*.lua", LUA_PATH)) do
		self:Msg("\t\tFound Shared File: "..File.."\n")
		AddCSLuaFile(Dir.."/"..File)
	end
end

function SF:IncludeDirectory(Dir)
	if (SERVER) then
		self:IncludeCS(Dir)
	end

	for k, side in pairs(self:GetSides()) do
		self:Msg("\tLoading Side: "..side.." ["..self.LoaderDir.."/"..Dir.."/"..side.."*.lua]\n")
		for k, File in pairs(file.Find(self.LoaderDir.."/"..Dir.."/"..side.."*.lua", LUA_PATH)) do
			self:Msg("\t\tFound File: "..File.."\n")
			self:Include(Dir, File)
		end
	end
end

function SF:AddResourceDirectory(Dir)
	local FoundDir = false
 	for k, v in pairs(file.FindDir(self.ResourceDir.."/"..Dir.."/*", "MOD")) do
		local File = Dir.."/"..v
		self:AddResourceDirectory(File)
	end

	for k, v in pairs(file.Find(self.ResourceDir.."/"..Dir.."/*", "MOD")) do
		if (!string.find(v, ".bz2", 1, true) and !string.find(v, ".bat", 1, true)) then
			local File = Dir.."/"..v
			resource.AddFile(File)
		end
 	end
end

SF.PlayerMeta = FindMetaTable("Player")
SF.EntityMeta = FindMetaTable("Entity")

function SF:Init(Dir)
	if(SERVER) then
		self.LoaderDir = Dir.."/gamemode"
	else
		self.LoaderDir = Dir.."/gamemode"
	end
	
	self.ResourceDir = "gamemodes/"..Dir.."/content"

	self:Print("###############################################")
	self:Print("# "..Dir.." by Slidefuse")
	
	if(SERVER) then
		self:Print("# Sending Resources to Client")
		self:AddResourceDirectory("sound")
		self:AddResourceDirectory("models")
		self:AddResourceDirectory("materials")
		self:AddResourceDirectory("resources")
	end
	
	self:Print("# Loading LUA Files")
	self:IncludeDirectory("classes")
	self:IncludeDirectory("vgui")

	self:Print("\tSetting up NetHooks")
	self:Call("SetupNetHooks")
	self:Print("###############################################")

	self:Msg("*** Search ***\n")
	SF:Msg(GM.Folder:gsub("gamemodes/","") .. "/gamemode\n")
end



SF:Init("ovias")