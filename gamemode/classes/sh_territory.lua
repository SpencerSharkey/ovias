--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
--]]


SF.Territory = {}
SF.Territory.buffer = {}
SF.Territory.stored = {}
SF.Territory.boundaries = {}

SF.Territory.metaClass = {}
SF.Territory.metaClass.__index = SF.Territory.metaClass

local T_INDEX = 0

function SF.Territory.metaClass:Init(pos, radius)
	self.points = {}
	self.triangles = {}
	self.pointsExcluded = {}
	self.pointsIncluded = {}

	--deprecated
	self.excludePoints = {}
	--/d

	self.position = pos
	self.radius = radius
	T_INDEX = T_INDEX + 1
	self.index = T_INDEX
end

function SF.Territory.metaClass:PointInArea(position)

	local triangle = self:PredictTriangle(position)

	local v = self.triangles[triangle]

	return SF.Util:TestTriangle(position, v)

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
	local tbl = {
		index = self.index,
		points = self.points,
		pointsExcluded = self.pointsExcluded,
		pointsIncluded = self.pointsIncluded,
		faction = self.faction,
		player = self.player,
		position = self.position,
		radius = self.radius
	}

	return tbl
end

function SF.Territory.metaClass:LoadNetworkTable(tbl)

	self:Init(tbl.position, tbl.radius)

	self.index = tbl.index
	self.points = tbl.points
	self.pointsExcluded = tbl.pointsExcluded
	self.pointsIncluded = tbl.pointsIncluded	
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

end

function SF.Territory:FindClosest(pos)
    -- do math
end


SF:RegisterClass("shTerritory", SF.Territory) 