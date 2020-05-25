
// ********************************
// * Tower Defense Gamemode - Game *
// ********************************
// sv_entities.lua - Loads serverside entities

local meta = FindMetaTable( "Entity" )

-- Legacy Function // Used by the original creators
function NullEntity()
	return NULL
end

function meta:GetCentralPos()
	local offset = self._OFFSET
	if (!offset) then
		offset = (self:OBBMins() + self:OBBMaxs())*0.5
		self._OFFSET = offset
	end
	return self:GetPos() + offset
end

require( "scripted_ents" )
if (!scripted_ents) then 
	print("MISSING scripted_ents !!!!!!!!!!!!!!!!!!!!")
	return
end

local function RegisterPointEntity( class, tab )
	scripted_ents.Register( tab or {
		Type = "point",
		Base = "base_point",
		KeyValue = function( ent, key, val )
			ent.Data = ent.Data or {}
			ent.Data[ key ] = val
		end }, 
		class, 
		true )
end

local function RegisterBrushEntity( class, tab )
	scripted_ents.Register( tab or {
		Type = "brush",
		Base = "base_brush"
	}, class, true )
end

RegisterPointEntity( "info_castle" )
RegisterPointEntity( "info_cave" )
RegisterPointEntity( "info_ainode" )

RegisterBrushEntity( "func_nobuild" )

module( "td_ents", package.seeall )

local castle = NullEntity()
local castle_ent, castlepos
local caves = {}
local nodes = {}

local Routes = {}
local RouteNames = {}

local function IsValidEnt( ent )
	return ent && ent:IsValid()
end

local function CacheRelevantInfo()
	caves = ents.FindByClass( "info_cave" )
	nodes = ents.FindByClass( "info_ainode" )
	castle = ents.FindByClass( "info_castle" )[1] or NullEntity()

	castlepos = castle:GetPos()
	SetGlobalVector( "castle_pos", castlepos )
	
	if (!castle:IsValid()) then
		ErrorNoHalt( "** MAP HAS NO info_castle ENTITY! **\n" )
		return
	end

	for _, ent in pairs( caves ) do
		local name = ent.Data.routename
		local tmp = {}
		tmp.Nodes = {}
		tmp.Start = ent:GetPos()
		tmp.End = castle:GetPos()
		tmp.Name = name
		for _, node in pairs( nodes ) do
			local rname = node.Data.routename
			if (rname == name) then
				local id = tonumber( node.Data.nodeid )
				tmp.Nodes[ id ] = node:GetPos()
			end
		end
		table.insert( RouteNames, name )
		Routes[ name ] = tmp
	end
end

function GetCastle()
	return castle_ent
end

function GetCastlePos()
	return castlepos
end

function HealCastle( amount )
	GetCastle():Heal( amount )
end

function IsInRangeOfCastle( ent )
	if ((!castle) || (!castle:IsValid())) then return end
	return (ent:GetPos() - castle:GetPos()):Length() <= 32
end

local function InitPostEntity()
	CacheRelevantInfo()
	if (castle && castle:IsValid()) then
		local ent = ents.Create( "castle" )
		ent:SetPos( castle:GetPos() )
		ent:Spawn()
		castle_ent = ent
	end
end
hook.Add( "InitPostEntity", "ENTS:Init", InitPostEntity )

function GetRoutes()
	return Routes
end

local origin = Vector( 0, 0, 0 )
function GetNodePos( routename, id )
	local r = Routes[ routename ]
	if (!r) then return origin end
	if (id == 0) then return r.Start end
	if (id > #r.Nodes) then return r.End end
	return r.Nodes[ id ]
end

local PathLength

function GetPathLength()
	if (PathLength) then return PathLength end
	local routename = RouteNames[ 1 ]
	if (!routename) then return 0 end
	local route = Routes[ routename ]
	if (!route) then return 0 end
	local length = 0
	local pos = route.Start
	local cnt
	for cnt=1, #route.Nodes do
		local nodepos = route.Nodes[ cnt ]
		length = length + (nodepos-pos):Length()
	end
	length = length + (route.End - pos):Length()
	PathLength = length
	return length
end