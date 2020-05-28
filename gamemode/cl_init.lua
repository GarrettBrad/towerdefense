
// ********************************
// * Tower Defense Gamemode - Game *
// ********************************
// cl_init.lua - Loads clientside functionality

--include( "sh_ages.lua" )
include( "shared.lua" )

include( "gui/cl_dermaskin.lua" )
include( "gui/cl_gui.lua" )
include( "gui/cl_hud.lua" )
include( "gui/cl_vgui.lua" )
include( "cl_hud.lua" )
include( "cl_endgame.lua" )

usermessage.Hook( "_youvoted", function() GAMEMODE.LocalPlayerVoted = true end )
function GM:Initialize()
	print("RAN INIT")
	--surface.CreateFont( "coolvetica", 48, 500, true, false, "ScoreboardHead" )
	--surface.CreateFont( "coolvetica", 24, 500, true, false, "ScoreboardSub" )
	--surface.CreateFont( "Tahoma", 16, 1000, true, false, "ScoreboardText" )
	
	surface.CreateFont( "ScoreboardHead", {
	font = "coolvetica", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 48,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})
	surface.CreateFont( "ScoreboardSub", {
	font = "coolvetica", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 24,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})
	surface.CreateFont( "ScoreboardText", {
	font = "Tahoma", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 16,
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})
	self.BaseClass.Initialize( self )
	self:InitGUI()
	
	timer.Simple( 3, function()
		GAMEMODE:StartMusic()
	end )
end
usermessage.Hook( "_gamestarted", function()
	GAMEMODE.GameStarted = true
	GAMEMODE.GameStartTime = CurTime()
end )

usermessage.Hook( "_playersleft", function( um )
	GAMEMODE.VotesLeft = um:ReadShort()
end )
usermessage.Hook( "_nextwave", function( um )
	GAMEMODE.NextWaveTime = CurTime() + um:ReadShort()
	GAMEMODE.WaveInProgress = false
end )

usermessage.Hook( "_wavestarted", function( um )
	GAMEMODE.WaveInProgress = true
	local id = um:ReadShort()
	local typ = um:ReadString()
	GAMEMODE.WaveID = id
	GAMEMODE.WaveType = typ
end )

usermessage.Hook( "_gameover", function( um )
	local won = um:ReadBool()
	GAMEMODE:GameOver( won )
	GAMEMODE.BackToLobby = CurTime() + um:ReadShort()
end )

usermessage.Hook( "_upgrades", function( um )
	local enc = um:ReadString()
	local lst = string.Explode( ",", enc )
	GAMEMODE.Upgrades = {}

	for _, v in pairs( lst ) do
		local spl = string.Explode( "=", v )
		local name = spl[1]
		local has = (spl[2] == "1")

		GAMEMODE.Upgrades[ name ] = has
	end

	if (um:ReadBool()) then
		RunConsoleCommand( "-menu" )
		timer.Simple( 0, RunConsoleCommand, "+menu" )
	end
end )

function GM:GameOver( won )
	self.GameEnded = true
end

concommand.Add( "td_music", function( pl, com, args )
	local on = (args[1] == "1")
	if (on) then
		RunConsoleCommand( "td_playmusic", 1 )
		if (!timer.IsTimer( "TDMusic" )) then GAMEMODE:StartMusic() end
	else
		RunConsoleCommand( "td_playmusic", 0 )
		timer.Destroy( "TDMusic" )
		timer.Simple( 1, RunConsoleCommand, "stopsounds" )
	end
end )




function GM:StartMusic()
	// surface.PlaySound( "TD_DurianCastle.mp3" )
	// timer.Create( "TDMusic", SoundDuration( "TD_DurianCastle.mp3" ), 0, surface.PlaySound, "TD_DurianCastle.mp3" )
end

function GM:Think()
	self.BaseClass.Think( self )
	//self:GUIThink()
end

function GM:Has( name )
	if (!self.Upgrades) then
		RunConsoleCommand( "td_refreshupgrades" )
		return
	end

	return game.SinglePlayer() || self.Upgrades[ name ]
end


----FROM BASE----
usermessage.Hook( "_notice", function( um )
	local pn = GAMEMODE:CreateNotice( um:ReadString() )

	timer.Simple( 5, pn.Remove, pn )
end )

usermessage.Hook( "_connect", function( um )
	// RunConsoleCommand( "connect", um:ReadString() )
	LocalPlayer():ConCommand( "connect " .. um:ReadString() )
end )

usermessage.Hook( "_event", function( um )
	local id = um:ReadShort()
	local event = GameEvents[ id ]
	if (!event) then return end

	event[2]()
	event[3] = true

	local nextevent = GameEvents[ id+1 ]

	if (!nextevent) then return end
end )

usermessage.Hook( "_timetillnextevent", function( um )
	GAMEMODE.NextEvent = CurTime() + um:ReadLong()
	local cnt

	for cnt=1, um:ReadShort() do
		local event = GameEvents[ cnt ]
		if (event) then event[3] = true end
	end
end )

local cvShowGSChat = CreateClientConVar( "td_showglobalchat", 1, true, false )

local bluez = Color( 0, 128, 128, 255 )
local morgreen = Color( 128, 158, 128, 255 )
usermessage.Hook( "_gschat", function( um )
	if (!cvShowGSChat:GetBool()) then return end

	local nick = um:ReadString()
	local text = um:ReadString()

	chat.AddText( bluez, "(Lobby) ", morgreen, nick .. ": ", color_white, text )
end )

usermessage.Hook( "_gslchat", function( um )
	if (!cvShowGSChat:GetBool()) then return end

	local nick = um:ReadString()
	local text = um:ReadString()

	chat.AddText( bluez, "(Global) ", morgreen, nick .. ": ", color_white, text )
end )

function GM:SecondsToString( secs )
	local mins = math.floor( secs/60 )
	local secsleft = secs-(mins*60)

	return mins .. " minutes and " .. secsleft .. " seconds"
end

function GM:TimeTillNextEvent()
	if (!self.NextEvent) then
		if (!self.SentForNextEvent) then
			self.SentForNextEvent = true
			RunConsoleCommand( "td_geteventinfo" )
		end
		return 0
	end
	
	return math.ceil( self.NextEvent - CurTime() )
end

local tmp = { "", Color( 0, 255, 0 ), "0", color_white, " minutes and ", Color( 0, 255, 0 ), "0", color_white, " seconds", "" }
function GM:strTimeTillNextEvent( appendtofront, appendtoback )
	local secs = self:TimeTillNextEvent()
	if (secs < 0) then return "Game is starting..." end
	local mins = math.floor( secs/60 )
	local secsleft = secs-(mins*60)
	tmp[1] = appendtofront
	tmp[3] = tostring( mins )
	if (mins == 1) then tmp[5] = " minute and " end
	if (mins == 0) then
		tmp[3] = ""
		tmp[5] = ""
	end
	tmp[7] = tostring( secsleft )
	tmp[10] = appendtoback
	return tmp
end