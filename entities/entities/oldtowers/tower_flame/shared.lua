
ENT.Base = "base_tower"
ENT.Type = "anim"
ENT.PrintName = "Flame Tower"

ENT.AutomaticFrameAdvance = true

if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	
	function ENT:SetupInfo( tower, lvl )
		tower.UpgradeName = "t_fire"
		tower.MaxLvl = 3
		
		tower.Delay = 4
		tower.Damage = 30
		tower.ShootNum = 1
		tower.IgniteOnHit = true
		tower.IgniteTime = 5
		tower.IgniteDamage = 35
		
		tower.MuzzleFlash = "MuzzleEffect"
		
		tower.Snd = Sound( "weapons/pistol/pistol_fire2.wav" )
		tower.Range = 256
		//tower.Model = "models/props_combine/breenglobe.mdl"
		//tower.Color = Color( 128, 255, 255 )
		tower.Model = "models/GMODTD/flametower/flametower.mdl"
		tower.Color = color_white
		tower.Animation = "rotation"
		tower.AnimationSpeed = 0
		if (lvl == 2) then
			tower.Delay = 3.5
			tower.Damage = 40
			tower.IgniteTime = 6
			tower.IgniteDamage = 50
			tower.AnimationSpeed = 1
		end
		if (lvl == 3) then
			tower.Delay = 2.5
			tower.Damage = 50
			tower.IgniteTime = 7
			tower.IgniteDamage = 65
			tower.AnimationSpeed = 2
		end
	end

end