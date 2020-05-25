
// ********************************
// * Tower Defense Gamemode - Game *
// *********************************
// sv_ai.lua - Loads serverside AI functionality

require( "td_ents" )

module( "td_ai", package.seeall )

local Waves = {}
local Session = {}
Session.WavesDefeated = {}
Session.BossesDefeated = {}
Session.MoneyWon = 0
Session.Flawless = true

local NBoss = 1

local gm = GM or GAMEMODE
if (gm.Waves) then Waves = gm.Waves end

local WaveID = 0
local Tracker = {}
local BreakPeriod = 10
local WaveInProgress = false
local SpawnInProgress = false

local CustomWave = false
local SUSPENDED = false

local SpawnMonsters, WaveEnded, SpawnNextWave

function SUSPEND()
	// Note: Once called, can't be reversed!!!
	SUSPENDED = true
	timer.Remove( "SpawnMonsters_Wave" .. WaveID )
	for _, ent in pairs( Tracker ) do
		if (ent && ent:IsValid()) then ent:Remove() end
	end
end

local function SpawnMonsters( monstertype, lvl )
	if (SUSPENDED) then return end
	local rts = td_ents.GetRoutes()
	local tmp = {}
	for name, _ in pairs( rts ) do
		local startpos = td_ents.GetNodePos( name, 0 )
		local ent = ents.Create( monstertype )
		ent:SetPos( startpos )
		ent:Spawn()
		if (ent.Monster && ent.Monster.Float) then
			ent:SetTargetZ( startpos.z + 16 )
		end
		ent:SetLevel( lvl )
		ent.RouteName = name
		ent.TargetID = 1
		table.insert( tmp, ent )
	end
	return tmp
end

local function SpawnNextWave()
	if (SUSPENDED) then return end
	WaveID = WaveID + 1
	local dat = Waves[ WaveID ]
	if (!dat) then return false end
	local cwav = WaveID
	local bosswave = false
	if (dat[4] == "BOSS") then bosswave = true end
	umsg.Start( "_wavestarted" )
		umsg.Short( cwav )
		umsg.String( dat[4] )
	umsg.End()
	GAMEMODE:SendWave( cwav )
	local typ = dat[1]
	if (type( typ ) == "table") then typ = table.Random( typ ) end
	local mrem = dat[2]
	local lvl = dat[5] or ""
	local globreward = dat[6]
	SpawnInProgress = true
	timer.Create( "SpawnMonsters_Wave" .. WaveID, dat[3], dat[2], function()
		local spawned = SpawnMonsters( typ, lvl )
		if (bosswave || globreward) then
			for _, ent in pairs( spawned ) do
				ent.IsBoss = bosswave
				ent.GlobalReward = globreward
			end
		end
		table.Add( Tracker, spawned )
		mrem = mrem - 1
		umsg.Start( "_Creeps" )
		umsg.Short( mrem )
		umsg.End()
		if (mrem == 0) then SpawnInProgress = false end
	end )
	WaveInProgress = true
	return true
end

local function DoWave()
	if (SUSPENDED) then return end
	if (CustomWave) then return end
	local result = SpawnNextWave()
	if (!result) then
		GAMEMODE:EndGame( true )
	end
end

local function WaveEnded( id )
	if (SUSPENDED) then return end
	local curwav = Waves[ id ]
	Session.WavesDefeated[ id ] = true
	/*if (curwav[ 6 ]) then
		GAMEMODE:GiveGlobalMoney( player.GetAll(), curwav[6] )
		Session.MoneyWon = Session.MoneyWon + curwav[6]
	end*/
	local castle = td_ents.GetCastle()
	if (castle && castle:IsValid() && (castle.HP < 100)) then Session.Flawless = false end
	if (curwav[ 7 ]) then td_ents.HealCastle( curwav[ 7 ] ) end
	if (!Waves[ id + 1 ]) then
		WaveInProgress = false
		GAMEMODE:EndGame( true )
		return
	end
	timer.Simple( BreakPeriod, DoWave )
	umsg.Start( "_nextwave" )
		umsg.Short( BreakPeriod )
	umsg.End()
	WaveInProgress = false
end

local function Tick()
	for k, v in pairs( Tracker ) do
		if ((!v) || (!v:IsValid()) || (!v.IsMonster)) then
			table.remove( Tracker, k )
			break
		end
	end
	if ((!SpawnInProgress) && WaveInProgress && (table.Count( Tracker ) == 0)) then
		WaveEnded( WaveID )
	end
end
hook.Add( "Tick", "SpawnMonsters_Track", Tick )

function StartEvents()
	SpawnNextWave()
end

function RunCustomWave( typ )
	if (WaveInProgress) then return end
	CustomWave = true
	umsg.Start( "_wavestarted" )
		umsg.Short( 0 )
		umsg.String( "CUSTOM" )
	umsg.End()
	GAMEMODE:SendWave( -1 )
	SpawnInProgress = true
	local mrem = 5
	timer.Create( "SpawnMonsters_WaveCustom", 1, 5, function()
		table.Add( Tracker, SpawnMonsters( typ ) )
		mrem = mrem - 1
		if (mrem == 0) then SpawnInProgress = false end
	end )
	WaveInProgress = true
end

concommand.Add( "td_debug_spawnmonster", function( pl, com, args )
	if (!pl:IsAdmin()) then return end
	SpawnMonsters( args[1], args[2] )
end )

local Diff = {
	Health = 0.35,
	Reward = 0.5,
	Sellback = 0.5
}
function CalculateDifficulty( id )
	local plcnt = #player.GetAll()
	return plcnt * Diff[ id ]
end

function GetTowerSellBackValue()
	if (!AllEventsFinished) then return 1 end
	if (!WaveInProgress) then return 1 end
	return Diff[ "Sellback" ]
end

function GetSession()
	local s = Session
	local castle = td_ents.GetCastle()
	s.CastleHealth = 0
	if (castle && castle:IsValid()) then s.CastleHealth = castle.HP end
	if (s.CastleHealth < 0) then s.CastleHealth = 0 end
	s.PlayerDamage = {}
	for _, ply in pairs( player.GetAll() ) do
		s.PlayerDamage[ ply:Nick() ] = (ply.TotalDamageDealt or 0)
	end
	return s
end

function BossDefeated( boss, globreward )
	Session.BossesDefeated[ boss ] = true
	if (globreward) then
		// GAMEMODE:GiveGlobalMoney( player.GetAll(), globreward )
		Session.MoneyWon = Session.MoneyWon + globreward
	end
end

function GetWaveID()
	return WaveID
end