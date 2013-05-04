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

function SF.Util:SimpleTrace(startpos, endpos)
    local t = util.TraceLine({
    	start = startpos,
    	endpos = endpos
    }) 

    if (t.Hit) then
        return t
    end
    
    return false
end

function SF.Util:TestTriangle(position, v)
	local a = Vector(v[1].x, v[1].y)
	local b = Vector(v[2].x, v[2].y)
	local c = Vector(v[3].x, v[3].y)
	local p = Vector(position.x, position.y)

	local pab = self:Cross2D(p - a, b - a)
	local pbc = self:Cross2D(p - b, c - b)

	if (!self:SameSign(pab, pbc)) then return false end

	local pca = SF.Util:Cross2D(p - c, a - c)

	if (!self:SameSign(pab, pca)) then return false end

	return true
end