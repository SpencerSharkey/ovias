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
		for tid, territory in pairs(SF.Territory.stored) do
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


	for _, tid in pairs(self.recheckQueue) do
		local territory = SF.Territory.stored[tid]
		for k, point in pairs(territory.points) do
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

	SF.Territory:CalculateBoundaries()
end

function SF.Territory:CalculateBoundaires()
	local calculated = {}
	local function checkUncalculated()
		for kTerritory, territory in pairs(self.stored) do
			calculated[kTerritory] = {}
			for _, kPoint in pairs(territory.pointsIncluded) do
				if (!table.HasValue(calculated[kTerritory], kPoint)) then
					return kTerritory, kPoint
					break
				end
			end
		end
		return false
	end

	while (checkUncalculated() != false) do
		local boundary = {}
		local startTerritory, startPoint = checkUncaculated()
		local iCheck = startPoint
		while (startTerritory.pointsIncluded[iCheck]) do
			
			table.insert(boundary, {startTerritory, iCheck})

			if (!startTerritory.pointsIncluded[iCheck+1]) then
				break --Just an early warning <3
			end
			iCheck = iCheck + 1
		end
		break; --REMOVE THIS

	end

end

concommand.Add("tt", function(ply, cmd, args)
	local sys = SysTime()
	local tr = ply:GetEyeTraceNoCursor()
	local t = SF.Territory:Create(1, tr.HitPos, 128)
	t:Calculate()

	print("Time Elapsed: ", SysTime()-sys)
	SF.FrameFunc:Create(1, function()
		print("Last Frame:", FrameTime())
	end)
end)

SF:RegisterClass("svTerritory", SF.Territory) 