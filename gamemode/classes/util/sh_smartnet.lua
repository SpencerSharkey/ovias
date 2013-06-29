--[[
    Ovias
    Slidefuse LLC 2013
--]]

SF.SmartNet = {}
SF.SmartNet.buffer = {}

SF.SmartNet.meta = {}
SF.SmartNet.meta.__index = SF.SmartNet.meta

function SF.SmartNet:New(key)
    local o = table.Copy(SF.SmartNet.meta)
    setmetatable(o, SF.SmartNet.meta)
    o:Init(key)
	return o
end

function SF.SmartNet:Find(id)
    if (!self.buffer[id]) then error("No smartnet buffer found with that ID ("..id..")") end
    return self.buffer[id]
end

SMARTNET_ID = 1
function SF.SmartNet.meta:Init(key)
    self.callbacks = {}
    self.players = {}
    self.playerCache = {}
    self.real = {}
    self.index = key
    SF.SmartNet.buffer[self.index] = self
    
    if (CLIENT) then
        netstream.Hook("ovSmartnet"..self.index, function(data)
            local id = data.smartnetID
            local smartNet = SF.SmartNet:Find(id)
            local newData = smartNet:UnpackData(data)
            smartNet:HandleCallback(newData)
        end)
    end
end

function SF.SmartNet.meta:SetObject(obj)
    self.netObject = obj
end

function SF.SmartNet.meta:GetObject()
    return self.netObject
end

function SF.SmartNet.meta:AddObject(name, default)
    self.real[name] = default or "undefined"
end

function SF.SmartNet.meta:RemoveObject(name)
    self.real[name] = nil
end

function SF.SmartNet.meta:SetPlayers(tbl)
    self.players = tbl
end

function SF.SmartNet.meta:UpdateObject(name, value, transfer, players)
    self.real[name] = value
    if (transfer) then
        if (!players) then
            players = self.players
        end
        self:Transfer(players)
    end
end

function SF.SmartNet.meta:Transfer(players)
    if (!players) then players = player.GetAll() end
    
    if (type(players) == "Player") then
        players = {players}
    end
    
    for _, ply in next, players do
        
        local netTable = {}
        netTable.smartnetID = self.index
        
        local compiledNetData = {}
        if (!self.playerCache[ply]) then
            compiledNetData = table.Copy(self.real)
        else
            local plyCache = self.playerCache[ply]
            for key, value in next, self.real do
                if (plyCache[key] != value) then
                    compiledNetData[key] = value
                end
            end
        end
            
        netTable.dataTable = table.Copy(compiledNetData)
    
        netstream.Start(ply, "ovSmartnet"..self.index, netTable)
            
        self.playerCache[ply] = compiledNetData
    end
end

--Client buffer funcs
function SF.SmartNet.meta:UnpackData(data)
    local ret = {}
    ret = data.dataTable
    return ret
end

function SF.SmartNet.meta:HandleCallback(data)
    for _, func in next, self.callbacks do 
        func(data, self.netObject)
    end
end

function SF.SmartNet.meta:AddCallback(func)
    table.insert(self.callbacks, func)
end
    
SF:RegisterClass("shSmartnet", SF.SmartNet)