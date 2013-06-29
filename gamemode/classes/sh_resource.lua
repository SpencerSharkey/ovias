--[[
    Ovias
    Copyright © Slidefuse LLC - 2012
--]]

SF.Resource = {}
SF.Resource.stored = {}

function SF.Resource:AddResource(name, data)
    self.stored[name] = data
end

function SF.Resource:Get(name)
    return self.stored[name] or false
end

SF.Resource:AddResource("iron", {
    name = "Iron",
    mass = 15
})

SF.Resource:AddResource("wood", {
    name = "Wood",
    mass = 10
})

SF:RegisterClass("shResource", SF.Resource)
