
local effects_freeze = CreateClientConVar( "effects_freeze", "1", true, false )

/*---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
---------------------------------------------------------*/
function EFFECT:Init( data )
	
	if ( effects_freeze:GetBool() == false ) then return end
	
	local vOffset = data:GetOrigin()
	
	local emitter = ParticleEmitter( vOffset )
	
		local particle = emitter:Add( "effects/freeze_unfreeze", vOffset )
		if (particle) then
			
			particle:SetDieTime( 2 )
			
			particle:SetStartAlpha( 100 )
			particle:SetEndAlpha( 100 )
			
			particle:SetStartSize( 0 )
			particle:SetEndSize( 100 )
			particle:SetColor( 0, 162, 221, 255 )
		
		end
	
end


/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
	return false
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()
end
