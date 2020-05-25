
ENT.Base = "base_tower"
ENT.Type = "anim"
ENT.PrintName = "Shotgun Tower"

ENT.AutomaticFrameAdvance = true

if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	
	function ENT:SetupInfo( tower, lvl )
		tower.UpgradeName = "t_shot"
		tower.MaxLvl = 3
		tower.Delay = 3
		tower.Damage = 30
		tower.ShootNum = 6
		tower.Effect = "AR2Tracer"
		tower.MuzzleFlash = "MuzzleEffect"
		tower.Accuracy = 0.12
		tower.Health = 50
		tower.Cost = 40
		tower.Snd = Sound( "weapons/shotgun/shotgun_fire7.wav" )
		tower.Range = 128
		//tower.Model = "models/props_combine/breenglobe.mdl"
		//tower.Color = Color( 128, 128, 255 )
		tower.Model = "models/GMODTD/shotguntower/shotguntower.mdl"
		tower.Color = color_white
		tower.Animation = "rotation"
		tower.AnimationSpeed = 0
		if (lvl == 2) then
			tower.ShootNum = 8
			tower.Delay = 2
			tower.Damage = 30
			tower.AnimationSpeed = 1
		end
		if (lvl == 3) then
			tower.ShootNum = 10
			tower.Delay = 1.5
			tower.Damage = 30
			tower.AnimationSpeed = 2
		end
	end

end