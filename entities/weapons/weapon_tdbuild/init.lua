
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
	local pos, norm, ent = self:GetTargetInfo()
	local valid = self:TargetLocationValid( pos, norm )
	local ply = self.Owner
	ply.TowerName = ply.TowerName or "tower_pistol"
	local name = ply.TowerName
	local tab = GAMEMODE:GetTowerTable( name )
	local cost = (tab[3][1] or 0) / 2
	if (ent && ent:IsValid() && (ent:GetClass() != "prop_physics")) then
		if (ent.IsTower) then
			self:AttemptUpgrade( ent )
		else
			self.Owner:ChatPrint( "You cannot build here!" )
		end
		return
	end
	if (!valid) then return end
	if (!tab) then
		ply:ChatPrint( "Invalid tower!" )
		return
	end
	local up = tab[5] or ""
	local upl = tab[6] or 0
	if (!game.SinglePlayer()) then
		if (!ply:HasUpgrade( up, upl )) then
			ply:ChatPrint( "You may not build that tower!" )
			return
		end
	end
	local cost = tab[3][1] or 0
	local nice = tab[2]
	if (!ply:HasMoney( cost )) then
		ply:ChatPrint( "You cannot afford that!" )
		return
	end
	local ent = GAMEMODE:SpawnTower( name, pos, norm, ply )
	ent.TotalValue = cost
	ply:TakeMoney( cost )
end

function SWEP:AttemptUpgrade( ent )
	local ply = self.Owner
	if (ent.Owner && ent.Owner:IsValid() && (ent.Owner != ply)) then
		ply:ChatPrint( "You do not own that tower!" )
		return
	end
	local name = ent:GetClass()
	local tab = GAMEMODE:GetTowerTable( name )
	if (!tab) then
		ply:ChatPrint( "Invalid tower!" )
		return
	end
	if (!ent:CanUpgrade()) then
		ply:ChatPrint( "This cannot be upgraded further!" )
		return
	end
	if (!ent.Tower.UpgradeName) then
		ply:ChatPrint( "That tower cannot be upgraded!" )
		return
	end
	local reqlvl = ent:GetLevel() + (tab[6] or 0)
	if (!game.SinglePlayer()) then
		if (!ply:HasUpgrade( ent.Tower.UpgradeName, reqlvl )) then
			ply:ChatPrint( "You must buy that upgrade from the lobby!" )
			return
		end
	end
	local curlvl = ent:GetLevel()
	local cost = tab[3][ curlvl + 1 ]
	if (!cost) then
		ply:ChatPrint( "This cannot be upgraded further!" )
		return
	end
	if (!ply:HasMoney( cost )) then
		ply:ChatPrint( "You cannot afford to upgrade that!" )
		return
	end
	ent:Upgrade()
	ent.TotalValue = ent.TotalValue + cost
	ply:TakeMoney( cost )
	ply:ChatPrint( "Tower upgraded to level " .. ent:GetLevel() .. "!" )
end

function SWEP:SecondaryAttack()
	local pos, norm, ent = self:GetTargetInfo()
	if (ent && ent:IsValid() && ent.IsTower) then
		if (ent.Owner && ent.Owner:IsValid() && ent.Owner:IsPlayer() && (ent.Owner != self.Owner)) then
			self.Owner:ChatPrint( "You do not own that!" )
		else
			local cost = ent.TotalValue * (td_ai.GetTowerSellBackValue() or 1)
			ent:Remove()
			self.Owner:GiveMoney( cost )
			self.Owner:ChatPrint( "Tower sold for " .. cost .. "!" )
			if (!self.Owner.TowerCount) then self.Owner.TowerCount = 0 end
			if (ent.Owner == self.Owner) then
				self.Owner.TowerCount = self.Owner.TowerCount - 1
				self.Owner:SetNWInt( "td_tcnt", self.Owner.TowerCount )
			end
		end
	else
		self.Owner:ChatPrint( "You may not remove that!" )
	end
end

function SWEP:Reload()
local pos, norm, ent = self:GetTargetInfo()
	if (ent && ent:IsValid() && (ent:GetClass() != "prop_physics")) then
		if (ent.IsTower) then
			ent.Ammo = ent.MaxAmmo
			ent:SetNWInt( "Ammo", ent.MaxAmmo )
		end
		return
	end
end