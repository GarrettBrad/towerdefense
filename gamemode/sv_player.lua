
// ********************************
// * Tower Defense Gamemode - Game *
// ********************************
// sv_player.lua - Loads serverside player functionality

-- Calls base PlayerInitSpawn
-- Gives the player their starting money
function GM:PlayerInitialSpawn( ply )
	self.BaseClass.PlayerInitialSpawn( self, ply )
	ply:GiveMoney( self.StartMoney )
end

-- I don't even know why they have this
local function BoolToString( b )
	if ( b ) then return "1" else return "0" end
end

function GM:PlayerSpawn( ply )
	self.BaseClass.PlayerSpawn( self, ply )
	ply:Give( "weapon_tdbuild" )

	self:SendUpgrades( ply, false )
end

function GM:SendUpgrades( ply, reopenmenu )
	local tosend = {}
	for _, tab in pairs( self.Towers ) do
		local up = tab[5] or ""
		local val = tab[6] or 0
		// ply:SetNWBool( "tdhas_" .. up, ply:HasUpgrade( up, val ) )
		table.insert( tosend, up .. "=" .. BoolToString( ply:HasUpgrade( up, val ) ) )
	end
	local str = table.concat( tosend, "," )
	umsg.Start( "_upgrades", ply )
		umsg.String( str )
		umsg.Bool( reopenmenu )
	umsg.End()
end
concommand.Add( "td_refreshupgrades", function( pl ) GAMEMODE:SendUpgrades( pl, true ) end )

function GM:PlayerDisconnected( ply )
	if (self.VoteEnded) then return end
	--self.PlayersLeft = math.Clamp( self.PlayersLeft - 1, 0, self.PlayersLeft )
	self:UpdateVote()
end

function GM:ShowSpare1( ply )
	if (self.VoteEnded) then return end
	if (ply.VoteStarted) then
		ply:ChatPrint( "You have already voted to start!" )
		return
	end
	ply.VoteStarted = true
	--self.PlayersLeft = self.PlayersLeft - 1
	self:UpdateVote()
	umsg.Start( "_youvoted" )
	umsg.End()
end

function GM:UpdateVote()
GAMEMODE:StartGame()
	--if (self.PlayersLeft <= 0) then
		--self:SkipToNextEvent()
		--self.VoteEnded = true
	--[[else
		umsg.Start( "_playersleft" )
			umsg.Short( self.PlayersLeft )
		umsg.End()
	end]]
end
function GM:SkipToNextEvent()
	local trig = 0
	for id, tab in pairs( GameEvents ) do
		if (tab[3]) then trig = trig + 1 end
		if (!tab[3]) then
			tab[3] = true
			tab[2]()
			umsg.Start( "_event" )
			umsg.Short( id )
			umsg.End()
			self.LastEvent = id
			trig = trig + 1
			GameTimePassed = tab[1]
			break
		end
	end
	if (trig == #GameEvents) then AllEventsFinished = true end
end

function GM:SpawnTower( classname, pos, normal, ply )
	local ent = ents.Create( classname )
	ent:SetAngles( normal:Angle():Up():Angle() )
	ent:Spawn()

	local obbmins = ent:OBBMins()
	ent:SetPos( pos - (obbmins.z * normal) )
	ent.Owner = ply

	if (!ply.TowerCount) then 
		ply.TowerCount = 0 
	end

	ply.TowerCount = ply.TowerCount + 1
	ply:SetNWInt( "td_tcnt", ply.TowerCount )
	ent:SetNWEntity( "owner", ply )

	return ent
end


local function SpawnEntity( trace, classname )
	return GAMEMODE:SpawnTower( classname, trace.HitPos, trace.HitNormal )
end

concommand.Add( "td_debug_spawn", function( pl, com, args )
	if (!pl:IsAdmin()) then return end
	local ent = SpawnEntity( util.TraceLine( {
		start = pl:GetShootPos(),
		endpos = pl:GetShootPos() + (pl:GetCursorAimVector() * 4096),
		filter = pl
	} ), args[1] );
	if (args[2]) then ent:SetModel( "models/" .. args[2] ) end
end )

concommand.Add( "td_selecttower", function( pl, com, args )
	for k, v in pairs( GAMEMODE.Towers ) do
		if (v[1] == args[1]) then
			pl.TowerName = v[1]
			// pl:ChatPrint( "Changed to " .. v[2] .. "!" )
			return
		end
	end
	pl:ChatPrint( "Invalid tower!" )
end )