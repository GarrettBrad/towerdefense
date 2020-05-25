
ENT.Base = "base_monster"
ENT.Type = "anim"

ENT.NoPitch = true -- Needed for clientside prediction
ENT.AutomaticFrameAdvance = true

if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	
	function ENT:SetupInfo( monster, lvl )
		monster.Speed = 10
		monster.Health = 30
		monster.Damage = 10
		monster.Model = "models/zombie/fast.mdl"
		monster.Upright = true
		monster.PhysicsBox = {
			Vector( -16, -16, 0 ),
			Vector( 16, 16, 48 )
		}
		monster.Mass = 1
		monster.Animation = { "Run" }
		monster.FixedAngle = true
		monster.NoPitch = true
		monster.Reward = 2
		if (lvl == "boss") then
			monster.Health = 1000
			monster.Reward = 50
			monster.FreezeResist = 4
			monster.ModelScale = Vector( 1.5, 1.5, 1.5 )
		end
	end

end