
// ***********************
// * DeathRun - by thomasfn *
// ***********************
// cl_chatbox.lua - Loads clientside chatbox

tdchat = {}

tdchat.Lines = {}
tdchat.Font = "ChatFont"

tdchat.Cols = {
	white = color_white,
	black = color_black,
	red = Color( 255, 0, 0 ),
	green = Color( 0, 255, 0 ),
	blue = Color( 0, 0, 255 )
}

function tdchat.Init()
	surface.CreateFont( "Arial", 12, 500, true, false, "ChatFont" )
	
	local w, h = ScrW(), ScrH()
	
	local tb = vgui.Create( "DTextEntry" )
	tb:SetMultiline( false )
	tb:SetEditable( false )
	tb:SetVisible( false )
	tb:SetPos( w*0.02, h*0.8 )
	tb:SetSize( w*0.3, 20 )
	
	tdchat.TextBox = tb
end

function tdchat.Show()
	local tb = tdchat.TextBox
	tb:SetVisible( true )
	gui.EnableScreenClicker( true )
	tdchat.IsOpen = true
end

function tdchat.Hide()
	local tb = tdchat.TextBox
	tb:SetVisible( false )
	gui.EnableScreenClicker( false )
	tdchat.IsOpen = false
end

function tdchat.UpdateChat( text )
	local tb = tdchat.TextBox
	tb:SetText( text )
end

function tdchat.AddText( text )
	local line = tdchat.Parse( text )
	table.insert( tdchat.Lines, line )
end

function tdchat.Parse( text )
	local tmp = {}
	local id
	local intag = false
	local content = ""
	for id=1, string.len( text ) do
		local char = string.sub( text, id, id )
		if (intag) then
			if (char == "]") then
				intag = false
				if (content != "") then table.insert( tmp, { "tag", content } ) end
				content = ""
			else
				content = content .. char
			end
		else
			if (char == "[") then
				intag = true
				if (content != "") then table.insert( tmp, { "text", content } ) end
				content = ""
			else
				content = content .. char
			end
		end
	end
	if (!intag) && (content != "") then table.insert( tmp, { "text", content } ) end
	tdchat.ParseLine( tmp )
	return tmp
end

function tdchat.ParseLine( line )
	for _, v in pairs( line ) do
		if (v[1] == "tag") then
			if (string.find( v[2], "=" )) then
				local temp = string.Explode( "=", v[2] )
				if (temp[1] == "c") then
					v[1] = "col"
					v[2] = tdchat.GetCol( temp[2] )
				end
				if (temp[1] == "fc") then
					v[1] = "fcol"
					v[2] = tdchat.GetCol( temp[2] )
				end
				if (temp[1] == "plstat") then
					v[1] = "plstat"
					v[2] = temp[2]
				end
				if (temp[1] == "fon") then
					v[1] = "fenable"
					v[2] = true
				end
				if (temp[1] == "foff") then
					v[1] = "fenable"
					v[2] = false
				end
			end
		end
		if (v[1] == "text") then
			v[2] = string.Replace( v[2], "{", "[" )
			v[2] = string.Replace( v[2], "}", "]" )
		end
	end
end

function tdchat.GetCol( name )
	local c = tdchat.Cols[ name ]
	if (c) then return c end
	if (string.find( name, "|" )) then
		local tab = string.Explode( "|", name )
		return Color( tonumber( tab[1] or "255" ), tonumber( tab[2] or "255" ), tonumber( tab[3] or "255" ) )
	end
	return color_white
end

local function mid( a, b, d )
	return a + ((b-a)*d)
end

local spare = Color( 0, 0, 0 )
function tdchat.FColor( a, b )
	local dec = math.sin( (CurTime()%3)/3 * 360 )
	spare.r = mid( a.r, b.r, dec )
	spare.g = mid( a.g, b.g, dec )
	spare.b = mid( a.b, b.b, dec )
	return spare
end

function tdchat.DrawLine( x, y, line, defcol )
	local cnt
	local cx = x
	local col = defcol
	local fcol = defcol
	local f_on = false
	surface.SetFont( tdchat.Font )
	for cnt=1, #line do
		local v = line[ cnt ]
		if (v[1] == "text") then
			local tw, th = surface.GetTextSize( v[2] )
			local acol = col
			if (f_on) then acol = tdchat.FColor( col, fcol ) end
			draw.SimpleText( v[2], tdchat.Font, cx, y, acol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			cx = cx + tw
		end
		if (v[1] == "col") then col = v[2] end
		if (v[1] == "fcol") then fcol = v[2] end
		if (v[1] == "fenable") then f_on = v[2] end
	end
end

function tdchat.DrawChat( maxlines )
	local cnt = math.Clamp( #tdchat.Lines - maxlines, 0, #tdchat.Lines )
	local i
	surface.SetFont( tdchat.Font )
	local tw, th = surface.GetTextSize( "deathrun iz cool" )
	local cy = (ScrH() * 0.8) - (th * (maxlines+1))
	if (tdchat.IsOpen) then
		surface.DrawRoundedPanel( ScrW()*0.015, cy - (ScrH()*0.005), ScrW()*0.36, (th * (maxlines+1)) + 30 )
	end
	for i=cnt, #tdchat.Lines do
		local line = tdchat.Lines[ i ]
		if (line) then
			tdchat.DrawLine( ScrW()*0.02, cy, line, color_white )
			cy = cy + th
		end
	end
end