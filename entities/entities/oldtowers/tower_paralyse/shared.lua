
ENT.Base = "base_tower"
ENT.Type = "anim"
ENT.PrintName = "Paralysis Tower"

ENT.AutomaticFrameAdvance = true

if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	
	function ENT:SetupInfo( tower, lvl )
		tower.UpgradeName = "t_slow"
		tower.MaxLvl = 3
		tower.Delay = 5
		tower.Damage = 0
		tower.ShootNum = 1
		tower.Effect = "AR2Tracer"
		tower.MuzzleFlash = "MuzzleEffect"
		tower.Accuracy = 0.04
		tower.Health = 50
		tower.Cost = 15
		tower.Snd = Sound( "weapons/357_fire2.wav" )
		tower.Range = 128
		//tower.Model = "models/props_combine/breenglobe.mdl"
		//tower.Color = Color( 255, 255, 64 )
		tower.Model = "models/GMODTD/para/para.mdl"
		tower.Color = color_white
		tower.FreezeOnHit = true
		tower.FreezeTime = 2
		tower.NoTargetFrozen = true
		tower.Animation = "rotation"
		tower.AnimationSpeed = 0
		if (lvl == 2) then
			tower.Delay = 4
			tower.FreezeTime = 3
			tower.AnimationSpeed = 1
		end
		if (lvl == 3) then
			tower.Delay = 3
			tower.FreezeTime = 4
			tower.AnimationSpeed = 2
		end
	end

end