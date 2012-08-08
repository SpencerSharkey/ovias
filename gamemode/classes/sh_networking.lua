--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
]]--

if (!SF) then
	SF = {}
end

SF.dataHooks = {};
SF.netDebug = false;

SF.netCache = {};

if (datastream) then
	if (SERVER) then

		function SF:AcceptStream(player, data, id)
			return true;
		end;

		function SF:NetAll(name, data)
			players = _player.GetAll();
			datastream.StreamToClients(players, name, data);
		end;	
		
		function SF:Net(player, name, data)
			if (!player or player == nil) then
				print("---ERROR! Datastream: '"..name.."' players table is nil!");
				return false;
			end;
			datastream.StreamToClients(player, name, data);
		end;

		function SF:NetHook(name, Callback)
			self.dataHooks[name] = Callback;
			datastream.Hook(name, function (player, handler, id, encoded, decoded)
				self.dataHooks[name](player, decoded);
			end);
		end;	
		
	else

		function SF:NetHook(name, Callback)
			self.dataHooks[name] = Callback;
			datastream.Hook(name, function(handler, id, encoded, decoded)
				self.dataHooks[name](decoded)
			end);
		end;	

		function SF:Net(name, data)
			datastream.StreamToServer(name, data);
		end;
		
	end;
else
	if (SERVER) then
		util.AddNetworkString("SFNet");

		function SF:NetAll(name, data)
			net.Start("SFNet")
				net.WriteString(name);
				net.WriteTable(data);
			net.Send(_player.GetAll());
		end;	
		
		function SF:Net(player, name, data)	
			if (!player or player == nil) then
				print("---ERROR! NETWORK: '"..name.."' players table is nil!");
				return false;
			end;
			net.Start("SFNet")
				net.WriteString(name);
				net.WriteTable(data);
			net.Send(player);

			if (self.netDebug) then
				print("_ SERVER _ SF-NET: Sent '"..name.."'\n");
			end;
		end;

		function SF:NetHook(name, Callback)
			self.dataHooks[name] = Callback;
		end;	

		net.Receive("SFNet", function(len, player)
			if (SF.netDebug) then
				print("_ SERVER _ SF-NET: Recieved '"..name.."' Stream ("..len.."B)\n");
			end;
			local name = net.ReadString();
			local recTable = net.ReadTable();
			if (SF.dataHooks[name]) then
				SF.dataHooks[name](player, recTable, len);
			end;
		end);
		
	else

		function SF:NetHook(name, Callback)
			self.dataHooks[name] = Callback;
		end;	

		net.Receive("SFNet", function(len)


			local name = net.ReadString();

			if (SF.netDebug) then
				print("_ CLIENT _ SF-NET: Receieved '"..name.."' Stream ("..len.."B)\n");
			end;
			
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

			if (self.netDebug) then
				print("_ CLIENT _ SF-NET: Sent '"..name.."'\n");
			end;
		end;
		
	end;
end;