--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

GM.Name			= "Ovias"
GM.Author		= "Slidefuse LLC"
GM.Email 		= "spencer@sf-n.com"
GM.Website 		= "slidefuse.com"

SF = {}
SF.CLASSES = {}

SF.TEAM_CONNECTED = 2
SF.TEAM_SPEC = 1
SF.TEAM_JOINING = 0

AddCSLuaFile("netstream.lua")
include("netstream.lua")

--[[
@class File
@name FindDir
@args string Path, string Mode
@desc Returns the directories from a file search
--]]
function file.FindDir(path, mode)
	local f, d = file.Find(path, mode)
	return d
end

--[[
@class GM
@name CreateTeams
@desc To create teams that will run smoothly with the gamemode.
--]]
function GM:CreateTeams()
	team.SetUp(SF.TEAM_CONNECTED, "Connected", Color(200, 0, 200, 255))

	team.SetUp(SF.TEAM_JOINING, "Joining", Color(20, 20, 20, 255))
	team.SetSpawnPoint(SF.TEAM_JOINING, "info_player_counterterrorist")
end


--[[
@class GM
@name GetGameDescription
@desc A gamemode hook to get the gamemode name
--]]
function GM:GetGameDescription()
	return "Ovias"
end

--[[
@class GM
@name GetGamemodeDescription
@desc An alias of `GM:GetGameDescription`
--]]
function GM:GetGamemodeDescription()
	return self:GetGameDescription()
end

--[[
@class SF
@name Msg
@args string Message, [number Tabs]
@desc Prints a tabbed message
--]]
function SF:Msg(s, t)
	s = tostring(s)
	
	if (!t) then
		s = s.."\n"
		Msg(s)
		return
	end

	for i = 1, t do
		s = "\t"..s
	end
	s = s.."\n"
	Msg(s)
end

--[[
@class SF
@name Print
@args string Message
@desc An alias of `Print`
--]]
function SF:Print(s)
	print(s)
end

-- This is a hackish method to detour default hooks in Garry's Mod to call our own
local oldHook = hook.Call
SF.HookTimings = {}
function hook.Call(name, gamemode, ...)
	if (CLIENT) then
		SF.Client = LocalPlayer()
	end

	local startTime = SysTime()
		for _, v in next, SF.CLASSES do
			if (v[name]) then
				local bSuccess, value = pcall(v[name], v, ...)
				if (!bSuccess) then
					ErrorNoHalt("[OVIAS HOOK '"..name.."'] FAILED\n\t"..value.."\n")
				elseif (value != nil) then
					return value
				end
			end
		end
	local timeTook = SysTime() - startTime

	SF.HookTimings[name] = {timeTook, SysTime()}

	if (value == nil) then
		local startTime = SysTime()
			local bStatus, a, b, c = pcall(oldHook, name, gamemode, ...)
		local timeTook = SysTime() - startTime

		SF.HookTimings[name] = {timeTook, SysTime()}

		if (!bStatus) then
			ErrorNoHalt("[GENERIC HOOK '"..name.."'] FAILED\n\t"..a.."\n")
		else
			return a, b, c
		end
	else
		return value
	end
end

--[[
@class SF
@name PrintTimings
@desc A function to print the pretty hooktimings
--]]
function SF:PrintTimings(filter)
	self:Msg("###############################################")
	self:Msg("# SF Hook Timings")
	for name, data in pairs(self.HookTimings) do
		if (filter and string.lower(name) != string.lower(filter)) then continue end
		local microseconds = data[1]*1000000
		local timeAgo = (SysTime()-data[2])*1000000
		SF:Msg(name.." ("..timeAgo.." Microseconds Ago", 1)
		SF:Msg(microseconds, 2)
	end
	self:Msg("###############################################")
end

--[[
@class SF
@name Call
@args string Hook Name, {var args}
@desc A function that calls a hook with the arguments given
--]]
function SF:Call(name, ...)
	return hook.Call(name, self, ...)
end

--[[
@class SF
@name RandomString
@args number Length, [string Haystack]
@desc Returns a randmized string with a specific length
--]]
function SF:RandomString(length, sHaystack)
	local haystack = sHaystack or "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
	local returnval = ""
	for i = 1, length do
		returnval = returnval..haystack[math.random(1, string.len(haystack))]
	end
	return returnval
end

--[[
@class SF
@name RegisterClass
@args string ClassName, table ClassTable
@desc Registers a class with the specified name
--]]
function SF:RegisterClass(s, t)
	if (!self.CLASSES[s]) then
		self.CLASSES[s] = t
		self:Msg("Registering Class: "..s, 3)
	end
end

--[[
@class SF
@name GetSides
@desc Returns the scope prefixes for the given runtime
--]]
function SF:GetSides()
	if(SERVER) then
		return {"sh_", "sv_"}
	else
		return {"sh_", "cl_"}
	end
