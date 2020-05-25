
// ******************************
// * Tower Defense Gamemode Base *
// ******************************
// sv_player.lua - Loads serverside player functionality

--require( "glon" )
--_R = _R or {} 

local meta = FindMetaTable("Player")

function meta:SendNotice( txt )
	umsg.Start( "_notice", self )
	umsg.String( txt )
	umsg.End()
end

/*function meta:Reconnect( ip )
	umsg.Start( "_connect" )
	umsg.String( string.Replace( ip, "\"", "" ) )
	umsg.End()
end*/

function meta:GetMoney()
	return self._Money or 0
end

function meta:SetMoney( val )
	self._Money = val
	self:SetNWInt( "money", val )
end

function meta:HasMoney( amnt )
	return self:GetMoney() >= amnt
end

function meta:GiveMoney( amnt )
	self:SetMoney( self:GetMoney() + amnt )
end

function meta:TakeMoney( amnt )
	self:GiveMoney( -amnt )
end

function meta:HasUpgrade( name, lvl )
	/*if (!self.Upgrades) then self.Upgrades = {} end
	return (self.Upgrades[ name ] or 0) >= lvl*/
	return true
end

function meta:SendTrace( startpos, endpos )
	umsg.Start( "_trace", self )
		umsg.Vector( startpos )
		umsg.Vector( endpos )
	umsg.End()
end

function player.CallOnAll( funcname, ... )
	for _, ply in pairs( player.GetAll() ) do
		ply[ funcname ]( ply, ... )
	end
end

function GM:PlayerInitialSpawn( ply )
	ply:SetTeam( TEAM_PLAYER )
	ply:SetMoney( 30 )
	GameEventsStarted = true
end

function GM:SelectPlayerModel( ply )
	local gender = table.Random( { "male", "male", "female", "female2" } ) -- *is not being sexist*
	if (gender == "male") then return "models/player/Group01/male_0" .. math.random( 1, 9 ) .. ".mdl" end
	if (gender == "female") then return "models/player/Group01/Female_0" .. math.random( 1, 4 ) .. ".mdl" end
	// Stupid valve, fancy missing out Female_05
	if (gender == "female2") then return "models/player/Group01/Female_0" .. math.random( 6, 7 ) .. ".mdl" end
end

function GM:PlayerSpawn( ply )
	ply:SetWalkSpeed( 200 )
	if ply:HasUpgrade( "sprint", 1 ) then
		ply:SetRunSpeed( 500 )
	else
		ply:SetRunSpeed( 200 )
	end
	ply:SetModel( self:SelectPlayerModel( ply ) )
	self:SendEventInfo( ply )
end

function GM:SendEventInfo( ply )
	umsg.Start( "_timetillnextevent", ply )
		local TimeUntil = 0
		for id, tab in pairs( GameEvents ) do
			if (!tab[3]) then
				TimeUntil = tab[1]-GameTimePassed
				break
			end
		end
		umsg.Long( TimeUntil )
		umsg.Short( LastEvent )
	umsg.End()
end

concommand.Add( "td_geteventinfo", function( pl ) GAMEMODE:SendEventInfo( pl ) end )

function GM:AwardTeamMoney( amount )
	local cnt = #player.GetAll()
	local perhead = amount/cnt
	for _, ply in pairs( player.GetAll() ) do
		ply:GiveMoney( perhead )
	end
end

function GM:GiveGlobalMoney( ply, amount )
	/*if (type( ply ) != "table") then ply = { ply } end
	local pls = {}
	for _, pl in pairs( ply ) do
		table.insert( pls, pl:SteamID() )
		// pl:SendNotice( "You have been awarded " .. amount .. "!" )
	end
	gameserver.SendToLobby( "gs_plmoney", { table.concat( pls, "|" ), amount } )*/
end

function GM:GiveAward( ply, award )
	/*gameserver.SendToLobby( "gs_plaward", { ply:SteamID(), award } )*/
end

function GM:PlayerSwitchFlashlight( ply, b )
	return ply:HasUpgrade( "flashlight", 1 ) or (false or not b)
end