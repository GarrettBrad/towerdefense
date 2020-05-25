
ENT.Base = "base_tower"
ENT.Type = "anim"
ENT.PrintName = "SMG Tower"

ENT.AutomaticFrameAdvance = true

if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	
	function ENT:SetupInfo( tower, lvl )
		tower.UpgradeName = "t_smg"
		tower.MaxLvl = 3
		tower.Delay = 0.2
		tower.Damage = 10
		tower.ShootNum = 1
		tower.Effect = "AR2Tracer"
		tower.MuzzleFlash = "MuzzleEffect"
		tower.Accuracy = 0.06
		tower.Health = 50
		tower.Cost = 25
		tower.Snd = Sound( "weapons/smg1/smg1_fire1.wav" )
		tower.Range = 256
		//tower.Model = "models/props_combine/breenglobe.mdl"
		//tower.Color = Color( 255, 128, 128 )
		tower.Model = "models/GMODTD/smgtower/smgtower.mdl"
		tower.Color = color_white
		tower.Animation = "rotation"
		tower.AnimationSpeed = 0
		if (lvl == 2) then
			tower.Damage = 14
			tower.Accuracy = 0.05
			tower.AnimationSpeed = 1
		end
		if (lvl == 3) then
			tower.Damage = 18
			tower.Accuracy = 0.04
			tower.Delay = 0.15
			tower.AnimationSpeed = 2
		end
	end

end