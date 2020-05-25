
ENT.Base = "base_tower"
ENT.Type = "anim"
ENT.PrintName = "Sniper Tower"

ENT.AutomaticFrameAdvance = true

if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	
	function ENT:SetupInfo( tower, lvl )
		tower.UpgradeName = "t_snip"
		tower.MaxLvl = 3
		tower.Delay = 5
		tower.Damage = 200
		tower.ShootNum = 1
		tower.Effect = "AR2Tracer"
		tower.MuzzleFlash = "MuzzleEffect"
		tower.Accuracy = 0.0001
		tower.Health = 50
		tower.Cost = 120
		tower.Snd = Sound( "weapons/scout/scout_fire-1.wav" )
		tower.Range = 768
		//tower.Model = "models/props_combine/breenglobe.mdl"
		//tower.Color = Color( 255, 100, 255 )
		tower.Model = "models/GMODTD/snipertower/snipertower.mdl"
		tower.Color = color_white
		tower.Animation = "rotation"
		tower.AnimationSpeed = 0
		if (lvl == 2) then
			tower.Delay = 4
			tower.Damage = 250
			tower.AnimationSpeed = 1
		end
		if (lvl == 3) then
			tower.Delay = 2
			tower.Damage = 300
			tower.AnimationSpeed = 2
		end
	end

end