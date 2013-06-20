--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

function SF.Territory.metaClass:Calculate()
	local position = self.position + Vector(0, 0, 5)
	local zPos = position.z
	local s = (math.pi*2)/32
	local index = 1

	local vUp = Vector(0, 0, 1)
	local vDown = Vector(0, 0, -1)
	local skipDistance = 5
	local org = position
	self.recheckQueue = {}

	for i = 0, math.pi*2, s do
		local vOffset = Vector(math.cos(i), math.sin(i), 0)
		local length = 0
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
		--Check for excluded bbz
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

	for _, tid in next, self.recheckQueue do
		local territory = SF.Territory.stored[tid]
		territory.pointsIncluded = {}
		territory.pointsExcluded = {}	
		for k, point in next, territory.points do
			if (self:PointInArea(point)) then
				if (!table.HasValue(territory.pointsExcluded, k)) then
					table.insert(territory.pointsExcluded, k)
				end
			else
				if (!table.HasValue(territory.pointsIncluded, k)) then
					table.insert(territory.pointsIncluded, k)
				end
			end
		end
		territory:Network()
	end

    SF.Territory:CalculateBoundaries()
	
end

--Eh, might work
function SF.Territory:GetAllPoints(included)
	local points = {}
	for _, v in ipairs(self.stored) do
		for k, p in pairs(v.points) do
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
	for _, checkPoint in pairs(self:GetAllPoints(true)) do
		if (table.HasValue(territory.pointsExcluded, checkPoint[1])) then continue end
		if (checkPoint[3] == territory) then continue end 
		if (point:Distance(checkPoint[2]) <= nearestDistance) then
			nearestDistance = point:Distance(checkPoint[2])
			nearestPoint = {checkPoint[3], checkPoint[1], checkPoint[2]} --Territory, PointKey, Position
		end
	end
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
		table.insert(self.boundaries, boundary)
		print("Finishing up a boundary.")
		return
	end

	print("adding point- "..territory.index..":"..thisID)
	--Lets add this point, assuming it's a goodie. (The startIndex must be a valid point.)
	table.insert(boundary, {thisPoint, territory, thisID}) -- Add it to our current boundary.
	table.insert(self.boundaryCheckedPoints, thisPoint) -- Add it so we don't re-add it later, ever.
	--Get some info about our next point
	if (table.HasValue(territory.pointsExcluded, nextID)) then
		-- It's excluded
		-- Since that bitch is excluded, lets move onto a new point.. from a new territory
		print("Needa look for a bitch")
		local nTerritory, nPointID, nPos = self:NearestNeighbor(territory, thisID)
		self:AddTerritoryToBoundary(boundary, nTerritory, nPointID)
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
	local thisBoundary = {}

	--Loop through all our points that should be included in boundaries...
	for gPointKey, pointData in pairs(pointTable) do
		--Localize useful info
		local pointKey = pointData[1]
		local pointTerritory = pointData[3]
		local pointPos = pointData[2]
		if (table.HasValue(pointTerritory.pointsExcluded, pointKey)) then continue end 
		if (!table.HasValue(self.boundaryCheckedPoints, pointPos)) then
			self:AddTerritoryToBoundary(thisBoundary, pointTerritory, pointKey)
		else
			print("already added, disregard: "..pointTerritory.index..":"..pointKey)
		end
	end

	print("total num: "..#self.boundaries)
	print("====================END")

	if (self.testEnts) then
		for k, v in pairs(self.testEnts) do
			v:Remove()
			v = nil
		end
	end
	self.testEnts = {}
	for k, v in pairs(self.boundaries) do
		for _, point in pairs(v) do
			local ent = ents.Create("prop_physics")
			ent:SetModel("models/mrgiggles/sassilization/wall.mdl")
			ent:SetPos(point[1])
			ent:Spawn()
			ent:GetPhysicsObject():EnableMotion(false)
			table.insert(self.testEnts, ent)
		end
	end

	/*while (true) do
		
		local terr = nextTerritory or self.stored[terrID]
		if (nextTerritory) then
			print("Continuing a border from terrID: "..terr.index.." & total: "..numberCalculated.."/"..#pointTable)
		end
		nextTerritory = nil
		if (!terr) then
			print("No territory")
			break
		end
		print("Workin that territory swag")

		local points = terr.points
		local thisPoint = 1
		--for kp, point in pairs(points) do
		for i = 1, #points do

			if (nextTerritory) then continue end
			if (nextTerritoryPoint) then
				thisPoint = nextTerritoryPoint
				nextTerritoryPoint = nil
				print("continuging @ "..terr.index.." from p "..thisPoint)
				continue
			end

			local point = points[thisPoint]
			local nextPoint = thisPoint + 1
			if (thisPoint == #points) then
				nextPoint = 1
			end

			if (!table.HasValue(checkedPoints, point)) then 
				if (thisBoundary[1] and points[nextPoint] == thisBoundary[1][1]) then
					table.insert(calculated, thisBoundary)
					numberCalculated = numberCalculated + #thisBoundary + 1 //we add one because we don't really connect the ending points.
					print("New boundary created, points: ", #thisBoundary+1, numberCalculated, pointCount)
					if (#checkedPoints >= pointCount) then print("we'redone", numberCalculated, pointCount) break end
					thisBoundary = {}
					nextTerritory = self.stored[terr.index+1]
					continue
				else
					if (points[nextPoint] and !table.HasValue(terr.pointsExcluded, nextPoint)) then
						table.insert(thisBoundary, {point, territory})
						table.insert(checkedPoints, point)
						print("point: ", thisPoint, "@", terr.index)
					else
						local nearestPoint = nil
						local nearestDistance = math.huge
						for checkPointK, checkPoint in pairs(pointTable) do
							local dist = point:Distance(checkPoint[1])
							if (checkPoint[2] != terr and dist <= nearestDistance) then
								nearestPoint = checkPoint
								nearestDistance = dist
							end
						end
						

						if (nearestPoint) then
							print("npoint", nearestPoint[1], nearestPoint[2].index)
							nextTerritory = nearestPoint[2]
							nextTerritoryPoint = nearestPoint[3]
							table.insert(thisBoundary, {nearestPoint[1], nextTerritory})
							table.insert(checkedPoints, nearestPoint[1])
						else
							error("No nearest point...")
							
						end
					end
				end
			end
			thisPoint = nextPoint
		end
		terrID = terrID + 1
	end*/
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
