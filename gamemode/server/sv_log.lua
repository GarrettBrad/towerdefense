
// ********************************
// * Tower Defense Gamemode - Game *
// *********************************
// sv_log.lua - Loads serverside logging functionality

module( "log", package.seeall )

local LogDir = "towerdefense/logs/"

local SessionID = 0
if (file.Exists( "sessionid.txt" )) then SessionID = tonumber( file.Read( "sessionid.txt" ) ) or 0 end
file.Write( "sessionid.txt", tostring( SessionID + 1 ) )

local Cache = {}

function Write( id, msg )
	local name = "session" .. tostring( SessionID ) .. "/" .. id
	local old = Cache[ name ]
	if (!old) then
		old = file.Read( LogDir .. name .. ".txt" )
		Cache[ name ] = old
	end
	local message = "[" .. os.date() .. "] " .. msg .. "\n"
	local new = (old or "") .. message
	Cache[ name ] = new
	file.Write( LogDir .. name .. ".txt", new )
	if (SinglePlayer()) then print( message ) end
end