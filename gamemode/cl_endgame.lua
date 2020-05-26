
// ********************************
// * Tower Defense Gamemode - Game *
// ********************************
// cl_endgame.lua - Loads the end game sequence

--require( "datastream" )

local SessionData

function GM:ShowEndGame()
	
	local endgame = vgui.Create( "TDEndGame" )
	endgame:Setup( SessionData )
	
	local w, h = ScrW(), ScrH()
	endgame:SetPos( w*0.05, h*0.05 )
	endgame:SetSize( w*0.9, h*0.9 )
	
end

local function dsSession( len )
    SessionData = net.ReadTable()
    print("Game Ended Received Table")
end
net.Receive("TDDataStreamToClient", dsSession)


local colGreen = Color( 0, 255, 0 )
local colRed = Color( 255, 0, 0 )
local colBlue = Color( 0, 0, 255 )

local infWaves = { color_white, "Survived to wave ", colGreen, "0", Color( 0, 0, 255 ), " +0" }
local infBosses = {
	monster_headcrab = { color_white, "Headcrab Boss: ", colGreen, "Defeated", colBlue, " +0" },
	monster_fastheadcrab = { color_white, "Fast Headcrab Boss: ", colGreen, "Defeated", colBlue, " +0" },
	monster_ztorso = { color_white, "Torso Boss: ", colGreen, "Defeated", colBlue, " +0" },
	monster_zombie = { color_white, "Zombie Boss: ", colGreen, "Defeated", colBlue, " +0" },
	monster_fastzombie = { color_white, "Fast Zombie Boss: ", colGreen, "Defeated", colBlue, " +0" },
	monster_poisonzomb = { color_white, "Poison Zombie Boss: ", colGreen, "Defeated", colBlue, " +0" }
}
local infCastle = { color_white, "Remaining castle HP: ", colRed, "0", colBlue, " +0" }
local infWinnings = { color_white, "Total Winnings: ", colBlue, "0" }
local infFlawless = { color_white, "Flawless Victory: ", colRed, "No" }

local BossRewards = {
	monster_headcrab = 10,
	monster_fastheadcrab = 20,
	monster_ztorso = 30,
	monster_zombie = 40,
	monster_fastzombie = 50,
	monster_poisonzomb = 60
}

local function QuickLabel( txt, showin )
	local lbl = vgui.Create( "TDLabel" )
	lbl.Text = txt
	lbl.Font = "ScoreboardSub"
	GAMEMODE:FadePanel( lbl, CurTime() + showin, CurTime() + showin + 1, color_black )
	return lbl
end


local PANEL = {}
function PANEL:Setup( sessiondata )
	// Store the session
	if not sessiondata then return end -- If the clients ping is to high will be nil

	self.Session = sessiondata
	
	// Wave Info
	local waves = sessiondata.WavesDefeated
	local waveid = table.maxn( waves )
	infWaves[ 4 ] = tostring( waveid )
	infWaves[ 6 ] = " +" .. tostring( waveid )
	local lblWaves = QuickLabel( infWaves, 0 )
	
	// Left panel list
	local left = vgui.Create( "DPanelList", self )
	left:SetPadding( 5 )
	left:SetSpacing( 5 )
	left:EnableHorizontal( false )
	left:EnableVerticalScrollbar( true )
	left.Paint = function() 
		local w, h = self:GetSize()
	left:SetPos( 5, 45 )
	left:SetSize( w*0.5 - 8, h-50 )
	end
	
	left:AddItem( lblWaves )
	
	local totalMoney = waveid
	
	// Bosses
	local i = 0
	local bosses = sessiondata.BossesDefeated
	for class, txt in pairs( infBosses ) do
		i = i + 1
		local def = bosses[ class ]
		
		if (!def) then
			txt[3] = colRed
			txt[4] = "NOT Defeated"
		else
			local money = BossRewards[ class ]
			txt[6] = " +" .. tostring( money )
			totalMoney = totalMoney + money
		end
		
		local lblBoss = QuickLabel( txt, i )
		left:AddItem( lblBoss )
	end
	
	if (sessiondata.CastleHealth && (sessiondata.CastleHealth > 0)) then
		infCastle[3] = colGreen
		infCastle[4] = tostring( sessiondata.CastleHealth )
		infCastle[6] = " +" .. sessiondata.CastleHealth
		totalMoney = totalMoney + sessiondata.CastleHealth
	end
	local lblCastleHP = QuickLabel( infCastle, i + 1 )
	left:AddItem( lblCastleHP )
	
	if (sessiondata.Flawless) then
		infFlawless[3] = colGreen
		infFlawless[4] = "Yes"
	end
	local lblFlawless = QuickLabel( infFlawless, i + 2 )
	left:AddItem( lblFlawless )
	
	infWinnings[4] = tostring( totalMoney )
	local lblWinnings = QuickLabel( infWinnings, i + 3 )
	left:AddItem( lblWinnings )
	
	local right = vgui.Create( "DPanelList", self )
	right:SetPadding( 5 )
	right:SetSpacing( 5 )
	right:EnableHorizontal( false )
	right:EnableVerticalScrollbar( true )
	right.Paint = function(p, w, h)
		right:SetPos( w*0.5 + 3, 45 )
		right:SetSize( w*0.5 - 8, h-50 )
	end
	
	i = 1
	for name, damage in pairs( sessiondata.PlayerDamage ) do
		local tmp = { colBlue, name, color_white, " dealt ", colGreen, tostring( damage ), color_white, " damage" }
		local lblPl = QuickLabel( tmp, i )
		right:AddItem( lblPl )
		i = i + 1
	end
	
	self.LeftP = left
	self.RightP = right
	

end
function PANEL:Paint(w, h)
	local BTL = GAMEMODE.BackToLobby
	if (BTL) then
		local timeleft = tostring( math.Round( BTL - CurTime() ) )
		draw.SimpleText( timeleft, "ScoreboardHead", w*0.5, h*0.8, color_white, 1, 1 )
	end
	draw.SimpleText( "Tower Defense - Game Over", "ScoreboardHead", w*0.5, 0, color_white, 1, TEXT_ALIGN_TOP )
end
function PANEL:InvalidateLayout()

end
vgui.Register( "TDEndGame", PANEL, "PANEL" )
