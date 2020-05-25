
// ********************************
// * Tower Defense Gamemode - Game *
// ********************************
// sh_towers.lua - Loads tower stat control functionality

require( "scripted_ents" )

print("Module -----------------------------")

		if (CLIENT) then
		module("sh_towers", package.seeall)
		print("Client Module -----------------------------")
		end
		if (SERVER) then
		module("sh_towers", package.seeall)
		print("Server Module -----------------------------")
		end




local StringBuilder = {}
setmetatable( StringBuilder, { __call = function() return StringBuilder:New() end } )
function StringBuilder:New()
	local o = {}
	o.String = {}
	setmetatable( o, {
		__index = self,
		__call = function() return table.concat( o.String, "\n" ) end
	} )
	return o
end
function StringBuilder:Append( str )
	table.insert( self.String, str )
end

local towers = {}
local sents = {}

function Register( class, lvl, tbl )
	towers[ class ] = towers[ class ] or {}
	tbl.Original = table.Copy( tbl )
	if (towers[ class ][ lvl-1 ]) then
		setmetatable( tbl, { __index = towers[ class ][ lvl-1 ] } )
	end
	towers[ class ][ lvl ] = tbl
	if (!sents[ class ]) then
		local ENT = {}
		ENT.Base = "base_tower"
		ENT.Type = "anim"
		ENT.PrintName = tbl.PrintName or "Gmod TD Tower"
		if (tbl.Animation) then ENT.AutomaticFrameAdvance = true end
		if (SERVER) then
			function ENT:SetupInfo( tower, level )
				for i=1, level do
					table.Merge( tower, towers[ class ][ i ] )
				end
			end
		end
		scripted_ents.Register( ENT, class, true )
		sents[ class ] = ENT
	end
end

function Get( class, lvl )
	return towers[ class ][ lvl or 1 ]
end

local compileKeys = {
	Delay = true,
	Damage = true,
	ShootNum = true,
	Cost = true,
	Range = true,
	FreezeTime = true,
	IgniteTime = true,
	IgniteDamage = true,
	SlowTime = true,
	SlowDamage = true
}

local function KVToString( key, value )
	if (key == "Delay") then
		local val = 10/value
		local rnd = math.Round( val )
		local rnded = ""
		if (rnd != val) then rnded = " (ON AVERAGE)" end
		return "Fire Rate: " .. tostring( rnd ) .. " shots per 10 seconds" .. rnded
	end
	if (key == "Damage") then
		if (value > 0) then return "Damage Per Shot: " .. tostring( value ) end
	end
	if (key == "ShootNum") then
		if (value > 1) then return "Shots Fired: " .. tostring( value ) end
	end
	if (key == "Cost") then
		return "Cost: " .. tostring( value )
	end
	if (key == "Range") then
		return "Range: " .. tostring( value ) .. " units"
	end
	if (key == "FreezeTime") then
		return "Freezes targets for " .. tostring( value ) .. " seconds"
	end
	if (key == "IgniteTime") then
		return "Ignites target for " .. tostring( value ) .. " seconds"
	end
	if (key == "IgniteDamage") then
		return "Deals " .. tostring( value ) .. " damage per second ignited"
	end
	if (key == "SlowTime") then
		return "Slows target for " .. tostring( value ) .. " seconds"
	end
	if (key == "SlowDamage") then
		return "Deals " .. tostring( value ) .. " damage per second slowed"
	end
end

function CompileDescription( class, sentence )
	local i = 0
	local str = StringBuilder()
	str:Append( sentence )
	for i=1, #towers[ class ] do
		local initialvalues = {}
		local tbl = towers[ class ][ i ].Original
		str:Append( "Level " .. tostring( i ) )
		for key, value in pairs( tbl ) do
			if (type( value ) == "Number") then
				if (!initialvalues[ key ]) then initialvalues[ key ] = value end
			end
			if (compileKeys[ key ]) then
				local compiled = KVToString( key, value )
				if (compiled) then
					if ((type( value ) == "Number") && initialvalues[ key ]) then
						compiled = compiled .. "(+" .. tostring( math.Round( (value-initialvalues[key])/initialvalues*100 ) ) .. "%)"
					end
					str:Append( " - " .. compiled )
				end
			end
		end
	end
	return str()
end