--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

SF.FrameFunc = {}
SF.FrameFunc.buffer = {}
SF.FrameFunc.currentFrame = 1

function SF.FrameFunc:Think()
    for k, v in pairs(self.buffer) do
        if (k == self.currentFrame) then
            v(currentFrame)
        end
    end
    self.currentFrame = self.currentFrame + 1
end

function SF.FrameFunc:Create(delay, func)
    self.buffer[self.currentFrame + delay] = func 
end

SF.FrameFunc.frameChain = {}
SF.FrameFunc.frameChain.__index = SF.FrameFunc.frameChain

function SF.FrameFunc.frameChain:AddLink(func)
    if (!self.nextStep) then
        self.nextStep = 0
    end
    self.nextStep = self.nextStep + self.frameSkip
    SF.FrameFunc:Create(self.nextStep, func)
end

function SF.FrameFunc:FrameChain(name, frameSkip)
    local o = {}
    setmetatable(o, self.frameChain)
    o.frameSkip = frameSkip
    return o
end


