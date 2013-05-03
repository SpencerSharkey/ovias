--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
--]]


SF.Territory = {}
SF.Territory.buffer = {}
SF.Territory.stored = {}

SF.Territory.metaClass = {}
SF.Territory.metaClass.__index = SF.Territory.metaClass

function SF.Territory.metaClass:Init(pos, radius)
	self.points = {}
	self.triangles = {}
	self.excludePoints = {}

	self.position = pos
	self.radius = radius
end

function SF.Territory.metaClass:PointInArea(position)

	local triangle = self:PredictTriangle(position)

	local v = self.triangles[triangle]

	local a = Vector(v[1].x, v[1].y)
	local b = Vector(v[2].x, v[2].y)
	local c = Vector(v[3].x, v[3].y)
	local p = Vector(position.x, position.y)

	local pab = SF.Util:Cross2D(p - a, b - a)
	local pbc = SF.Util:Cross2D(p - b, c - b)

	if (!SF.Util:SameSign(pab, pbc)) then return false end

	local pca = SF.Util:Cross2D(p - c, a - c)

	if (!SF.Util:SameSign(pab, pca)) then return false end


	return true

end

function math.cosec(val)
	return math.sin(val)/1
end

function math.sec(val)
	return math.cos(val)/1
end

function SF.Territory.metaClass:PredictTriangle(pos)

	local ang = math.atan2(pos.x - self.position.x, pos.y - self.position.y)
	local angle = Angle(0, math.deg(ang), 0)
	angle:RotateAroundAxis(Vector(0, 0, 1), -90)
	local y = angle.y
	if (y < 0) then
		y = 180 + (y + 180)
	end
	y = math.abs(y - 360)
	local rad = math.rad(y)
	local r = math.pi*2/32
	return math.floor(rad/r)+1

end

function SF.Territory.metaClass:CalculateTriangles()
	local tid = 1
	for k, point in pairs(self.points) do
		local i = k + 1
		if (k >= #self.points) then
			i = 1
		end

		self.triangles[tid] = {
			self.points[i],
			point,
			self.position
		}
		tid = tid + 1

	end

	SF:Call("OnTerritoryTrianglesCalculated", self)
end

function SF.Territory.metaClass:Draw()

	//for k, point in pairs(self.points) do
	//	if (table.HasValue(self.excludePoints, k)) then continue end
	//	local normal = (point - self.position):Angle():Right()

		//render.DrawBeam(point - normal*2, point + normal*2, 3, 0.5, 0.75, Color(255, 255, 0))
		/*debugoverlay.Axis(point, (point - self.position):Angle(), 15, FrameTime())
		debugoverlay.Text(point, k, FrameTime())
		debugoverlay.Line(point, self.position, FrameTime(), Color(255, 0, 0))*/
	//end

	debugoverlay.Cross(self.position, 10, FrameTime())
end

function SF.Territory.metaClass:FindExclusions()
	for k, point in pairs(self.points) do
		for index, territory in pairs(SF.Territory.stored) do
			if (territory == self) then continue end
			if (territory.position:Distance(point) >= territory.radius) then continue end
			if (territory:PointInArea(point)) then
				table.insert(self.excludePoints, k)
			end
		end
	end
end

function SF.Territory.metaClass:GetNetworkTable()
	local tbl = {}
	tbl.points = self.points
	tbl.faction = self.faction
	tbl.player = self.player
	tbl.position = self.position
	tbl.radius = self.radius

	return tbl
end

function SF.Territory.metaClass:LoadNetworkTable(tbl)

	self:Init(tbl.position, tbl.radius)

	self.points = tbl.points
	self.player = tbl.player
	self.faction = tbl.faction
	self.triangles = {}

	self:CalculateTriangles()

end

function SF.Territory.metaClass:Network()
	netstream.Start(player.GetAll(), "territoryStream", self:GetNetworkTable())
end

/* End meta functions */

function SF.Territory:CreateRaw()
	local o = table.Copy(SF.Territory.metaClass)
	setmetatable(o, SF.Territory.metaClass)
	table.insert(self.stored, o)
	SF:Call("OnTerritoryCreated", o)
	return o
end

function SF.Territory:Create(team, pos, radius)

	local o = self:CreateRaw()
	o:Init(pos, radius)

	return o
end

function SF.Territory:OnTerritoryTrianglesCalculated(territory)

	for tID, territory in pairs(self.stored) do
		territory:FindExclusions()

	end

end

function SF.Territory:FindClosest(pos)
    -- do math
end


SF:RegisterClass("shTerritory", SF.Territory) 