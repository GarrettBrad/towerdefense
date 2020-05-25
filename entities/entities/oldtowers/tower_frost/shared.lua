
ENT.Base = "base_tower"
ENT.Type = "anim"
ENT.PrintName = "Frost Tower"

ENT.AutomaticFrameAdvance = true

if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	
	function ENT:SetupInfo( tower, lvl )
		tower.UpgradeName = "t_ice"
		tower.MaxLvl = 3
		
		tower.Delay = 4
		tower.Damage = 30
		tower.ShootNum = 1
		tower.SlowOnHit = true
		tower.SlowTime = 2
		tower.SlowDamage = 40
		
		tower.MuzzleFlash = "MuzzleEffect"
		
		tower.Snd = Sound( "weapons/pistol/pistol_fire2.wav" )
		tower.Range = 256
		//tower.Model = "models/props_combine/breenglobe.mdl"
		//tower.Color = Color( 128, 255, 255 )
		tower.Model = "models/GMODTD/icetower/icetower.mdl"
		tower.Color = color_white
		tower.Animation = "rotation"
		tower.AnimationSpeed = 0
		if (lvl == 2) then
			tower.Delay = 3.5
			tower.Damage = 45
			tower.SlowTime = 3
			tower.SlowDamage = 45
			tower.AnimationSpeed = 1
		end
		if (lvl == 3) then
			tower.Delay = 2.5
			tower.Damage = 60
			tower.SlowTime = 4
			tower.SlowDamage = 50
			tower.AnimationSpeed = 2
		end
	end

end