
// ******************************
// * Tower Defense Gamemode Base *
// ******************************
// cl_gui.lua - Loads clientside user interface

colTransBlue = Color( 0, 157, 217, 150 )

function GM:ForceDermaSkin()
	return "td_skin"
end

function draw.AdvancedText( text, font, x, y, shadowed, NODRAW )
	if (type( text ) != "table") then text = { text } end
	local cnt, col = 0, color_white
	surface.SetFont( font )
	local curw, curh = 0, 0
	for cnt=1, #text do
		local t = text[ cnt ]
		if (type( t ) == "table") then
			col = t
		else
			t = tostring( t )
			local tw, th = surface.GetTextSize( t )
			curh = th
			if (!NODRAW) then
				if (shadowed) then draw.SimpleText( t, font, x+curw+1, y+1, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP ) end
				draw.SimpleText( t, font, x+curw, y, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			end
			curw = curw + tw
		end
	end
	return curw, curh
end