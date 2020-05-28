
// ********************************
// * Tower Defense Gamemode - Game *
// ********************************
// cl_hud.lua - Loads clientside heads up display

local FadeStatus = 0
local FadeTimeEnd = 0

local BarRelativeHeight = 0.04

local HUDLabel1, HUDLabel2, HUDLabel3, HUDLabel4

surface.CreateFont("ScoreboardSub", {
	font = "coolvetica",
	size = 20,
	weight = 400,
	antialias = true,
} )
	
function GM:InitGUI()
	local lbl = vgui.Create( "TDLabel" )
	lbl.Shadowed = true
	lbl.Font = "ScoreboardSub"
	lbl.Text = {}
	lbl:SetPos( 5, 5 )
	HUDLabel1 = lbl
	
	lbl = vgui.Create( "TDLabel" )
	lbl.Shadowed = true
	lbl.Font = "ScoreboardSub"
	lbl.Text = { color_white, "Money: ", Color( 0, 255, 0 ), "999" }
	lbl:SizeToContents()
	lbl:SetPos( 5, 5 )
	HUDLabel2 = lbl
	
	lbl = vgui.Create( "TDLabel" )
	lbl.Shadowed = true
	lbl.Font = "ScoreboardSub"
	lbl.Text = { color_white, "Towers: ", Color( 0, 255, 0 ), "999" }
	lbl:SizeToContents()
	lbl:SetPos( 5, 5 + HUDLabel2:GetTall() )
	HUDLabel3 = lbl
	
	lbl = vgui.Create( "TDLabel" )
	lbl.Shadowed = true
	lbl.Font = "ScoreboardSub"
	lbl.Text = { color_white, "Creeps: ", Color( 0, 255, 0 ), "999" }
	lbl:SizeToContents()
	lbl:SetPos( ScrW()*0.88, 5 )
	HUDLabel4 = lbl
	
end

local tblWaveProgress = { color_white, "Wave ", Color( 0, 255, 0 ), "1", color_white, " in progress!" }
local tblNextWave = { color_white, "Next wave in ", Color( 0, 255, 0 ), "1", color_white, " seconds!" }

local BLANKTABLE = {}
function GM:GUIThink()
	if (self.GameEnded) then return end
	if (GameEvents[1][3]) then
		if (self.WaveInProgress) then
			tblWaveProgress[4] = tostring( self.WaveID )
			HUDLabel1.Text = tblWaveProgress
		else
			local timeuntil = math.Round( self.NextWaveTime - CurTime() )
			if (timeuntil < 0) then timeuntil = 0 end
			tblNextWave[4] = tostring( timeuntil )
			HUDLabel1.Text = tblNextWave
		end
	else
		HUDLabel1.Text = self:strTimeTillNextEvent( "Game starts in ", "!" )
	end
	HUDLabel1:SizeToContents()
	HUDLabel1:CenterHorizontal()
end

local color_Black = Color( 0, 0, 0, 255 )
function GM:HUDPaint()
	// Tell our base class to paint
	self.BaseClass.HUDPaint( self )
	
	// Draw standard HUD stuff
	if (FadeStatus < 2) then
		self:DrawHUD()
		self:DrawEntityHealth()
	end
	
	// If it's game over, draw the end game sequence
	if (FadeStatus == 0) then
		if (self.GameEnded) then
			FadeStatus = 1
			FadeTimeEnd = CurTime() + 2
		end
	end
	if (FadeStatus == 1) then
		local alpha = 255-(255*((FadeTimeEnd-CurTime())/2))
		if (alpha >= 255) then
			FadeStatus = 2
			alpha = 255
		end
		color_Black.a = alpha
		surface.SetDrawColor( color_Black )
		surface.DrawRect( 0, 0, ScrW(), ScrH() )
	end
	if (FadeStatus == 2) then
		// RunConsoleCommand( "+score" )
		//  self:ShowEndGame()
		HUDLabel1:Remove()
		HUDLabel2:Remove()
		HUDLabel3:Remove()
		HUDLabel4:Remove()
		GAMEMODE:ShowEndGame()
		FadeStatus = 3
	end
	if (FadeStatus == 3) then
		surface.SetDrawColor( color_black )
		surface.DrawRect( 0, 0, ScrW(), ScrH() )
	end
end

local traces = {}
function GM:DrawHUD()
	// Draw the current wave info
	self:DrawWaveBar()
	
	// Draw player info
	self:DrawPlayerInfo()
	
	// Wavecounter
	self:DrawWaveCounter()
	
	// Traces
	local i
	surface.SetDrawColor( 255, 0, 0, 255 )
	local cnt = #traces
	for i=0, cnt-1 do
		local o = cnt-i
		local st = traces[ o ][1]
		local ed = traces[ o ][2]
		surface.DrawLine( st.x, st.y, ed.x, ed.y )
		traces[ o ] = nil
	end
end

local function umTrace( um )
	table.insert( traces, { um:ReadVector():ToScreen(), um:ReadVector():ToScreen() } )
end
usermessage.Hook( "_trace", umTrace )

local colDarkRed = Color( 150, 0, 0 )
local colDarkGreen = Color( 0, 150, 0 )
local colDarkBlue = Color( 0, 0, 150 )

local olddec = 0

local WaveFadeStatus = 0
local WaveFadeTime = 0

function printWaveStatus()
	print( WaveFadeStatus, WaveFadeTime-CurTime() )
end

