
// ********************************
// * Tower Defense Gamemode - Game *
// ********************************

--DeriveGamemode( "td2_gamebase" )
function LoadMenus( foldername )
		if (CLIENT) then include( "menus/towerselect.lua" ) end
		if (SERVER) then AddCSLuaFile( "menus/towerselect.lua" ) end
end

LoadMenus( "td2_game" )

GM.Name = "Tower Defense - Game"
GM.Author = "thomasfn"

function math.Deg2Rad(number)
	return math.rad(number)
end 

// ------------------------------------------------------------------------------------------------------------------
// CONFIGURABLE OPTIONS
// ------------------------------------------------------------------------------------------------------------------

function AddWave( MonsterType, Amount, SpawnDelay, WaveType, WaveLevel, Reward, CastleHeal )
	table.insert( GM.Waves, { MonsterType, Amount, SpawnDelay, WaveType, WaveLevel, Reward, CastleHeal } )
end

function AddTower( EntClass, TowerName, TowerCost, Description, UpgradeName, UpgradeLvl )
	if type( TowerCost ) != "table" then TowerCost = { TowerCost } end
	table.insert( GM.Towers, { EntClass, TowerName, TowerCost, Description or "", UpgradeName, UpgradeLvl } )
end

GM.Waves = {}
GM.Towers = {}
include("includes/modules/sh_towers.lua")

print("TOWERS")

require("sh_towers")

include( "GAMECONFIG.lua" )
if (SERVER) then AddCSLuaFile( "GAMECONFIG.lua" ) end

GameEvents = {
	{ 180, function()
		if ( CLIENT ) then
			
		end
		if ( SERVER ) then
			GAMEMODE:StartGame()
		end
	end }
}

// ------------------------------------------------------------------------------------------------------------------

function GM:GetTowerTable( name )
	for k, v in pairs( self.Towers ) do
		if (name == v[1]) then return v end
	end
end



function GM:ShouldCollide( enta, entb )
	if (enta:IsPlayer() && (entb.Base == "base_tower")) then return false end
	if (entb:IsPlayer() && (enta.Base == "base_tower")) then return false end
	if (enta:IsPlayer() && entb:IsPlayer()) then return false end
	if (enta:IsPlayer() && (entb.Base == "base_monster")) then return false end
	if (entb:IsPlayer() && (enta.Base == "base_monster")) then return false end
	if ((enta.Base == "base_monster") && (entb.Base == "base_monster")) then return false end
	return true
end

// ------------------------------------------------------------------------------------------------------------------
// ENUMS
// ------------------------------------------------------------------------------------------------------------------

	STATUS_OFFLINE = 0
	STATUS_ONLINE = 1
	STATUS_READY = 2
	STATUS_VOTING = 3
	STATUS_PREPARING = 4
	STATUS_INGAME = 5
	STATUS_GAMEOVER = 6

// ------------------------------------------------------------------------------------------------------------------
// EVENTS
// ------------------------------------------------------------------------------------------------------------------

	GameEvents = {}
	GameEventsStarted = false
	GameTimePassed = 0
	AllEventsFinished = false

// ------------------------------------------------------------------------------------------------------------------

GameTeams = {}
function CreateTeam( name, col, spawnpoints )
	local id = table.insert( GameTeams, { Name = name, Colour = col, Spawnpoints = spawnpoints } )
	team.SetUp( id, name, col )
	return id
end
TEAM_PLAYER = CreateTeam( "Players", Color( 128, 158, 128 ), { "info_player_start" } )

function math.Mid( a, b, dec )
	return a + (b-a)*dec
end

local Circle
function math.Circle()
	if (!Circle) then
		Circle = {}
		local cnt
		for cnt=1, 36 do
			Circle[ cnt ] = Vector( math.sin( cnt*10 ), math.cos( cnt*10 ), 0 )
		end
	end
	return Circle
end -- Is this even used?