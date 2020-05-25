
// ******************************
// * Tower Defense Gamemode Base *
// ******************************
// cl_hud.lua - Loads clientside heads up display

local red = Color( 255, 0, 0 )
local green = Color( 0, 255, 0 )
local awhite = Color( 255, 255, 255, 100 )
function GM:DrawBar( x, y, w, h, dec, forecol, bgcol )
	forecol = forecol or green
	bgcol = bgcol or red
	surface.SetDrawColor( bgcol )
	surface.DrawRect( x, y, w, h )
	surface.SetDrawColor( forecol )
	surface.DrawRect( x, y, w*dec, h )
	surface.SetDrawColor( awhite )
	surface.DrawRect( x, y, w, h*0.45 )
end

function GM:DrawCBar( x, y, w, h, ... )
	self:DrawBar( x-(w*0.5), y-(h*0.5), w, h, ... )
end

local temp = Color( 0, 0, 0, 255 )
function surface.Fade( cola, colb, dec )
	temp.r = math.Mid( cola.r, colb.r, dec )
	temp.g = math.Mid( cola.g, colb.g, dec )
	temp.b = math.Mid( cola.b, colb.b, dec )
	return temp
end

local matUpperLeft = surface.GetTextureID( "gui/td/upperleft-rounded-bordered" )
local matUpperRight = surface.GetTextureID( "gui/td/upperright-rounded-bordered" )
local matRoundedCorner = surface.GetTextureID( "gui/td/rounded-corner" )
local matEdge = surface.GetTextureID( "gui/td/left-edge" )

function GM:DrawUpperLeftBox( size, col )
	surface.SetDrawColor( col )
	surface.SetTexture( matUpperLeft )
	surface.DrawTexturedRect( 0, 0, size, size )
end

function GM:DrawUpperRightBox( size, col )
	local w = ScrW()
	
	surface.SetDrawColor( col )
	surface.SetTexture( matUpperRight )
	surface.DrawTexturedRect( w*0.85, 0, size, size )
end

function GM:DrawRoundedBox( border, x, y, w, h, col )
	surface.SetDrawColor( col )
	
	x = math.Round( x )
	y = math.Round( y )
	w = math.Round( w )
	h = math.Round( h )

	surface.DrawRect( x+border, y, w-(border*2), h )
	surface.DrawRect( x, y+border, border, h-(border*2) )
	surface.DrawRect( x-border, y+border, border, h-(border*2) )
	
	surface.SetTexture( matRoundedCorner )
	surface.DrawTexturedRectRotated( x + border/2 , y + border/2, border, border, 0 )
	surface.DrawTexturedRectRotated( x + w - border/2 , y + border/2, border, border, 270 )
	surface.DrawTexturedRectRotated( x + w - border/2 , y + h - border/2, border, border, 180 )
	surface.DrawTexturedRectRotated( x + border/2 , y + h -border/2, border, border, 90 )
	
	surface.SetTexture( matEdge )
	surface.DrawTexturedRectRotated( x + 2, y + (h * 0.5), 4, h-(border*2), 0 )
	surface.DrawTexturedRectRotated( x + w - 2, y + (h * 0.5), 4, h-(border*2), 180 )
	surface.DrawTexturedRectRotated( x + (w * 0.5), y + 2, w-(border*2), 4, 90 )
	surface.DrawTexturedRectRotated( x + (w * 0.5), y + h - 2, w-(border*2), 4, 270 )
end

function GM:DrawInfoLabel( x, y, txt, padding, font, bgcol, txtcol )
	if (type( txt ) != "table") then txt = { txt } end
	surface.SetFont( font )
	local curw = 0
	local curh = 0
	local FH = draw.GetFontHeight( font )
	for _, str in pairs( txt ) do
		local tw, th = surface.GetTextSize( str )
		if (tw > curw) then curw = tw end
		curh = curh + th + padding
	end
	// self:DrawRoundedBox( 6, x-((curw+padding)*0.5), y-(curh*0.5), curw + padding, curh, bgcol )
	draw.RoundedBoxOutlined( 6, x-((curw+padding)*0.5), y-(curh*0.5), curw + padding, curh, bgcol, color_white )
	local cnt, cch = 0, curh
	curh = 0
	for cnt=1, #txt do
		draw.SimpleText( txt[ cnt ], font, x, y-(cch*0.5) + curh + (padding*0.5), txtcol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		curh = curh + FH
	end
end


local HideHUD = {
	CHudHealth = true,
	CHudCrosshair = true,
	CHudWeaponSelection = true
}
function GM:HUDShouldDraw( name )
	if (HideHUD[ name ]) then return false end
	return true
end