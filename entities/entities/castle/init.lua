
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

ENT.Model = "models/GMODTD/castle/castle2.mdl"

ENT.IsTower = true

/*---------------------------------------------------------
   Name: Initialize
   Desc: Entity is created
---------------------------------------------------------*/
function ENT:Initialize()
	self.Entity:SetModel( self.Model )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_NONE )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	self.HP = 100
	self:SetNWInt( "health", self.HP )
end

/*---------------------------------------------------------
   Name: Think
   Desc: Entity thinks
---------------------------------------------------------*/
function ENT:Think()
	local hp = self.HP
	if (hp <= 20) then
	self.Entity:Extinguish()
	self.Entity:Ignite( 100 )
	end
	if (hp <= 0) then
		local e = EffectData()
		e:SetStart( self.Entity:GetPos() )
		e:SetOrigin( e:GetStart() )
		e:SetScale( 1 )
		e:SetMagnitude( 1 )
		util.Effect( "Explosion", e )
		self.Entity:Remove()
		GAMEMODE:EndGame( false )
		return
	end
end

/*---------------------------------------------------------
   Name: Heal
   Desc: Heals this entity
---------------------------------------------------------*/
function ENT:Heal( amount )
	self.HP = math.Clamp( self.HP + amount, 0, 100 )
	
	self:SetNWInt( "health", self.HP )
end

/*---------------------------------------------------------
   Name: OnTakeDamage
   Desc: Entity takes damage
---------------------------------------------------------*/
function ENT:OnTakeDamage( dmginfo )

	if (!dmginfo:GetInflictor().IsMonster) then return end

	self.HP = self.HP - dmginfo:GetDamage()
	self:SetNWInt( "health", self.HP )

end