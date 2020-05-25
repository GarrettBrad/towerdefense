
include( "shared.lua" )
 
SWEP.PrintName		= "Tower Defense Build Tool"
SWEP.Slot			= 0
SWEP.SlotPos		= 1
SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= false

function SWEP:PrimaryAttack()

end

function SWEP:SecondaryAttack()

end

function SWEP:Reload()
	
end

local color_green = Color( 0, 255, 0 )
local color_red = Color( 255, 0, 0 )
local color_blue = Color( 50, 50, 255 )
local circle_size = 192
local offseta = Angle( 90, 0, 0 )

local matCircle = surface.GetTextureID( "gui/td/aimer_circle" )
local matSquare = surface.GetTextureID( "gui/td/aimer_square" )

local offset = Vector( 0, 0, 0 )
function SWEP:DrawAimer()
	cam.Start3D( EyePos(), EyeAngles() )
	local pos, norm, ent = self:GetTargetInfo()
	local valid = self:TargetLocationValid( pos, norm )
	local col = color_red
	if (valid) then col = color_green end
	local TowerFocus = (self.DrawEnt && self.DrawEnt:IsValid() && (self.DrawEnt.Base == "base_tower"))
	local size = circle_size
	offset.x = 0; offset.y = 0; offset.z = 0;
	if (TowerFocus) then
		col = color_blue
		size = circle_size * 3
		local height = (self.DrawEnt:OBBMaxs() - self.DrawEnt:OBBMins()).z
		offset.z = ((math.sin( CurTime() ) + 1) * 0.4 * height) + (height*0.1)
	end
	cam.Start3D2D( pos + norm + offset, norm:Angle() + offseta, 0.05 )
		surface.SetDrawColor( col )
		surface.SetTexture( matCircle )
		surface.DrawTexturedRect( size*-0.5, size*-0.5, size, size, 0 )
	cam.End3D2D()
	self.DrawEnt = ent
	cam.End3D()
end

local function DrawAimer()
	local wep = LocalPlayer():GetActiveWeapon()
	if (wep && wep:IsValid() && wep.DrawAimer) then wep:DrawAimer() end
end
hook.Add( "RenderScreenspaceEffects", "DrawAimer", DrawAimer )

local function InScreen( x, y )
	return (x > 0) && (x < ScrW()) && (y > 0) && (y < ScrH())
end

local info = {}
function SWEP:DrawHUD()
	local ent = self.DrawEnt
	if (ent && ent:IsValid() && (ent.Base == "base_tower")) then
		// Name
		info[1] = ent.PrintName
		local lvl = ent:GetNWInt( "lvl" )
		
		// Level
		info[2] = "Level " .. tostring( lvl )
		local owner = ent:GetNWEntity( "owner" )
		
		// Owner
		info[3] = "Unowned"
		if (owner && owner:IsValid() && owner:IsPlayer()) then info[3] = owner:Nick() end
		
		// Upgrade
		info[4] = nil
		local name = ent:GetClass()
		local tab = GAMEMODE:GetTowerTable( name )
		if (tab) then
			local cost = tab[3][lvl+1]
			if (cost) then
				info[4] = "Upgrade Cost: " .. tostring( cost )
			end
		end
		
		local pos = ent:GetPos():ToScreen()
		local x, y = pos.x, pos.y
		GAMEMODE:DrawInfoLabel( x, y, info, 4, "ScoreboardText", colTransBlue, color_white )
		
		/*local circ, cnt = math.Circle(), 0
		local prev = (circ[36] * 256) + ent:GetPos()
		surface.SetDrawColor( 0, 255, 0, 128 )
		for cnt=1, 36 do
			local cur = (circ[cnt] * 256) + ent:GetPos()
			local P = prev:ToScreen()
			local x1, y1 = P.x, P.y
			local C = cur:ToScreen()
			local x2, y2 = C.x, C.y
			if InScreen( x1, y1 ) || InScreen( x2, y2 ) then surface.DrawLine( x1, y1, x2, y2 ) end
			prev = cur
		end*/
		
	end
end