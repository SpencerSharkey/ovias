--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]


SF.HudTips = {}

local mBuild = Material("ovias/build01.png")
function SF.HudTips:HUDPaint()

	/*
	--This isn't bad... just... idk. Not feeln it..
	render.PushFilterMin(2)
	render.PushFilterMag(2)
	for _, ent in pairs(ents.FindByClass("building_*")) do
		if (ent.isBuilding) then
			surface.SetMaterial(mBuild)
			local epos = ent:GetPos() + Vector(0, 0, ent.modelMaxs.z)
			local pos = epos:ToScreen()
			local rpos = {x = pos.x-32, y = pos.y-32}

			surface.SetDrawColor(Color(255, 255, 255))
			surface.DrawTexturedRect(rpos.x, rpos.y, 64, 64)

			local height = (ent.buildProgress/100)*64
			print(height)

			render.SetScissorRect(rpos.x, rpos.y+(64-(height)), rpos.x+64, rpos.y+(64-(height))+64, true)
				surface.SetDrawColor(Color(0, 255, 0))
				surface.DrawTexturedRect(rpos.x, rpos.y, 64, 64)
			render.SetScissorRect(rpos.x, rpos.y+(64-(height)), rpos.x+64, rpos.y+(64-(height))+64, false)
		end
		if (ent.isBuilt) then
			if (!ent.hasChecked) then
				
			end
		end
	end
	render.PopFilterMin()
	render.PopFilterMag()
	*/
end

SF:RegisterClass("clHudTips", SF.HudTips)