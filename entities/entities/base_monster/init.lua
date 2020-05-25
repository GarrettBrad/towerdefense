
local function AccessorFunc( tab, name, var, force )
	tab[ "Set" .. name ] = function( ent, val )
		if (force == FORCE_BOOL) then ent[ var ] = tobool( val ) end
		if (force == FORCE_STRING) then ent[ var ] = tostring( val ) end
		if (force == FORCE_NUMBER) then ent[ var ] = tonumber( val ) end
	end
	tab[ "Get" .. name ] = function( ent )
		return ent[ var ]
	end
end

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

ENT.Model = "models/roller.mdl"

local SpeedMultiplier = 20
local TickRate = 0.1

/*---------------------------------------------------------
   Name: Initialize
   Desc: Entity is created
---------------------------------------------------------*/
function ENT:Initialize()

	local dat = self:SetLevel( "1" )
	
	self.Entity:SetModel( dat.Model or self.Model )
	if (dat.PhysicsBox) then
		local p = dat.PhysicsBox
		local mins = p[1]
		local maxs = p[2]
		self.Entity:PhysicsInitBox( mins, maxs )
		self.Entity:SetCollisionBounds( mins, maxs )
	else
		self.Entity:PhysicsInit( SOLID_VPHYSICS )
	end
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	
	// self.Entity:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	
	if (dat.ModelScale) then
		self:SetNWVector( "ModelScale", dat.ModelScale )
	else
		self:SetNWVector( "ModelScale", Vector( 1, 1, 1 ) )
	end
	
	local phys = self.Entity:GetPhysicsObject()
	
	if (phys && phys:IsValid()) then
		phys:Wake()
		if (dat.Upright) then
			local const = constraint.Keepupright( self.Entity, Angle( 0, 0, 0 ), 0, 100000 )
			if (const && const:IsValid()) then const:Activate() end
		end
		if (dat.Mass) then
			phys:SetMass( dat.Mass )
		end
	end
	
	if (dat.Animation) then
		self.AutomaticFrameAdvance = true
		if (type( dat.Animation ) == "table") then
			self.Anim = self.Entity:LookupSequence( table.Random( dat.Animation ) )
		else
			self.Anim = self.Entity:LookupSequence( dat.Animation )
		end
		self.Entity:SetSequence( self.Anim )
	end
	
	// self.Entity:StartMotionController()
	self:SetTargetZ( 0 )
	self:SetAirResistance( 1 )
	
	// self:SetTargetPos( Vector( 0, 0, 0 ) )
	// self.Targeted = false
end

/*---------------------------------------------------------
   Name: SetLevel
   Desc: Level of monster is set
---------------------------------------------------------*/
function ENT:SetLevel( lvl )
	local dat = {}
	
	self:SetupInfo( dat, lvl )
	self.HP = dat.Health * td_ai.CalculateDifficulty( "Health" ) * td_ai.GetWaveID()
	
	self:SetNWInt( "HP", self.HP )
	self:SetNWInt( "MaxHP", self.HP )
	
	self.Monster = dat
	
	if (lvl == "boss") then dat.Damage = 50 end
	
	return dat
end

/*---------------------------------------------------------
   Name: AccessorFuncs for the entity
---------------------------------------------------------*/
AccessorFunc( ENT, "TargetZ", "m_intTargetZ", FORCE_NUMBER )
AccessorFunc( ENT, "AirResistance", "m_intAirResist", FORCE_NUMBER )

/*---------------------------------------------------------
   Name: SetupInfo
   Desc: Entity sets up monster data
---------------------------------------------------------*/
function ENT:SetupInfo( monster, lvl )
	monster.Speed = 50
	monster.Health = 114
	monster.Damage = 10
	monster.Reward = 2
end