function GM:DrawWaveBar()

	local w, h = ScrW(), ScrH()
	
	local curwave = self.WaveID
	if ((!curwave) || (curwave < 1)) then
		local str = "Press F3 to start the game!"
		if (self.LocalPlayerVoted) then
			local votesleft = self.VotesLeft
			if (!votesleft) then
				str = "Waiting for votes..."
			else
				str = tostring( votesleft ) .. " votes remaining..."
			end
		end
		draw.SimpleText( str, "ScoreboardSub", w*0.5 + 1, h*0.97 + 1, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		draw.SimpleText( str, "ScoreboardSub", w*0.5, h*0.97, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		return
	end
	
	local ypos = h
	local typos = h*(1-BarRelativeHeight-0.005)
	local col = colDarkGreen
	
	if (WaveFadeStatus == 0) then
		WaveFadeStatus = 1
		WaveFadeTime = CurTime() + 1
	end
	
	if (WaveFadeStatus == 1) then
		local dec = 1 - (WaveFadeTime-CurTime())
		if (dec >= 1) then
			WaveFadeStatus = 2
			dec = 1
		end
		ypos = math.Mid( ypos, typos, dec )
	end
	
	if (WaveFadeStatus == 2) then
		if (self.WaveInProgress) then
			WaveFadeStatus = 3
			WaveFadeTime = CurTime() + 1
		end
		col = colDarkGreen
		ypos = typos
	end
	
	if (WaveFadeStatus == 3) then
		local dec = 1 - (WaveFadeTime-CurTime())
		if (dec >= 1) then
			WaveFadeStatus = 4
			dec = 1
		end
		col = surface.Fade( colDarkGreen, colDarkBlue, dec )
		ypos = typos
	end
	
	if (WaveFadeStatus == 4) then
		if (!self.WaveInProgress) then
			WaveFadeStatus = 5
			WaveFadeTime = CurTime() + 1
		end
		col = colDarkBlue
		ypos = typos
	end
	
	if (WaveFadeStatus == 5) then
		local dec = 1 - (WaveFadeTime-CurTime())
		if (dec >= 1) then
			WaveFadeStatus = 2
			dec = 1
		end
		col = surface.Fade( colDarkBlue, colDarkGreen, dec )
		ypos = typos
	end

	
	local dec = (curwave-0.5) / #self.Waves
	if (self.GameEnded) then dec = 1 end
	local newdec = math.Mid( olddec, dec, 0.2 )
	olddec = newdec
	
	self:DrawBar( w*0.15, ypos, w*0.7, h*BarRelativeHeight, newdec, col, colDarkRed )
	local str = "Wave " .. tostring( curwave ) .. " of " .. tostring( #self.Waves )
	draw.SimpleText( str, "ScoreboardSub", w*0.5 + 1, ypos - (h*0.03) + 1, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	draw.SimpleText( str, "ScoreboardSub", w*0.5, ypos - (h*0.03), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
end

local colGreen = Color( 0, 255, 0 )
local colRed = Color( 255, 0, 0 )
function GM:DrawPlayerInfo()
	local w, h = ScrW(), ScrH()
	
	self:DrawUpperLeftBox( w*0.15, colTransBlue )
		
	local money = LocalPlayer():GetNWInt( "money" )
	HUDLabel2.Text[4] = tostring( math.floor( money ) )
	if (money > 0) then HUDLabel2.Text[3] = colGreen end
	if (money == 0) then HUDLabel2.Text[3] = colRed end
	
	local tcnt = LocalPlayer():GetNWInt( "td_tcnt" )
	HUDLabel3.Text[4] = tostring( tcnt )
	if (tcnt > 0) then HUDLabel3.Text[3] = colGreen end
	if (tcnt == 0) then HUDLabel3.Text[3] = colRed end
end

usermessage.Hook( "_Creeps", function( um ) Creeps = um:ReadShort() end )
function GM:DrawWaveCounter()
	local w, h = ScrW(), ScrH()

	self:DrawUpperRightBox( w*0.15, colTransBlue )
	
	Creeps = Creeps or 0
	HUDLabel4.Text[4] = tostring( Creeps or 0 )
	if (Creeps > 0) then HUDLabel4.Text[3] = colGreen end
	if (Creeps == 0) then HUDLabel4.Text[3] = colRed end
	
end

function GM:DrawEntityHealth()
	local w, h = ScrW(), ScrH()
	local elist = ents.GetAll()
	for _, ent in pairs( elist ) do
		if (ent && ent:IsValid() && ent.IsMonster) then
			if ((ent:GetPos() - LocalPlayer():GetPos()):Length() <= 256) then
				local pos = ent:GetPos():ToScreen()
				if (pos.x > 0) && (pos.x < w) && (pos.y > 0) && (pos.y < h) then
					self:DrawCBar( pos.x, pos.y, w*0.05, h*0.02, ent:GetHealth(), green, red )
				end
			end
		end
		if (ent && ent:IsValid() && ent.IsTower) then
			if ((ent:GetPos() - LocalPlayer():GetPos()):Length() <= 256) then
				local pos = Vector(ent:GetPos().x,ent:GetPos().y,ent:GetPos().z+25):ToScreen()
				if (pos.x > 0) && (pos.x < w) && (pos.y > 0) && (pos.y < h) then
					self:DrawCBar( pos.x, pos.y, w*0.05, h*0.02, ent:GetAmmo(), green, red )
				end
			end
		end
	end
	local castle = ents.FindByClass( "castle" )[1]
	if (castle && castle:IsValid()) then
		local pos = castle:GetPos():ToScreen()
		if (pos.x > 0) && (pos.x < w) && (pos.y > 0) && (pos.y < h) then
			self:DrawCBar( pos.x, pos.y, w*0.05, h*0.02, castle:GetHealth(), green, red )
		end		
	end
end