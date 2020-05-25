
// ***********************
// * DeathRun - by thomasfn *
// ***********************
// cl_chat.lua - Inits clientside chatbox

function GM:InitChatbox()
	tdchat.Init()
end

function GM:StartChat()
	tdchat.Show()
	return true
end

function GM:FinishChat()
	tdchat.Hide()
end

function GM:ChatTextChanged( text )
	tdchat.UpdateChat( text )
end

local function FormulateColour( col )
	local r = tostring( col.r )
	local g = tostring( col.g )
	local b = tostring( col.b )
	return r .. "|" .. g .. "|" .. b
end

function GM:ChatText( id, name, text, messagetype, norep )
	// print( id, name, text, messagetype, norep )
	if (!norep) && (messagetype != "none") then
		text = string.Replace( text, "[", "{" )
		text = string.Replace( text, "]", "}" )
	end
	if (messagetype == "chat") then
		local ply = id
		if (type( id ) == "number") then ply = player.GetByID( id ) end
		local teamid = ply:Team()
		local teamcol = team.GetColor( teamid )
		local tag = ""
		if (ply:GetNWBool( "IsDonator" )) then tag = "[c=0|150|0]<VIP> " end
		if (ply:IsAdmin()) then tag = "[c=255|0|0]<Admin> " end
		if (ply:IsSuperAdmin()) then tag = "[c=0|0|150]<SuperAdmin> " end
		local col = FormulateColour( teamcol )
		local chat = tag .. "[c=" .. col .. "]" .. name .. ":[c=white] " .. text
		tdchat.AddText( chat )
	end
	if (messagetype == "none") then
		local chat = "[c=150|0|0]" .. text
		// print( "adding text!" )
		tdchat.AddText( chat )
	end
	if (messagetype == "joinleave") then
		local chat = "[c=0|150|0]" .. text
		tdchat.AddText( chat )
	end
end

function GM:OnPlayerChat( ply, text, msgtype, alive )
	local t = text
	if (!alive) then t = "[c=255|0|0]*DEAD*" .. text end
	self:ChatText( ply, ply:Nick(), t, msgtype, true )
end

hook.Add( "HUDPaint", "DrawChat", function()
	if (tdchat.IsOpen) then
		tdchat.DrawChat( 6 )
	else
		tdchat.DrawChat( 4 )
	end
end )