/*---------------------------------------------------------
   Name: Think
   Desc: Entity thinks
---------------------------------------------------------*/
function ENT:Think()
	if (self.Anim) then
		self:ResetSequence( self.Anim )
		self:NextThink( CurTime() )
	end
	local m = self.Monster
	if (!m) then return end
	local hp = self.HP
	if (hp <= 0) then
		Winnings = math.floor( m.Reward * td_ai.CalculateDifficulty( "Reward" ) ) -- you forgot to math.floor the money dummy xD
		GAMEMODE:AwardTeamMoney( Winnings )
		if (self.IsBoss && (!self.WasNotDefeated)) then td_ai.BossDefeated( self:GetClass(), self.GlobalReward ) end
		self.Entity:Remove()
		return
	end
	if (!self.NextUpdate) then self.NextUpdate = CurTime() end
	if (CurTime() > self.NextUpdate) then
		self.NextUpdate = CurTime() + TickRate
		self:Tick( m )
	end
	local fend = self.FreezeEndTime
	if (fend && (CurTime() >= fend)) then self:Unfreeze() end
	local iend = self.IgniteEndTime
	if (iend && (CurTime() >= iend)) then self:Unignite() end
	local send = self.SlowEndTime
	if (send && (CurTime() >= send)) then self:Unslow() end
end

/*---------------------------------------------------------
   Name: Tick
   Desc: Entity ticks
---------------------------------------------------------*/
local offsety = Vector( 0, 0, 1 )
function ENT:Tick( m )
	local rt = self.RouteName
	if (!rt) then return end
	local tid = self.TargetID
	print("----TID----")
	print(tid)
	if (!tid) then return end
	local SpeedMult = 1
		
	if (self.Ignited) then
		local dmg = self.IgDmg * TickRate
		self:DealDamage( dmg )
	end
	if (self.Slowed) then
		local dmg = self.SlDmg * TickRate
		self:DealDamage( dmg )
		SpeedMult = 0.5
		local vPoint = self.Entity:GetPos()
		local e = EffectData()
		e:SetStart( Vector(vPoint.x,vPoint.y,vPoint.z + 20) )
		e:SetOrigin( Vector(vPoint.x,vPoint.y,vPoint.z + 20)  )
		e:SetScale( 1 )
		util.Effect( "frosteffect", e )
	end
	if (td_ents.IsInRangeOfCastle( self.Entity )) then
		self.HP = 0
		self.WasNotDefeated = true
		local c = td_ents.GetCastle()
		if (c && c:IsValid()) then
			c:TakeDamage( m.Damage, self.Entity )
		end
		return
	end
	local targetpos = td_ents.GetNodePos( rt, tid )
	print("-----targetpos------")
	print(targetpos)
	if (!self.TargetPos) then self.TargetPos = targetpos end
	local cpos = self.Entity:GetPos()
	print("-----Cpos------")
	print(cpos)
	print("-----Node ID------")
	print(self.TargetID)
	--print(targetpos:Sub(cpos):Length())
	local tvec = targetpos:Sub(cpos)
	print(tvec)
	if (targetpos:Sub(cpos):Length() <= 60) then
	--if targetpos:DistToSqr(cpos) < (32*32) then
		self.TargetID = tid + 1
		self.TargetPos = td_ents.GetNodePos( rt, self.TargetID )
	end
	local tpos = self.TargetPos
	local phys = self.Entity:GetPhysicsObject()
	local aim = nil
    tpos:Sub(cpos)
    aim = tpos
    aim:Normalize()
	if (m.FixedAngle) then
		local oldaim = self.OldAim or aim
		self.OldAim = aim
		local myaim = math.Mid( oldaim, aim, TickRate )
		local ang = myaim:Angle()
		if (m.NoPitch) then ang.p = 0 end
		self:SetAngles( ang )
	end
	if (phys && phys:IsValid()) then
		local force = aim * m.Speed * SpeedMultiplier * phys:GetMass() * SpeedMult
		phys:ApplyForceCenter( force )
	end
end

/*---------------------------------------------------------
   Name: FreezeFor
   Desc: Freeze this entity for n seconds
---------------------------------------------------------*/
function ENT:FreezeFor( time )
	local m = self.Monster
	if (m && m.FreezeResist) then
		local phys = self.Entity:GetPhysicsObject()
		if (phys && phys:IsValid()) then phys:SetVelocity( phys:GetVelocity() * (m.FreezeResist/5) ) end
		return
	end
	local phys = self.Entity:GetPhysicsObject()
	if (phys && phys:IsValid()) then phys:EnableMotion( false ) end
	if (!self.FreezeEndTime) then self.FreezeEndTime = CurTime() end
	self.FreezeEndTime = self.FreezeEndTime + time
	self.Entity:SetColor( 0, 0, 255, 128 )
	self.Frozen = true