end

--[[
@class SF
@name Include
@args string Directory, string File
@desc Runs include(Directory/File)
--]]
function SF:Include(Dir, File)
	include(Dir.."/"..File)
end

--[[
@class SF
@name IncludeCS
@args string Directory, string Prefix
@desc Adds clientside files to the client buffer in a directory
--]]
function SF:IncludeCS(Dir, Prefix)
	local Prefix = Prefix or ""
	self:Msg("Adding Client Folder: ["..self.LoaderDir.."/"..Dir.."]", 1)
	for k, File in pairs(file.Find(self.LoaderDir.."/"..Dir.."/cl_*.lua", "LUA")) do
		self:Msg("Found Client File: "..File, 2)
		AddCSLuaFile(Prefix..Dir.."/"..File)
	end

	for k, File in pairs(file.Find(self.LoaderDir.."/"..Dir.."/sh_*.lua", "LUA")) do
		self:Msg("Found Shared File: "..File, 2)
		AddCSLuaFile(Prefix..Dir.."/"..File)
	end
end

--[[
@class SF
@name IncludeDirectoryRecursive
@args string Directory, string Prefix
@desc Recursively includes a directory
--]]
function SF:IncludeDirectoryRecursive(Dir, Prefix)
    local Prefix = Prefix or ""
    for k, v in pairs(file.FindDir(self.LoaderDir.."/"..Dir.."/*", "LUA")) do
        local File = Dir.."/"..v
		self:IncludeDirectoryRecursive(File)
	end

    self:IncludeDirectory(Dir, Prefix)
end

--[[
@class SF
@name IncludeDirectory
@args string Directory, string Prefix
@desc Includes all the files in a directory non-recursive
--]]
function SF:IncludeDirectory(Dir, Prefix)
	local Prefix = Prefix or ""
	if (SERVER) then
		self:IncludeCS(Dir, Prefix)
	end

	for k, side in pairs(self:GetSides()) do
		self:Msg("Loading Side: "..side.." ["..self.LoaderDir.."/"..Dir.."/"..side.."*.lua]", 1)
		for k, File in pairs(file.Find(self.LoaderDir.."/"..Dir.."/"..side.."*.lua", "LUA")) do
			self:Msg("Found File: "..File, 2)
			self:Include(Dir, File)
		end
	end
end

--[[
@class SF
@name IncludeDirectoryRel
@args string Unknown, string Unknown, [number Tabs=1], [bool Hide=false]
@desc No idea to be honest.
--]]
function SF:IncludeDirectoryRel(Search, Include, t, hide)
	local hide = hide or false
	local t = t or 1

	if (hide) then self:Msg("Adding Client Folder: ["..self.LoaderDir.."/"..Search.."]", t) end
	for k, File in pairs(file.Find(self.LoaderDir.."/"..Search.."/cl_*.lua", "LUA")) do
		if (hide) then self:Msg("Found Client File: "..File, t+1) end
		AddCSLuaFile(Include.."/"..File)
	end

	for k, File in pairs(file.Find(self.LoaderDir.."/"..Search.."/sh_*.lua", "LUA")) do
		if (hide) then self:Msg("Found Shared File: "..File, t+1) end
		AddCSLuaFile(Include.."/"..File)
	end

	for k, side in pairs(self:GetSides()) do
		if (hide) then self:Msg("Loading Side: "..side.." ["..self.LoaderDir.."/"..Search.."/"..side.."*.lua]", t) end
		for k, File in pairs(file.Find(self.LoaderDir.."/"..Search.."/"..side.."*.lua", "LUA")) do
			if (hide) then self:Msg("Found File: "..File, t+1) end
			self:Include(Include, File)
		end
	end
end

--[[
@class SF
@name AddResourceDirectory
@args string Directory
@desc Adds a recursive directory to the resource buffer
--]]
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

--[[
@class SF
@name Init
@args string GamemodeDirectory
@desc Includes and starts the gamemode given the GamemodeDirectory
--]]
function SF:Init(Dir)
	if(SERVER) then
		self.LoaderDir = Dir.."/gamemode"
	else
		self.LoaderDir = Dir.."/gamemode"
	end
	
	self.ResourceDir = "gamemodes/"..Dir.."/content"

	self:Msg("###############################################")
	self:Msg("# "..GM.Name.." by "..GM.Author.." ("..GM.Email..")")
	
	if(SERVER) then
		self:Msg("# Sending Resources to Client Buffer")
		self:AddResourceDirectory("sound")
		self:AddResourceDirectory("models")
		self:AddResourceDirectory("materials")
		self:AddResourceDirectory("resources")
	end
	
	self:Msg("# Loading LUA Files")
	self:IncludeDirectoryRecursive("classes")
	self:IncludeDirectory("vgui")

	self:Msg("###############################################")
end

SF:Init("ovias")
