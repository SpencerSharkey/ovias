
--[[
	Slidefuse Networking
	Usage is simple, nerds
]]--

if (!SF) then
	SF = {}
end
SF.dataHooks = {}
SF.netCache = {}
SF.netReq = {}

if (SERVER) then
	util.AddNetworkString("SFNet")
	util.AddNetworkString("SFRaw")
	util.AddNetworkString("SFReq")

	function SF:RawNetAll(name, Callback)
		net.Start("SFRaw")
			net.WriteString(name)
			Callback()
		net.Send(player.GetAll())
	end

	function SF:RawNet(player, name, Callback)
		net.Start("SFRaw")
			net.WriteString(name)
			Callback()
		net.Send(player)
	end

	function SF:RawNetHook(name, Callback)
		self.rawHooks[name] = Callback;
	end

	net.Receive("SFRaw", function(len, player)
		local name = net:ReadString()
		if (SF.rawHooks[name]) then
			SF.rawHooks[name](player, len)
		end
	end)

	function SF:NetAll(name, data)
		net.Start("SFNet")
			net.WriteString(name);
			net.WriteTable(data);
		net.Send(player.GetAll());
	end;	
	
	function SF:Net(player, name, data)	
		if (!player or player == nil) then
			return false;
		end;
		net.Start("SFNet")
			net.WriteString(name);
			net.WriteTable(data);
		net.Send(player);
	end;

	function SF:NetHook(name, Callback)
		self.dataHooks[name] = Callback;
	end;	

	net.Receive("SFNet", function(len, player)
		local name = net.ReadString();
		local recTable = net.ReadTable();
		if (SF.dataHooks[name]) then
			SF.dataHooks[name](player, recTable, len);
		end;
	end);

	net.Receive("SFReq", function(len, player)
		local name = net.ReadString()
		local data = SF.netReq[name](player)
		if (data) then
			net.Start("SFReq")
				net.WriteString(name)
				net.WriteTable(data)
			net.Send(player)
		end
	end)

	function SF:NetRegisterReq(name, Callback)
		self.netReq[name] = Callback
	end
	
else

	function SF:RawNet(name, Callback)
		net.Start("SFRaw")
			net.WriteString(name)
			Callback()
		net.SendToServer()
	end

	function SF:RawNetHook(name, Callback)
		self.rawHooks[name] = Callback;
	end

	net.Receive("SFRaw", function(len, player)
		local name = net:ReadString()
		if (SF.rawHooks[name]) then
			SF.rawHooks[name](len)
		end
	end)

	function SF:NetHook(name, Callback)
		self.dataHooks[name] = Callback;
	end;	

	net.Receive("SFNet", function(len)
		local name = net.ReadString();
		
		local recTable = net.ReadTable();
		if (SF.dataHooks[name]) then
			SF.dataHooks[name](recTable, len);
		end;
	end);

	function SF:Net(name, data)
		net.Start("SFNet")
			net.WriteString(name)
			net.WriteTable(data);
		net.SendToServer();
	end;

	net.Receive("SFReq", function(len)
		local name = net.ReadString()
		local data = net.ReadTable()
		if (SF.netReq[name]) then
			SF.netReq[name](data, len)
		end
	end)

	function SF:NetReq(name, Callback)
		self.netReq[name] = Callback
		net.Start("SFReq")
			net.WriteString(name)
		net.SendToServer()
	end

	
end;