
ENT.Base = "base_tower"
ENT.Type = "anim"
ENT.PrintName = "Pistol Tower"

ENT.AutomaticFrameAdvance = true

if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	
	function ENT:SetupInfo( tower, lvl )
		tower.UpgradeName = "t_pist"
		tower.MaxLvl = 3
		tower.Delay = 2
		tower.Damage = 30
		tower.ShootNum = 1
		tower.Effect = "AR2Tracer"
		tower.MuzzleFlash = "MuzzleEffect"
		tower.Accuracy = 0.04
		tower.Health = 50
		tower.Cost = 10
		tower.Snd = Sound( "weapons/pistol/pistol_fire2.wav" )
		tower.Range = 128
		// tower.Model = "models/props_combine/breenglobe.mdl"
		// tower.Color = Color( 128, 255, 128 )
		tower.Model = "models/GMODTD/pistoltower/pistoltower.mdl"
		tower.Color = color_white
		tower.Animation = "rotation"
		tower.AnimationSpeed = 0
		if (lvl == 2) then
			tower.Delay = 0.9
			tower.Damage = 35
			tower.AnimationSpeed = 1
		end
		if (lvl == 3) then
			tower.Delay = 0.8
			tower.Damage = 40
			tower.AnimationSpeed = 2
		end
	end

end