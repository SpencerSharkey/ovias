--[[
    Ovias
	Copyright © Slidefuse LLC - 2012
--]]

--A dummy material for our meshes
local mInside = CreateMaterial("innerMaterial", "UnlitGeneric", {
    ["$alpha"] = "0"
})

--A material for our ring. Let it accept color/alpha
local mRing = CreateMaterial( "ringMaterial1", "UnlitGeneric", {
    ["$basetexture"] = "color/white",
    ["$vertexalpha"] = "1",
    ["$vertexcolor"] = "1",
    ["$alpha"] = "0.5"
})


function SF.Territory:PostDrawOpaqueRenderables()
	if (!SF.Client:HasInitialized()) then return end 

	--Loop through our territories and make sure our meshes are setup.
	--We only need to calculate the mesh ones per territory, per-frame would be useless and slow.
	for k, v in next, self.stored do
		if (!v.drawCache) then
			v:CreateDrawCache()
		end
	end

	--Index our faction color
	local col = SF.Client:GetFaction():GetColor()

	--Do our cam in a protected call so errors don't fuck up our scene (ex: http://4stor.com/BzRlY)
	pcall(function() 
		--Start a cam, duh.
		cam.Start3D(EyePos(), EyeAngles())
			--[[
				Territory stencils 101
					>Draw the outer boundary (the bigger one) to our stencil buffer
					>Set the pixel reference value to 2, then draw the smaller one
					>Use stencils to find the pixels that weren't drawn over by the smaller boundary
					>Fill those pixels with a solid color to represent a boundary outline!
			--]]
			render.ClearStencil()
			render.SetStencilEnable(true)
			
			render.SetStencilCompareFunction(STENCIL_ALWAYS) -- For our first draw, we want to always replace pixel reference values with our new ID
			render.SetStencilPassOperation(STENCIL_REPLACE) -- Set all the pixels drawn to our new reference value so long as it passes
			render.SetStencilFailOperation(STENCIL_KEEP) -- Keep failed pixels (that aren't within our newly drawn shit)
			render.SetStencilZFailOperation(STENCIL_KEEP) -- We want to maintain the depth, so we don't overwrite pixels that we can't "see" (walls)			
			
			render.SetStencilReferenceValue(1) --Set our pixel reference value to 1

			render.SetMaterial(mInside) --Set our material to our invisible but still valid material

			--Draw the bigger one first on the reference value of 1
			for k, v in next, self.stored do 
				v.meshOutline:Draw()
			end

			render.SetStencilZFailOperation(STENCIL_REPLACE) -- We don't want to see our boundaries through walls.
			render.SetStencilReferenceValue(2) -- Set our smaller mesh to a reference value of 2

			--Draw the smaller meshes
			for k, v in next, self.stored do
				v.meshOutlineInside:Draw()
			end
			render.SetStencilCompareFunction(STENCIL_EQUAL)
			render.SetStencilReferenceValue(1)
			--The above two lines say "for all the pixels of a reference value of 1, do this:"

			mRing:SetVector("$color", Vector(col.r/255, col.g/255, col.b/255)) --Set the materials color to reflect our faction color
			render.SetMaterial(mRing) 
			render.DrawScreenQuad()--Draw a material filling the above pixels


			render.SetStencilEnable(false) --Stop using stencils
		cam.End3D()
		--Cleanup
	end)
end

function SF.Territory.metaClass:CreateDrawCache()
	--Setup tables for two of our meshes
	local meshOutline = {}
	local meshOutlineInside = {}
	--Standard normal
	local norm = Vector(0, 0, 1)

	for k, point in next, self.points do
		local nextK = ((k) % (#self.points)) + 1
		//local nextK = k % #self.points

		--Localize our points, we go up 2 units because we don't want z-fighting (floating points suck)
		local point = point + Vector(0, 0, 2)
		local nextPoint = self.points[nextK] + Vector(0, 0, 2)

		--Setup our outer mesh (http://4stor.com/wgv3i)
		table.insert(meshOutline, {pos = nextPoint, normal = norm})
		table.insert(meshOutline, {pos = self.position, normal = norm})
		table.insert(meshOutline, {pos = point, normal = norm})

		--Localize our inside points. We find the angle of each point realative to the centerpoint of the teritory and simply move it back.
		local innerPoint = (point-self.position):Angle():Forward()*-2 + point
		local innerNextPoint = (nextPoint-self.position):Angle():Forward()*-2 + nextPoint

		--Setup our inner mesh
		table.insert(meshOutlineInside, {pos = innerNextPoint, normal = norm})
		table.insert(meshOutlineInside, {pos = self.position, normal = norm})
		table.insert(meshOutlineInside, {pos = innerPoint, normal = norm})
	end

	--Create mesh objects and build them. Should be fast.
	self.meshOutline = Mesh()
	self.meshOutline:BuildFromTriangles(meshOutline)

	self.meshOutlineInside = Mesh()
	self.meshOutlineInside:BuildFromTriangles(meshOutlineInside)

	--We're done here.
	self.drawCache = true
end

--Network hooks
netstream.Hook("territoryRemove", function(data)
	SF.Territory.stored[data]:Remove()
end)

netstream.Hook("territoryStream", function(data)
	if (!SF.Territory.stored[data.index]) then
		local t = SF.Territory:CreateRaw()
		t:LoadNetworkTable(data)
		SF.Territory.stored[data.index] = t
	else
		local t = SF.Territory.stored[data.index]
		t:LoadNetworkTable(data)
	end
end)


SF:RegisterClass("clTerritory", SF.Territory)