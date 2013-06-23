--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

function SF.Territory.metaClass:Calculate()
	--Setup some variables
	local position = self.position + Vector(0, 0, 5)
	local zPos = position.z
	local s = -(math.pi*2)/32
	local index = 1

	--Setup some helpful variables
	local vUp = Vector(0, 0, 1)
	local vDown = Vector(0, 0, -1)
	local skipDistance = 5
	local org = position
	self.recheckQueue = {}

	--This will give us (in radians) angles to go out from, in a clockwise fashion.
	for i = math.pi*2, 0, s do
		--Find the vector offset, using some basic trig.
		local vOffset = Vector(math.cos(i), math.sin(i), 0)

		--Setup the length of the ray, we start at 0 and add for every addition
		local length = 0

		--Setup our first trace, maybe we can make it in one go...
		local tr = SF.Util:SimpleTrace(org, org + vOffset*self.radius)	 
		local prevHit = position
		
		while true do
			
			local newHit
			local tt = SF.Util:SimpleTrace(prevHit, prevHit + vOffset*skipDistance)

			if (!tt) then
				-------------------------
				-- CLIFF/EDGE
				-------------------------
				newHit = prevHit + vOffset*skipDistance
				local dt = SF.Util:SimpleTrace(newHit, newHit + vDown*15)
				if (!dt) then
					--The cliff, it was too TALLZ
					self.points[index] = newHit
					break;
				else
					newHit = dt.HitPos
				end
				
			else

				-------------------------
				-- WALL/UP HILL
				-------------------------

				local testLength = 0
				local ut
			  	
			 	while true do
					local startPos = prevHit + vOffset*skipDistance + Vector(0, 0, 50)
					local endPos = prevHit + vOffset*skipDistance + Vector(0, 0, -10)
					local tt = SF.Util:SimpleTrace(startPos, endPos)

					if (!tt) then
						--Something is wrong, just end previously.
						self.points[index] = prevHit
						break
					else
						if (tt.StartSolid) then
							--Big wall. Abort!
							self.points[index] = prevHit
							break
						else
							local diff = tt.HitPos.z - prevHit.z
							if (diff >= skipDistance/2) then
								--Ending becuase a gradient is too steep
								self.points[index] = prevHit
								break
							end
							newHit = tt.HitPos
						end
					end

					length = length + prevHit:Distance(newHit)
					
					if (length >= self.radius) then
						--Just a regular termination, we got to the end eventually <3
						self.points[index] = prevHit
						break
					end

					prevHit = newHit
				end
				break
			end

			length = length + prevHit:Distance(newHit)
			
			if (length >= self.radius) then
				--We've reached the max distance of our radius, lets end here.
				self.points[index] = prevHit
				break
			end


			prevHit = newHit
		end

		self:CalculateTriangles()

		table.insert(self.recheckQueue, self.index)
		
		--Recalculate excluded points within our territories, etc
		local finalPos = self.points[index]
		for tid, territory in next, SF.Territory.stored do
			if (territory == self) then continue end

			if (territory:PointInArea(finalPos)) then
				table.insert(self.pointsExcluded, index)
				if (!table.HasValue(self.recheckQueue, territory.index)) then
					table.insert(self.recheckQueue, territory.index)
				end
			else
				if (!table.HasValue(territory.pointsIncluded, k)) then
					table.insert(territory.pointsIncluded, k)
				end
			end
		end
		index = index + 1
	end

	//for _, tid in next, self.recheckQueue do
	for _, territory in pairs(SF.Territory.stored) do
		//local territory = SF.Territory.stored[tid]
		territory.pointsIncluded = {}
		territory.pointsExcluded = {}	
		for k, point in next, territory.points do
			for _, checkTerritory in pairs(SF.Territory.stored) do
				if (checkTerritory:PointInArea(point)) then
					if (!table.HasValue(territory.pointsExcluded, k)) then
						table.insert(territory.pointsExcluded, k)
					end
				else
					if (!table.HasValue(territory.pointsIncluded, k)) then
						table.insert(territory.pointsIncluded, k)
					end
				end
			end
		end
		territory:Network()
	end
	
	--this was a major failure.
    //SF.Territory:CalculateBoundaries()
	
end

--Eh, might work
function SF.Territory:GetAllPoints(included)
	local points = {}
	for _, v in ipairs(self.stored) do
		for k, p in pairs(v.points) do
			if (table.HasValue(v.pointsExcluded, k)) then continue end 
			table.insert(points, {k, p, v})
		end
	end
	return points
end


