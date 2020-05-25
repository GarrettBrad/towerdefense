
include('shared.lua')

ENT.RenderGroup = RENDERGROUP_OPAQUE

/*---------------------------------------------------------
   Name: Draw
   Desc: Draw it!
---------------------------------------------------------*/
function ENT:Draw()
	self.Entity:DrawModel()
end

/*---------------------------------------------------------
   Name: GetHealth
   Desc: I wonder what this does...
---------------------------------------------------------*/
function ENT:GetHealth()
	return self:GetNWInt( "health" ) / 100
end