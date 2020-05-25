
ENT.Base = "base_monster"
ENT.Type = "anim"

ENT.NoPitch = true -- Needed for clientside prediction
ENT.AutomaticFrameAdvance = true

if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	
	function ENT:SetupInfo( monster, lvl )
		monster.Speed = 8
		monster.Health = 300
		monster.Damage = 10
		monster.Model = "models/Combine_Soldier.mdl"
		monster.Upright = true
		monster.PhysicsBox = {
			Vector( -16, -16, 0 ),
			Vector( 16, 16, 64 )
		}
		monster.Mass = 200
		monster.Animation = { "WalkUnarmed_all" }
		monster.FixedAngle = true
		monster.NoPitch = true
		monster.Reward = 4
		// monster.ModelScale = Vector( 1, 1.5, 1 )
		if (lvl == "2") then
			monster.Health = 500
		end
		if (lvl == "3") then
			monster.Health = 700
		end
		if (lvl == "boss") then
			monster.Health = 900
			// monster.ModelScale = Vector( 1.5, 1.5, 1.5 )
		end
	end

end