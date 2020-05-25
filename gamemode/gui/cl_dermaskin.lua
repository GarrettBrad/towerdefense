
// ******************************
// * Tower Defense Gamemode Base *
// ******************************
// cl_dermaskin.lua - Loads clientside derma skin

local SKIN = {}

local texOutlinedCorner = surface.GetTextureID( "gui/td/rounded-corner" )

/*---------------------------------------------------------
    Name: RoundedBox( bordersize, x, y, w, h, color )
    Desc: Draws a rounded box - ideally bordersize will be 8 or 16
   Usage: color is a table with r/g/b/a elements
---------------------------------------------------------*/
function draw.RoundedBoxOutlined( bordersize, x, y, w, h, color, bordercol )

	x = math.Round( x )
	y = math.Round( y )
	w = math.Round( w )
	h = math.Round( h )

	draw.RoundedBox( bordersize, x, y, w, h, color )
	
	surface.SetDrawColor( bordercol )
	
	surface.SetTexture( texOutlinedCorner )
	surface.DrawTexturedRectRotated( x + bordersize/2 , y + bordersize/2, bordersize, bordersize, 0 ) 
	surface.DrawTexturedRectRotated( x + w - bordersize/2 , y + bordersize/2, bordersize, bordersize, 270 ) 
	surface.DrawTexturedRectRotated( x + w - bordersize/2 , y + h - bordersize/2, bordersize, bordersize, 180 ) 
	surface.DrawTexturedRectRotated( x + bordersize/2 , y + h -bordersize/2, bordersize, bordersize, 90 ) 
	
	surface.DrawLine( x+bordersize, y, x+w-bordersize, y )
	surface.DrawLine( x+bordersize, y+h-1, x+w-bordersize, y+h-1 )
	
	surface.DrawLine( x, y+bordersize, x, y+h-bordersize )
	surface.DrawLine( x+w-1, y+bordersize, x+w-1, y+h-bordersize )

end

local colTransA = Color( 120, 120, 120, 80 )
local colTransB = Color( 120, 120, 120, 120 )
local colGrey = Color( 128, 128, 128 )
local colBlue = Color( 0, 153, 255 )
local colDarkBlue = Color( 0, 0, 153 )
function SKIN:PaintFrame( frame )
	local w, h = frame:GetSize()
	draw.RoundedBoxOutlined( 8, 5, 0, w-10, h-5, colGrey, color_white )
	draw.RoundedBoxOutlined( 8, 0, 0, w, 30, colBlue, color_white )
end

function SKIN:PaintButton( button )
	local w, h = button:GetSize()
	local col = colTransA
	if (button.Hovered) then col = colTransB end
	draw.RoundedBoxOutlined( 8, 0, 0, w, h, col, colDarkBlue )
end

derma.DefineSkin( "td_skin", "Tower Defense Skin", SKIN, "Default" )