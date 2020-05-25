
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local DebugMode = false

ENT.Model = "models/props_combine/breenglobe.mdl"

/*---------------------------------------------------------
   Name: OnRemove
   Desc: Entity is removed (o rly)
---------------------------------------------------------*/
function ENT:OnRemove()
	timer.Remove( self.Entity:EntIndex() .. "_anim" )
	
end

/*---------------------------------------------------------
   Name: Initialize
   Desc: Entity is created
---------------------------------------------------------*/
function ENT:Initialize()
	local dat = {}
	self:SetupInfo( dat, 1 )
	
	self.NextShoot = CurTime() + dat.Delay -- Anti hax
	self.Level = 1
	self:SetNWInt( "lvl", self.Level )
	self:SetNWInt( "Range", dat.Range )
	self.MaxLevel = dat.MaxLvl or 1
	self.Tower = dat
	
	self.Ammo = dat.Ammo
	self.MaxAmmo = dat.Ammo
	
	self:SetNWInt( "Ammo", self.Ammo )
	self:SetNWInt( "MaxAmmo", self.MaxAmmo )
		
	if (dat.Color) then self.Entity:SetColor( dat.Color.r, dat.Color.g, dat.Color.b, 255 ) end
	self:ChangeModel( dat.Model or self.Model, dat.ModelScale )
	
	if (dat.Animation) && ((!dat.AnimationSpeed) || (dat.AnimationSpeed > 0)) then
		if (type( dat.Animation ) == "table") then
			self.Anim = self.Entity:LookupSequence( table.Random( dat.Animation ) )
		else
			self.Anim = self.Entity:LookupSequence( dat.Animation )
		end
		self.Entity:SetSequence( self.Anim )
		if (dat.AnimationSpeed) then self.Entity:SetPlaybackRate( dat.AnimationSpeed ) end
		timer.Remove( self.Entity:EntIndex() .. "_anim" )
		timer.Create( self.Entity:EntIndex() .. "_anim", self.Entity:SequenceDuration(), 0,
			self.Entity.ResetSequence, self.Entity, self.Anim );
	end
end

/*---------------------------------------------------------
   Name: ChangeModel
   Desc: Changes the model of the entity
---------------------------------------------------------*/
function ENT:ChangeModel( mdl, scale )
	self.Entity:SetModel( mdl )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_NONE )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	if (scale) then
		self.Entity:SetNWBool( "scaled", true )
		self.Entity:SetNWVector( "modelscale", scale )
	end
end

/*---------------------------------------------------------
   Name: GetLevel
   Desc: Retrieves the entity's level
---------------------------------------------------------*/
function ENT:GetLevel()
	return self.Level
end

/*---------------------------------------------------------
   Name: CanUpgrade
   Desc: Determines if the entity can be upgraded or not
---------------------------------------------------------*/
function ENT:CanUpgrade()
	return self:GetLevel() < self.MaxLevel
end

/*---------------------------------------------------------
   Name: Upgrade
   Desc: Upgrades the entity
---------------------------------------------------------*/
function ENT:Upgrade()
	if (!self:CanUpgrade()) then return end
	self.Level = self.Level + 1
	local dat = {}
	self:SetupInfo( dat, self.Level )
	self.Tower = dat
	self:SetNWInt( "lvl", self.Level )
	if (dat.Animation) && ((!dat.AnimationSpeed) || (dat.AnimationSpeed > 0)) then
		if (type( dat.Animation ) == "table") then
			self.Anim = self.Entity:LookupSequence( table.Random( dat.Animation ) )
		else
			self.Anim = self.Entity:LookupSequence( dat.Animation )
		end
		self.Entity:SetSequence( self.Anim )
		if (dat.AnimationSpeed) then self.Entity:SetPlaybackRate( dat.AnimationSpeed ) end
		timer.Remove( self.Entity:EntIndex() .. "_anim" )
		timer.Create( self.Entity:EntIndex() .. "_anim", 
            self.Entity:SequenceDuration(), 
            0,
            function ()
                self.Entity.ResetSequence(self.Entity, self.Anim)
            end )

	end
end

