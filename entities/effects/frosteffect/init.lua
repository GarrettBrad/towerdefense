
/*---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
---------------------------------------------------------*/
function EFFECT:Init( data )
	
	local vOffset = data:GetOrigin()
	
	local NumParticles = 200
	
	local emitter = ParticleEmitter( vOffset )
	
		for i=0, NumParticles do
		
			local particle = emitter:Add( "effects/spark", vOffset )
			if (particle) then
				
				particle:SetVelocity( VectorRand() * 100)
				
				particle:SetLifeTime( 0 )
				particle:SetDieTime( 5 )
				
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 255 )
				
				particle:SetStartSize( 1 )
				particle:SetEndSize( 0 )
				
				particle:SetColor(9, 97, 255, 255) 

				particle:SetRoll( math.Rand(0, 150) )
				particle:SetRollDelta( math.Rand(-200, 200) )
				
				particle:SetAirResistance( 400 )
				
				particle:SetGravity( Vector( 0, 0, -100 ) )
			
			end
			
		end
		
	emitter:Finish()
	
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
