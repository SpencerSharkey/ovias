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


	for _, tid in next, self.recheckQueueF do
		local territory = SF.Territory.stored[tid]
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
	self:Network()
    
    --this is a failure and it's wasted computation but we'll make ti work eventually 
	SF.Territory:CalculateBoundaries()
end

function SF.Territory:_checkUncalculated(calculated)
	for kTerritory, territory in next, self.stored do
		calculated[kTerritory] = {}
		for _, kPoint in next, territory.pointsIncluded do
			if (!table.HasValue(calculated[kTerritory], kPoint)) then
				return kTerritory, kPoint
			end
		end
	end
	return false
end

function SF.Territory:CalculateBoundaries()
	local calculated = {}

	while (self:_checkUncalculated(calculated) != false) do
		local boundary = {}
		local startTerritory_i, startPoint = self:_checkUncalculated(calculated)
		local startTerritory = self.stored[startTerritory_i]
		local iCheck = startPoint
		while (startTerritory.pointsIncluded[iCheck]) do
			
			table.insert(boundary, {startTerritory_i, iCheck})

			if (!startTerritory.pointsIncluded[iCheck+1]) then
				break --Just an early warning <3
			end
			iCheck = iCheck + 1
		end
		table.insert(self.boundaries, boundary)
		break; --REMOVE THIS
	end

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
