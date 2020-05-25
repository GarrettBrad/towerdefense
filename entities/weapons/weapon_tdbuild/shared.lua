
SWEP.Author				= "thomasfn"
SWEP.Contact			= ""
SWEP.Purpose			= ""
SWEP.Instructions		= "Left Click: Build/Upgrade tower\nRight Click: Remove tower"
 
SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false
 
SWEP.ViewModel			= "models/weapons/v_hands.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"
 
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"
 
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.GridSnap				= 8
SWEP.MinimumTowerDistance	= 24

function SWEP:GetCastlePos()
    return GetGlobalVector( "castle_pos" )
end


local mins = Vector( 0, 0, 0 )
local maxs = Vector( 0, 0, 0 )
function SWEP:TargetLocationValid( pos, norm )
	local norma = norm:Angle()
	local z = self:GetCastlePos().z
	if (pos.z < (z+8)) then return false end
	if not ((norma.p > 240) && (norma.p < 300)) then return false end
	local MinDist = self.MinimumTowerDistance
	mins.x = pos.x-(MinDist/2); mins.y = pos.y-(MinDist/2); mins.z = pos.z-(MinDist/2);
	maxs.x = pos.x+(MinDist/2); maxs.y = pos.y+(MinDist/2); maxs.z = pos.z+(MinDist/2);
	local elst = ents.FindInBox( mins, maxs )
	for _, ent in pairs( elst ) do
		if (ent.Base == "base_tower") then return false end
	end
	return true
end

function math.RoundToNumber( a, b )
	return math.Round( a/b ) * b
end

function math.RoundVecToNumber( a, b )
	a.x = math.RoundToNumber( a.x, b )
	a.y = math.RoundToNumber( a.y, b )
	a.z = math.RoundToNumber( a.z, b )
	return a
end

local up = Vector( 0, 0, 1 )
function SWEP:GetTargetInfo()
	local tr = self.Owner:GetEyeTrace()
	local pos = tr.HitPos
	local norm = tr.HitNormal
	local valid = self:TargetLocationValid( pos, norm )
	if (tr.Entity && tr.Entity:IsValid()) then
		if (tr.Entity.IsTower) then
			valid = true
			pos = tr.Entity:GetPos()
			norm =  Vector( 0, 0, 1 )
		else
			valid = false
		end
	end
	
	return math.RoundVecToNumber( pos, self.GridSnap ), norm, tr.Entity
end