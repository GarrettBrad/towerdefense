
ENT.Base = "base_monster"
ENT.Type = "anim"

ENT.NoPitch = true -- Needed for clientside prediction
ENT.AutomaticFrameAdvance = true

if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	
	function ENT:SetupInfo( monster, lvl )
		monster.Speed = 3
		monster.Health = 425
		monster.Damage = 20
		monster.Model = "models/zombie/Classic_torso.mdl"
		monster.Upright = true
		monster.PhysicsBox = {
			Vector( -16, -16, 0 ),
			Vector( 16, 16, 16 )
		}
		monster.Mass = 200
		monster.Animation = { "crawl" }
		monster.FixedAngle = true
		monster.NoPitch = true
		monster.Reward = 2
		if (lvl == "boss") then
			monster.Health = 6000
			monster.FreezeResist = 3
			monster.Reward = 30
			monster.ModelScale = Vector( 1.5, 1.5, 1.5 )
		end
	end

end