
// ********************************
// * Tower Defense Gamemode - Game *
// ********************************
// init.lua - Loads serverside functionality

require( "glon" )
//require( "datastream" )
AddCSLuaFile( "includes/modules/sh_towers.lua" )
AddCSLuaFile("shared.lua")
--AddCSLuaFile("sh_ages.lua")


AddCSLuaFile( "gui/cl_gui.lua" )
AddCSLuaFile( "gui/cl_vgui.lua" )
AddCSLuaFile( "gui/cl_hud.lua" )
AddCSLuaFile( "gui/cl_dermaskin.lua" )
AddCSLuaFile( "gui/cl_chat.lua" )
AddCSLuaFile( "gui/cl_chatbox.lua" )
	


AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_endgame.lua")

print("add cs lua")
include( "shared.lua" )

include( "server/sv_player.lua" )
include( "server/sv_resource.lua" )

include( "sv_player.lua" )
include( "sv_entities.lua" )
include( "sv_ai.lua" )

resource.AddDir( "models/GMODTD/icetower" )
resource.AddDir( "models/GMODTD/para" )
resource.AddDir( "models/GMODTD/flametower" )
resource.AddDir( "models/GMODTD/pistoltower" )
resource.AddDir( "models/GMODTD/smgtower" )
resource.AddDir( "models/GMODTD/shotguntower" )
resource.AddDir( "models/GMODTD/snipertower" )

resource.AddDir( "materials/models/GMODTD/icetower" )
resource.AddDir( "materials/models/GMODTD/para" )
resource.AddDir( "materials/models/GMODTD/flametower" )
resource.AddDir( "materials/models/GMODTD/pistoltower" )
resource.AddDir( "materials/models/GMODTD/smgtower" )
resource.AddDir( "materials/models/GMODTD/shotguntower" )
resource.AddDir( "materials/models/GMODTD/snipertower" )


function GM:Tick()
	self.BaseClass.Tick( self )
	local playercount = #player.GetAll()
	if ((self.GameStarted && (playercount == 0)) || (self.FullResetAt && (CurTime() >= self.FullResetAt))) then
		// gameserver.FullReset()
		// NOTE: Game ends here, players get reconnected to lobby!
		self.FullResetAt = CurTime() + 5
	end
end

function GM:EndGame( won )
	if (self.GameEnded) then return end
	self.GameEnded = true
	player.CallOnAll( "Freeze", true )
	umsg.Start( "_gameover" )
		umsg.Bool( won == true )
		umsg.Short( 20 )
	umsg.End()
	local session = td_ai.GetSession()
	for _, ply in pairs( player.GetAll() ) do
		datastream.StreamToClients( ply, "td_session", session )
	end
	local reward = (session.CastleHealth or 0) + (table.maxn( session.WavesDefeated or {} ) or 0)
	if (reward < 0) then reward = 0 end
	// GAMEMODE:GiveGlobalMoney( player.GetAll(), reward )
	self.FullResetAt = CurTime() + 20
	// Send gameover status to lobby here
	// timer.Simple( 1, gameserver.SendGameOverStatus, (won == true) )
	td_ai.SUSPEND()
end

function GM:SendWave( wave )
	if (self.GameEnded) then return end
	// Send wave ID to lobby here
	// gameserver.SendWave( wave )
end

function GM:StartGame()
	umsg.Start( "_gamestarted" )
	umsg.End()
	td_ai.StartEvents()
	self.GameStarted = true
end

function GM:InitPostEntity()
	for _, ent in pairs( ents.FindByClass( "prop_physics" ) ) do
		local phys = ent:GetPhysicsObject()
		if (phys && phys:IsValid()) then phys:EnableMotion( false ) end
	end
end


local NextSecond = 0
function GM:Tick()
	if (!self.LastEvent) then self.LastEvent = 0 end
	if (!GameEventsStarted) then return end
	if (AllEventsFinished) then return end
	if (CurTime() >= NextSecond) then
		GameTimePassed = GameTimePassed + 1
		NextSecond = CurTime() + 1
		local trig = 0
		for id, tab in pairs( GameEvents ) do
			if (tab[3]) then trig = trig + 1 end
			if ((!tab[3]) && (GameTimePassed >= tab[1])) then
				tab[3] = true
				tab[2]()
				umsg.Start( "_event" )
				umsg.Short( id )
				umsg.End()
				self.LastEvent = id
				trig = trig + 1
				break
			end
		end
		if (trig == #GameEvents) then AllEventsFinished = true end
	end
end

