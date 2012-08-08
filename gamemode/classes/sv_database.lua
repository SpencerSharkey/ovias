--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
]]--

require("tmysql")

SF.Database = {}

function SF.Database:Initialize()
	print("Connecting to Database...")
	//if (!tmysql.initialize("sf-n.net", "sfnet", "M,q#a2uTi#tx", "sfnet_roleplay", 3306)) then
	//	Error("Error connecting to database!")
	//end

	print("Connected to database!")
end

SF:RegisterClass("Database", SF.Database)