/*---------------------------------------------------------
   Name: SetupInfo
   Desc: Entity sets up tower data
---------------------------------------------------------*/
function ENT:SetupInfo( tower )
	tower.Delay = 0.2
	tower.Damage = 1
	tower.ShootNum = 1
	tower.Effect = "AR2Tracer"
	tower.MuzzleFlash = "AR2MuzzleFlash"
	tower.Accuracy = 0.05
	tower.Health = 50
	tower.Cost = 10
	tower.Snd = Sound( "weapons/ar2/fire1.wav" )
	tower.Range = 256
end

/*---------------------------------------------------------
   Name: SelectTarget
   Desc: Selects a target to attack from a list of potential targets
---------------------------------------------------------*/
function ENT:SelectTarget( targets )
	if (self.Tower.SelectTarget) then return self.Tower.SelectTarget( self, targets ) end

	// BASIC LOGIC
	// > Get the first target in the list
	return targets[1]
end

/*---------------------------------------------------------
   Name: CheckVisible
   Desc: Performs a traceline to see if an entity is visible
---------------------------------------------------------*/
local trace = {}
function ENT:CheckVisible( target )
	trace.start = self:GetPos()
	if (self.Tower.MuzzleFlashOffset) then trace.start = trace.start + self.Tower.MuzzleFlashOffset end
	trace.endpos = target:GetCentralPos()
	trace.filter = { self.Entity }
	table.Add( trace.filter, player.GetAll() )
	local tr = util.TraceLine( trace )
	if (DebugMode) then self.Owner:SendTrace( trace.start, tr.HitPos ) end
	return (tr.HitPos - trace.endpos):Length() < 1
end

/*---------------------------------------------------------
   Name: Think
   Desc: Entity thinks
---------------------------------------------------------*/
function ENT:Think()
	/*if (self.Anim) then
		self:ResetSequence( self.Anim )
		self:NextThink( CurTime() )
	end*/
	local t = self.Tower
	if (!t) then return end

	if (!self.NextUpdate) then self.NextUpdate = CurTime() end
	if (CurTime() > self.NextUpdate) then
		self.NextUpdate = CurTime() + 0.5
		self:Tick( t )
	end
	

	if (self.IsShooting) then
		if (!self.Ammo) then return end
		if (!self.NextShoot) then self.NextShoot = CurTime() end
		if (CurTime() >= self.NextShoot) then
			if (self.Ammo > 0) then
			// Fire at the target!
			self:FireAt( t, self.ShootTarget )
			self.NextShoot = CurTime() + t.Delay
			end
		end
	end
	
end

