--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
--]]

SF.Util = {}

function SF.Util:Cross2D(u, v)
	return u.y * v.x - u.x * v.y
end

function SF.Util:SameSign(x, y)
	if (x >= 0 and y >= 0) then
		return true
	elseif (x < 0 and y < 0) then
		return true
	end
	return false
end