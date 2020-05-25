// ********************************
// * Tower Defense Gamemode - Game *
// ********************************
// towerselect.lua - The tower selection menu
 
local win, desc
 
local colGrey = Color( 50, 50, 50 )
local colLGrey = Color( 100, 100, 100 )
 
local seltower = 1
 
local function CreateBuildMenu()
	win = vgui.Create( "DPanel" )
	desc = vgui.Create( "DLabel" )
	desc:SetText( "" )
	function win:Paint()
		draw.RoundedBoxOutlined( 6, 0, 0, self:GetWide(), self:GetTall(), colTransBlue, color_white )
	end
	win:MakeIntoRow()
	local pns = {}
	for k, v in pairs( GAMEMODE.Towers ) do
		local up = v[5] or ""
		if (GAMEMODE:Has( up )) then
			local id = k
			local info = v
			local pn = vgui.Create( "DButton" )
			pns[ id ] = pn
			function pn:Paint()
				local col = colGrey
				if (self.Selected) then col = colLGrey end
				draw.RoundedBoxOutlined( 6, 0, 0, self:GetWide(), self:GetTall(), col, color_white )
			end
			function pn:DoClick()
				RunConsoleCommand( "td_selecttower", info[1] )
				if (pns[ seltower ] && pns[ seltower ]:IsValid()) then pns[ seltower ].Selected = false end
				seltower = id
				self.Selected = true
			end
			function pn:OnCursorEntered()
				desc:SetText( info[4] )
				desc:SizeToContents()
				desc:CenterHorizontal()
			end
			function pn:OnCursorExited()
				desc:SetText( "" )
			end
			pn:SetSize( ScrW()*0.1, ScrH()*0.1 )
			GAMEMODE:QuickLabelCentered( pn, 5, info[2] )
			GAMEMODE:QuickLabelCentered( pn, 25, "Cost: " .. info[3][1] )
			pn:SetText( "" )
			win:AddItem( pn )
			if (k == seltower) then pn.Selected = true end
		end
	end
	win.Padding = 5
	win:SizeToContents()
	win:PerformLayout()
	win:Center()
	win:SetVisible( false )
	local x, y = win:GetPos()
	desc:SetPos( 0, win:GetTall() + y + 5 )
end
 
concommand.Add( "+menu", function()
	if !win then CreateBuildMenu() end
	gui.EnableScreenClicker( true )
	win:SetVisible( true )
	desc:SetVisible( true )
end )
concommand.Add( "-menu", function()
	gui.EnableScreenClicker( false )
	win:SetVisible( false )
	desc:SetVisible( false )
end )