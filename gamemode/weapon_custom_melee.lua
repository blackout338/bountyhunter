--Custom Weapon

SWEP.Author                = "RightBehindu"
SWEP.Base                  = "weapon_base"
SWEP.PrintName             = "Custom Crowbar"
SWEP.Instructions          = [[Left-Click: Hit a player.
                               Right-Click: Does nothing.]]

SWEP.ViewModel              = "models/weapons/c_crowbar.mdl"
SWEP.ViewModelFlip          = false
SWEP.WorldModel             = "models/weapons/w_crowbar.mdl"
SWEP.UseHands               = true
SWEP.SetHoldType            = "melee"

SWEP.Weight                 = 5
SWEP.AutoSwitchTo           = true
SWEP.AutoSwitchFrom         = false

SWEP.Slot                   = 1
SWEP.SlotPos                = 0

SWEP.DrawCrosshair          = false
SWEP.DrawAmmo               = false

SWEP.Spawnable              = true
SWEP.AdminSpawnable         = true

SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Ammo           = "none"
SWEP.Primary.Automatic      = false


SWEP.Primary.Spread         = 0
SWEP.Primary.Cone           = 0
SWEP.Primary.Delay          = 1

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Ammo         = "none"
SWEP.Secondary.Automatic    = false

local SwingSound = Sound("Weapon_Crowbar.Single")
local HitSound = Sound("Weapon_Crowbar.Melee_Hit")

function SWEP:Initialize()
	self:SetWeaponHoldType( "melee" )
end

function SWEP:PrimaryArrack()
	if( CLIENT ) then return end
	
	local ply = self:GetOwner()
	ply:LagCompensation(true)
	
	local hitPosition = ply:GetShootPos()
	--Controls range of weapon (70 units)
	local endHitPostition = hitPosition + ply:GetAimVecotor() * 70
	local tmin = Vector( 1, 1, 1) * -10
	local tmin = Vector( 1, 1, 1) * 10
	
	local tr = util.TraceHull( {
		start = hitPostition,
		endpos = endHitPosition,
		filter = ply,
		mask = MASK_SHOT_HULL,
		mins = tmin,
		maxs = tmax
	} )
	if( not IsValid(tr.Entity) ) then
		tr = util.TraceLine( {
			start = hitPosition,
			endpos = endHitPosition,
			filter = ply,
			mask = MASK_SHOT_HULL
		})
	end
	
	local ent = tr.Entity
	if ( IsValid(ent) && (ent:IsPlayer() || ent:IsNpc()) ) then 
		self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
		ply:SetAnimation( PLAYER_ATTACK1 )
		
		ply:EmitSound(HitSound)
		ent:SetHealth( ent:Health() - 25 )
		if(ent:Health() < 1) then
			ent:Kill()
		end
	elseif( !IsValid( ent ) ) then
		self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
		ply:SetAnimation( PLAYER_ATTACK1 )
		
		ply:EmitSound(SwingSound)
	end
	ply:LagCompensation(false)
end

function SWEP:DampenDrop()
   -- For some reason gmod drops guns on death at a speed of 400 units, which
   -- catapults them away from the body. Here we want people to actually be able
   -- to find a given corpse's weapon, so we override the velocity here and call
   -- this when dropping guns on death.
   local phys = self:GetPhysicsObject()
   if IsValid(phys) then
      phys:SetVelocityInstantaneous(Vector(0,0,-75) + phys:GetVelocity() * 0.001)
      phys:AddAngleVelocity(phys:GetAngleVelocity() * -0.99)
   end
end