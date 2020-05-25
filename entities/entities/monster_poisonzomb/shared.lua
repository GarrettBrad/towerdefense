
ENT.Base = "base_monster"
ENT.Type = "anim"

ENT.NoPitch = true -- Needed for clientside prediction
ENT.AutomaticFrameAdvance = true

if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	
	function ENT:SetupInfo( monster, lvl )
		monster.Speed = 5
		monster.Health = 200
		monster.Damage = 20
		monster.Model = "models/zombie/Poison.mdl"
		monster.Upright = true
		monster.PhysicsBox = {
			Vector( -20, -20, 0 ),
			Vector( 20, 20, 48 )
		}
		monster.Mass = 500
		monster.Animation = { "Walk" }
		monster.FixedAngle = true
		monster.NoPitch = true
		monster.Reward = 4
		if (lvl == "boss") then
			monster.Health = 5000
			monster.FreezeResist = 4
			monster.ModelScale = Vector( 1.5, 1.5, 1.5 )
		end
	end

end