end

/*---------------------------------------------------------
   Name: IgniteFor
   Desc: Ignite this entity for n seconds
---------------------------------------------------------*/
function ENT:IgniteFor( time, damage_per_second )
	local m = self.Monster
	if (m && m.FireResist) then time = time / m.FireResist end
	if (!self.IgniteEndTime) then self.IgniteEndTime = CurTime() end
	self.IgniteEndTime = self.IgniteEndTime + time
	self.Entity:SetColor( 255, 200, 200, 255 )
	self.Ignited = true
	self:Ignite( time, 0 )
	self.IgDmg = damage_per_second
end

/*---------------------------------------------------------
   Name: SlowFor
   Desc: Slow down this entity for n seconds
---------------------------------------------------------*/
function ENT:SlowFor( time, damage_per_second )
	local m = self.Monster
	if (m && m.SlowResist) then time = time / m.SlowResist end
	if (!self.SlowEndTime) then self.SlowEndTime = CurTime() end
	self.SlowEndTime = self.SlowEndTime + time
	self.Entity:SetColor( 200, 200, 255, 255 )
	self.Slowed = true
	self.SlDmg = damage_per_second
end

/*---------------------------------------------------------
   Name: Unfreeze
   Desc: Unfreeze this entity
---------------------------------------------------------*/
function ENT:Unfreeze()
	local phys = self.Entity:GetPhysicsObject()
	if (phys && phys:IsValid()) then
		phys:EnableMotion( true )
		phys:SetVelocity( Vector( 0, 0, 0 ) )
	end
	self.Entity:SetColor( 255, 255, 255, 255 )
	self.FreezeEndTime = nil
	self.Frozen = false
end

/*---------------------------------------------------------
   Name: Unfreeze
   Desc: Unfreeze this entity
---------------------------------------------------------*/
function ENT:Unignite()
	self.Entity:SetColor( 255, 255, 255, 255 )
	self.IgniteEndTime = nil
	self.Ignited = false
	self:Extinguish()
end

/*---------------------------------------------------------
   Name: Unslow
   Desc: Unslow this entity
---------------------------------------------------------*/
function ENT:Unslow()
	self.Entity:SetColor( 255, 255, 255, 255 )
	self.SlowEndTime = nil
	self.Slowed = false
end

/*---------------------------------------------------------
   Name: OnTakeDamage
   Desc: Entity takes damage
---------------------------------------------------------*/
function ENT:OnTakeDamage( dmginfo )

	if (!dmginfo:GetInflictor().IsTower) then return end

	self:DealDamage( dmginfo:GetDamage() )
	
	self.LastAttacker = dmginfo:GetAttacker()

end

/*---------------------------------------------------------
   Name: DealDamage
   Desc: Deals damage to this entity, regardless of circumstance
---------------------------------------------------------*/
function ENT:DealDamage( amount )
	self.HP = math.Clamp( self.HP - amount, 0, self.HP )
	self:SetNWInt( "HP", self.HP )
end	

/*---------------------------------------------------------
   Name: PhysicsSimulate
   Desc: Entity updates it's physics
---------------------------------------------------------*/
function ENT:PhysicsSimulate( phys, deltatime )
	
	// Wake the physics object
	phys:Wake()
	
	// Get information about our target and current status
	local m, rt, tid = self.Monster, self.RouteName, self.TargetID
	if (!m) || (!rt) || (!tid) then return end
	local pos = phys:GetPos()
	local vel = phys:GetVelocity()
	local speed = vel:Length()
	local tpos = self.TargetPos
	if (!tpos) then return end
	local dir = (pos-tpos):Normalize()
	
	local force = dir * m.Speed * SpeedMultiplier * deltatime * phys:GetMass() * (self.SlowEffect or 1)
	phys:ApplyForceCenter( force )
	
	return SIM_NOTHING
	
end