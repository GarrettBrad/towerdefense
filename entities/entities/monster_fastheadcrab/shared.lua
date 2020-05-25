
ENT.Base = "base_monster"
ENT.Type = "anim"

ENT.NoPitch = true -- Needed for clientside prediction
ENT.AutomaticFrameAdvance = true

if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	
	function ENT:SetupInfo( monster, lvl )
		monster.Speed = 6
		monster.Health = 40
		monster.Damage = 10
		monster.Model = "models/headcrab.mdl"
		monster.Upright = true
		monster.PhysicsBox = {
			Vector( -8, -8, 0 ),
			Vector( 8, 8, 16 )
		}
		monster.Mass = 40
		monster.Animation = "Run1"
		monster.FixedAngle = true
		monster.NoPitch = true
		monster.Reward = 1
		monster.ModelScale = Vector( 1, 1, 1 )
		if (lvl == "boss") then
			monster.Health = 1250
			monster.FreezeResist = 2.5
			monster.Reward = 20
			monster.ModelScale = Vector( 1.5, 1.5, 1.5 )
		end
	end

end