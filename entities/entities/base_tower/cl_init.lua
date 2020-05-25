
include('shared.lua')

ENT.RenderGroup = RENDERGROUP_OPAQUE

ENT.LeashOn = true

local matLaser = Material("cable/redlaser")

/*---------------------------------------------------------
   Name: Think
   Desc: Tick tock tick tock...
---------------------------------------------------------*/
local hulltrace = {}
hulltrace.mins = Vector( -8, 0, -8 )
hulltrace.maxs = Vector( 8, 0, 8 )
function ENT:Think()
	if (self.AutomaticFrameAdvance) then self:NextThink( CurTime() ) end
	if (self.LeashOn) then
		hulltrace.start = EyePos()
		hulltrace.endpos = EyePos() + (EyeAngles():Forward() * 512)
		hulltrace.filter = LocalPlayer()
		local tr = util.TraceHull( hulltrace )
		self.ShouldDrawBounds = (tr.Entity == self.Entity)
	end
end

/*---------------------------------------------------------
   Name: GetAmmo
   Desc: Gets the ammo
---------------------------------------------------------*/
function ENT:GetAmmo()
	return self:GetNWInt( "Ammo" ) / self:GetNWInt( "MaxAmmo" )
end

/*---------------------------------------------------------
   Name: Draw
   Desc: Draw it!
---------------------------------------------------------*/
function ENT:Draw()
	// Draw the model
	self.Entity:DrawModel()
	
	// If we have been told to, draw the range
	local range = self:GetNWInt( "Range" )
	if (self.ShouldDrawBounds) && (range > 0) then self:DrawBounds( range ) end
end

/*---------------------------------------------------------
   Name: DrawBounds
   Desc: Draw the range of this tower
---------------------------------------------------------*/
local BoundQuality = 0.2
local BoundColour = Color( 255, 255, 255, 200 )
local Points = 360 * BoundQuality
local Temp = Vector( 0, 0, 0 )
function ENT:DrawBounds( radius )
	// Set the material
	render.SetMaterial( matLaser )
	
	// Start the beam
	render.StartBeam( Points+1 )
	// render.AddBeam( self.Entity:GetPos(), 32, CurTime(), BoundColour )
	
	// Get the origin pos
	local opos = self.Entity:GetPos()
	local ox = opos.x
	local oy = opos.y
	Temp.z = opos.z
	
	// Cycle through each point
	local i, rad, inc = 0, 0, 0
	local angperpoint = 360/Points
	
	for i=1, Points do
		// Calculate the position
		local ang = i * angperpoint
		local nx = ox + (math.sin( math.rad( ang ) ) * radius)
		local ny = oy + (math.cos( math.rad( ang ) ) * radius)
		Temp.x = nx
		Temp.y = ny
		
		// Add the beam
		render.AddBeam( Temp, 16, CurTime() + (i * 1/Points), BoundColour )
	end
	
	// Finialise the beam
	local nx = ox + (math.sin( math.rad( 0 ) ) * radius)
	local ny = oy + (math.cos( math.rad( 0 ) ) * radius)
	Temp.x = nx
	Temp.y = ny
	render.AddBeam( Temp, 16, CurTime() + (i * 1/Points), BoundColour )
	
	render.EndBeam()
end