function SF.Territory:NearestNeighbor(territory, point)
	if (type(point) == "number") then
		point = territory.points[point]
	end
	local nearestDistance = math.huge
	local nearestPoint = nil
	for gKey, checkPoint in pairs(self:GetAllPoints(true)) do
		if (table.HasValue(self.boundaryCheckedPoints, checkPoint[2])) then continue end
		if (table.HasValue(checkPoint[3].pointsExcluded, checkPoint[1])) then continue end
		if (checkPoint[3] == territory) then continue end 
		if (point:Distance(checkPoint[2]) <= nearestDistance) then

			nearestDistance = point:Distance(checkPoint[2])
			
			nearestPoint = {checkPoint[3], checkPoint[1], checkPoint[2]} --Territory, PointKey, Position
		end
	end
	if (!nearestPoint or nearestDistance >= 100) then return false end 
	print("Using point "..nearestPoint[1].index.."_"..nearestPoint[2].." - Distance of "..point:Distance(nearestPoint[3]))
	return nearestPoint[1], nearestPoint[2], nearestPoint[3]
	--find the nearest
end

function SF.Territory:AddTerritoryToBoundary(boundary, territory, startIndex)
	--Setup our points and indexes
	local thisID = startIndex
	local nextID = startIndex + 1
	if (!territory.points[nextID]) then
		nextID = 1
	end

	local thisPoint = territory.points[thisID]
	local nextPoint = territory.points[nextID]

	if (table.HasValue(self.boundaryCheckedPoints, thisPoint)) then
		--We've reached a full-circle, lets add this to our boundary buffer
		table.insert(self.boundaries, self.currentBoundary)
		self.currentBoundary = {}
		print("Finishing up a boundary.")
		return
	end

	--print("adding point- "..territory.index..":"..thisID)
	--Lets add this point, assuming it's a goodie. (The startIndex must be a valid point.)
	//table.insert(boundary, {thisPoint, territory, thisID}) -- Add it to our current boundary.
	table.insert(self.currentBoundary, thisPoint)
	table.insert(self.boundaryCheckedPoints, thisPoint) -- Add it so we don't re-add it later, ever.
	--Get some info about our next point
	if (table.HasValue(territory.pointsExcluded, nextID)) then
		-- It's excluded
		-- Since that bitch is excluded, lets move onto a new point.. from a new territory
		print("Needa look for a bitch")
		local nTerritory, nPointID, nPos = self:NearestNeighbor(territory, thisID)
		if (!nTerritory) then
			table.insert(self.boundaries, self.currentBoundary)
			self.currentBoundary = {}
			print("Finishing up a boundary.")
			return
		end
		self:AddTerritoryToBoundary(boundary, nTerritory, nPointID)
		print("DONE")
	
	else
		--We'll just go ahead and start from the next one <3
		self:AddTerritoryToBoundary(boundary, territory, nextID)
	end
end

function SF.Territory:CalculateBoundaries()
	print("START===========================")
	self.boundaryCheckedPoints = {}
	self.boundaries = {}
	local pointTable = self:GetAllPoints(true) //{pointkey, pos, terr}
	self.currentBoundary = {}
	local thisBoundary = {}

	--Loop through all our points that should be included in boundaries...
	for gPointKey, pointData in pairs(pointTable) do
		--Localize useful info
		local pointKey = pointData[1]
		local pointTerritory = pointData[3]
		local pointPos = pointData[2]
		if (table.HasValue(pointTerritory.pointsExcluded, pointKey)) then 
			continue
		end 
		if (!table.HasValue(self.boundaryCheckedPoints, pointPos)) then
			print("Starting a new boundary at "..pointTerritory.index..":"..pointKey)
			self:AddTerritoryToBoundary(thisBoundary, pointTerritory, pointKey)
			--break
		else
			--print("already added, disregard: "..pointTerritory.index..":"..pointKey)
		end
	end

	print("END=======================")
	print("ENDNUM: "..#self.boundaries)
	self:NetworkBoundaries()
end

function SF.Territory:NetworkBoundaries()
	netstream.Start(player.GetAll(), "boundaryStream", self.boundaries)
end

function SF.Territory.metaClass:GetNetworkTable()
	local tbl = {
		index = self.index,
		points = self.points,
		pointsExcluded = self.pointsExcluded,
		pointsIncluded = self.pointsIncluded,
		faction = self.faction:GetNetKey(),
		player = self.player,
		position = self.position,
		radius = self.radius
	}

	return tbl
end

function SF.Territory.metaClass:Network()
	netstream.Start(self:GetFaction():GetPlayers(), "territoryStream", self:GetNetworkTable())
end


SF:RegisterClass("svTerritory", SF.Territory) 