local STATUS_IDLE = 0
local STATUS_ATTACKING = 1
/*---------------------------------------------------------
   Name: Tick
   Desc: Entity ticks
---------------------------------------------------------*/
function ENT:Tick( t )

	if (t.Upgradetowers) then
		local vPoint = self.Entity:GetPos()
		local e = EffectData()
		e:SetStart( vPoint )
		e:SetOrigin( vPoint )
		e:SetScale( 0.1 )
		util.Effect( "TowerResearchEffect", e )
	end
	
	
	if (t.Ammoregen) then
	local AmmoTickRate = t.Delay
		if (!self.AmmoTickUpdate) then self.AmmoTickUpdate = CurTime() end
		if (CurTime() > self.AmmoTickUpdate) then
			self.AmmoTickUpdate = CurTime() + AmmoTickRate
			local vPoint = self.Entity:GetPos()
			local e = EffectData()
			e:SetStart( vPoint )
			e:SetOrigin( vPoint )
			e:SetScale( 0.1 )
			util.Effect( "TowerResearchEffect", e )
			for _, ents in pairs( ents.FindInSphere( self.Entity:GetPos() , self.Tower.Range ) ) do
				if (ents.IsTower) then	
					ents:SetNWInt( "Ammo", ents.Ammo + t.Ammoregen )
					ents.Ammo = math.Clamp( ents.Ammo + t.Ammoregen, 0, ents.Ammo )
				end
			end
		end
	end
	
	
	if (t.ParalyzeSlowDown) then
	local ParalyzeTickRate = t.Delay
	if (!self.ParalyzeTickUpdate) then self.ParalyzeTickUpdate = CurTime() end
	if (CurTime() > self.ParalyzeTickUpdate) then
		self.ParalyzeTickUpdate = CurTime() + ParalyzeTickRate
		local vPoint = self:GetPos()
		local e = EffectData()
		e:SetStart( vPoint )
		e:SetOrigin( vPoint )
		e:SetScale( 0.01 )
		util.Effect( "TowerParalyzeEffect", e )
			for _, ent in pairs( ents.FindInSphere( self:GetPos() , t.Range ) ) do
				if (ent.IsMonster) then	
					if (self:CheckVisible( ent ) && (!ent.Slowed) ) then
						ent:SlowFor( t.SlowTime, t.SlowDamage )
					end
				end
			end
		end
	end
	
	// Get our current status and target
	local status = self.Status or STATUS_IDLE
	local target = self.Target or NullEntity()
	
	// If we are idle....
	if (status == STATUS_IDLE) then
		// ... search for targets.
		local targetlist = ents.FindInSphere( self:GetPos(), t.Range )
		local targets = {}
		for _, ent in pairs( targetlist ) do
			// Check if entity is a possible target
			if (ent.IsMonster) then
				if (self:CheckVisible( ent ) && ((!ent.Frozen) || (!t.NoTargetFrozen) )) then
					// We have a target!
					table.insert( targets, ent )
				end
			end
		end
		if (#targets > 0) then
			local ent = self:SelectTarget( targets )
			if (IsValid( ent )) then
				// Target locked, aim and prepare to fire!
				target = ent
				status = STATUS_ATTACKING
				// Yessir!  *salutes*
			end
		end
	end
	
	// If we are attacking...
	if (status == STATUS_ATTACKING) then
		
		// ... reset our attack data
		self.IsShooting = false
		self.ShootTarget = nil
		
		// ... check the target is still valid.
		if ((!target) || (!target:IsValid()) || (!self:CheckVisible( target )) ||
			((self.Entity:GetPos() - target:GetPos()):Length() > t.Range)) then
			
			// We lost it, switch back to idle
			target = NullEntity()
			status = STATUS_IDLE
		else
			// We are shooting
			self.IsShooting = true
			self.ShootTarget = target
		end
	end
	
	// Update our status and target
	self.Status = status
	self.Target = target
end

/*---------------------------------------------------------
   Name: FireAt
   Desc: Entity fires at other entity
---------------------------------------------------------*/
local bullet = {}
local trace = {}
local tempvec = Vector( 0, 0, 0 )
function ENT:FireAt( t, ent )
	if ((!ent) || (!ent:IsValid())) then return end
	self:SetNWInt( "Ammo", self.Ammo - 1 )
	self.Ammo = math.Clamp( self.Ammo - 1, 0, self.Ammo )
	if (!ent.SnapPos) then ent.SnapPos = (ent:OBBMins() + ent:OBBMaxs()) * 0.5 end
	local targetpos = ent:LocalToWorld( ent.SnapPos )
	local aimvec = targetpos - self.Entity:GetPos()
      print(aimvec)
	if (t.FreezeOnHit) then
		ent:FreezeFor( t.FreezeTime )
	end
	
	if (t.IgniteOnHit) then
		ent:IgniteFor( t.IgniteTime, t.IgniteDamage )
	end
	
	if (t.SlowOnHit) then
		ent:SlowFor( t.SlowTime, t.SlowDamage )
	end
				
	local dmg = t.Damage * t.ShootNum
	ent:TakeDamage( dmg, self.Entity )
	local ply = self.Owner
	if (ply && ply:IsValid()) then ply.TotalDamageDealt = (ply.TotalDamageDealt or 0) + dmg end
		
	if (t.MuzzleFlash) then
		local pos = self.Entity:GetPos()
		--print(aimvec:Normalize())
		--print(aimvec:Normalize()*8)
		if (t.MuzzleFlashOffset) then pos = pos + t.MuzzleFlashOffset end
		local epos = pos
		local tempVec = aimvec
		tempVec:Normalize()
		tempVec:Mul(8)
		epos:Add(tempVec)

		local e = EffectData()
		e:SetStart( epos )
		e:SetOrigin( epos )
		e:SetAngles( Vector(-aimvec.x,-aimvec.y,aimvec.z):Angle() )
		e:SetMagnitude( 1 )
		e:SetScale( 1 )
		util.Effect( t.MuzzleFlash, e )
		e:SetStart( epos )
		e:SetOrigin( epos )
		e:SetAngles( aimvec:Angle() )
		e:SetMagnitude( 1 )
		e:SetScale( 1 )
		util.Effect( "MuzzleEffect", e )
	end
	
	if (t.Snd) then self.Entity:EmitSound( t.Snd ) end
end
