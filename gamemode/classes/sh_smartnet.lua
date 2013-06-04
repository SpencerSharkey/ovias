--[[
    Ovias
    Slidefuse LLC 2013
--]]

SF.SmartNet = {}
SF.SmartNet.buffer = {}

SF.SmartNet.meta = {}
SF.SmartNet.meta.__index = SF.SmartNet.meta

function SF.SmartNet:New()
    local o = table.Copy(SF.SmartNet.meta)
    setmetatable(o, SF.SmartNet.meta)
    o:Init()
	table.insert(self.buffer, o.index)
	return o
end

function SF.SmartNet:Find(id)
    if (!self.buffer[id]) then error("No smartnet buffer found with that ID") end
    return self.buffer[id]
end

SMARTNET_ID = 1
function SF.SmartNet.meta:Init()
    self.playerCache = {}
    self.cache = {}
    self.real = {}
    self.index = SMARTNET_ID
    SMARTNET_ID = SMARTNET_ID + 1
    
    if (CLIENT) then
        netstream.Hook("ovSmartnet"..self.index, function(data)
            local id = data.smartnetID
            local smartNet = Sf.SmartNet:Find(id)
            local newData = smartNet:UnpackData(data)
            smartNet:HandleCallback(newData)
        end)
    end
end

function SF.SmartNet.meta:AddObject(name)
    self.cache[name] = "undefined"
    self.real[name] = "undefined"
end

function SF.SmartNet.meta:RemoveObject(name)
    self.real[name] = nil
end

function SF.SmartNet.meta:UpdateObject(name, value, transfer, players)
    self.real[name] = value
    if (transfer) then
        self:Transfer(players)
    end
end

function Sf.SmartNet.meta:Transfer(players)
    if (!players) then players = player.GetAll() end
    
    if (type(players) == "Player") then
        players = {players}
    end
    
    for _, ply in pairs(players) do
        
        local netTable = {}
        netTable.smartnetID = self.index
        
        local compiledNetData = {}
        if (!self.playerCache[ply]) then
            compiledNetData = table.copy(self.real)
        else
            local plyCache = self.playerCache[ply]
            for key, value in pairs(self.real) do
                if (plyCache[key] != value) then
                    compiledNetData[key] = value
                end
            end
        end
            
        netTable.dataTable = table.copy(compiledNetData)
    
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
    for _, func in pairs(self.callbacks) do 
        func(data)
    end
end

function SF.SmartNet.meta:AddCallback(func)
    table.insert(self.callbacks, func)
end
    
