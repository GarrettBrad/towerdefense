
include('shared.lua')

ENT.RenderGroup = RENDERGROUP_OPAQUE

/*---------------------------------------------------------
   Name: Draw
   Desc: Draw it!
---------------------------------------------------------*/
function ENT:Draw()
	self:UpdateScale()
	self.Entity:DrawModel()
end

/*---------------------------------------------------------
   Name: GetHealth
   Desc: I wonder what this does...
---------------------------------------------------------*/
function ENT:GetHealth()
	return self:GetNWInt( "HP" ) / self:GetNWInt( "MaxHP" )
end

/*---------------------------------------------------------
   Name: UpdateScale
   Desc: Reads and updates this entity's scale
---------------------------------------------------------*/
function ENT:UpdateScale()
	local scale = self:GetNWVector( "ModelScale" )

	self:SetModelScale( 1 ) -- TODO: FIX THIS -- model scale is vecotor and should be a number
end

/*---------------------------------------------------------
   Name: PhysicsUpdate
   Desc: Updates this entity's physics
---------------------------------------------------------*/
function ENT:PhysicsUpdate( phys )
	if (self.NoPitch) then
		local ang = self.Entity:GetAngles()
		ang.p = 0
		self.Entity:SetAngles( ang )
	end
end