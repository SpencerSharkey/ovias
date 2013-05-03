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

	for i = 0, math.pi*2, s do
		local vOffset = Vector(math.cos(i), math.sin(i), 0)
		local length = 0
		local tr = SF.Util:SimpleTrace(org, org + vOffset*self.radius)     
		local prevHit = position
        
		while true do
            
			local newHit
			local tt = SF.Util:SimpleTrace(prevHit, prevHit + vOffset*skipDistance)

			if (!tt) then
				newHit = prevHit + vOffset*skipDistance
				local dt = SF.Util:SimpleTrace(newHit, newHit + vDown*15)
				if (!dt) then
					print(index, "Terminated on a Cliff or Edge")
					self.points[index] = newHit
					break;
				else
					newHit = dt.HitPos
				end
                
			else
                local testLength = 0
                local ut
                
                while true do
                    ut = SF.Util:SimpleTrace(prevHit + vUp*5, prevHit + vUp*5 + vOffset*100)
                    if (ut.Fraction <= 0.1) then
                        newHit = ut.HitPos
           			else
                        self.points[index] = prevHit
                        break;
                    end
                end
                
				if (ut) then
					newHit = ut.HitPos
				else
					print(index, "Terminated on a Wall")
					self.points[index] = prevHit
					break
				end
			end

			length = length + prevHit:Distance(newHit)
			
			if (length >= self.radius) then
				print(index, "Terminated Regularly")
				self.points[index] = prevHit
				break
			end

			prevHit = newHit
		end
		index = index + 1
	end
end

concommand.Add("tt", function(ply, cmd, args)
	local tr = ply:GetEyeTraceNoCursor()
	local t = SF.Territory:Create(1, tr.HitPos, 128)
	t:Calculate()

	t:Network()

end)

SF:RegisterClass("svTerritory", SF.Territory) 