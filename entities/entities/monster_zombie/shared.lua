
ENT.Base = "base_monster"
ENT.Type = "anim"

ENT.NoPitch = true -- Needed for clientside prediction
ENT.AutomaticFrameAdvance = true

if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	
	function ENT:SetupInfo( monster, lvl )
		monster.Speed = 3
		monster.Health = 100
		monster.Damage = 10
		monster.Model = "models/zombie/Classic.mdl"
		monster.Upright = true
		monster.PhysicsBox = {
			Vector( -16, -16, 0 ),
			Vector( 16, 16, 64 )
		}
		monster.Mass = 200
		monster.Animation = { "walk", "walk1", "walk2", "walk3", "walk4", "FireWalk" }
		monster.FixedAngle = true
		monster.NoPitch = true
		monster.Reward = 2
		if (lvl == "boss") then
			monster.Health = 3000
			monster.FreezeResist = 3.5
			monster.Reward = 40
			monster.ModelScale = Vector( 1.5, 1.5, 1.5 )
		end
	end

end