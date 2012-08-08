if (CLIENT) then
	function MPosAimVec(iScreenX,iScreenY,iScreenW,iScreenH,aCamRot,fFoV)
	    local fHalfWidth = iScreenW*0.5;
	    local fHalfHeight = iScreenH*0.5;
	    local d = fHalfWidth/math.tan(fFoV*0.5);
	 
	    local vForward=aCamRot:Forward();
	    local vRight=aCamRot:Right();
	    local vUp=aCamRot:Up();
	 
	    return (vForward*d + vRight*(iScreenX-fHalfWidth) + vUp*(fHalfHeight-iScreenY)):GetNormal();
	end

	function _R.Player:GetEyeTrace()

		local vAngles = self.ov_ViewAngles
		local vOrigin = self.ov_ViewOrigin
		//print(vAngles, vOrigin)
		local trace = {}
		local mposx = gui.MouseX()
		local mposy = gui.MouseY()
		local sw = ScrW()
		local sh = ScrH()
		local fov = 90
		local ratio = sw/sh

		local fovFix = (math.atan(math.tan((fov * math.pi) / 360) * (ratio / (4/3) )) * 360) / math.pi
		trace.start = vOrigin
		trace.endpos = trace.start + MPosAimVec(mposx, mposy, sw, sh, vAngles, math.rad(fovFix))*5000
		trace.filter = self.ovCamera
		local tr = util.TraceLine(trace)
		return tr
	end
end
