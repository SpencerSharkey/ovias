
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )
 
SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

function SWEP:Initialize()
	self:SetWeaponHoldType( "normal" )
end

function SWEP:Deploy()
	self.Owner:DrawWorldModel( false )
end

function SWEP:PrimaryAttack()
	
end

function SWEP:SecondaryAttack()
	
end

function SWEP:Reload()

end