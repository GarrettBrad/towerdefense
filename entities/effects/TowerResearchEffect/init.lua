

EFFECT.Mat = Material( "effects/select_ring" )

/*---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
---------------------------------------------------------*/
function EFFECT:Init( data )
	
	local size = 8
	self.Entity:SetCollisionBounds( Vector( -size,-size,-size ), Vector( size,size,size ) )
	
	local Pos = data:GetOrigin() + data:GetNormal() * 2
		
	self.Entity:SetPos( Pos )
	
	self.Entity:SetAngles( data:GetNormal():Angle() + Angle( 0.01, 0.01, 0.01 ) )
	
	self.Entity:SetParentPhysNum( data:GetAttachment() )
	
	if (data:GetEntity():IsValid()) then
		self.Entity:SetParent( data:GetEntity() )
	end
	
	self.Pos = data:GetOrigin()
	self.Normal = data:GetNormal()
	
	self.Speed = 0.25
	self.Size = 60
	self.Alpha = 255
	
	self.Life = 0.5
	
end


/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )

	self.Alpha = self.Alpha - FrameTime() * 255 * 5 * self.Speed
	self.Size = self.Size + FrameTime() * 256 * self.Speed
	
	if (self.Alpha < 0 ) then return false end
	return true
	
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render( )

	if (self.Alpha < 1 ) then return end

	render.SetMaterial( self.Mat )
	
	render.DrawQuadEasy( self.Entity:GetPos(),
						 self.Entity:GetAngles():Forward(),
						 self.Size, self.Size,
						 Color( 0, 0, 255, self.Alpha ) )
						 
						

end
