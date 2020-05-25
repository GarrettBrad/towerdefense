
// ******************************
// * Tower Defense Gamemode Base *
// ******************************
// cl_vgui.lua - Loads clientside VGUI stuff

local panelmeta = FindMetaTable( "Panel" )

function panelmeta:SnapToBottom( padding )
	local x, y = self:GetPos()
	self:SetPos( x, self:GetParent():GetTall() - self:GetTall() - padding )
end

function panelmeta:WedgeRight( target, padding )
	local x, y = self:GetPos()
	local tx, ty = target:GetPos()
	self:SetPos( tx + target:GetWide() + padding, y )
	self:SetSize( self:GetParent():GetWide() - (padding*2) - tx - target:GetWide(), self:GetTall() )
end

function panelmeta:HideToRight()
	local x, y = self:GetParent():GetSize()
	self:Center()
	local cx, cy = self:GetPos()
	self:SetPos( x, cy )
end

function panelmeta:HideToBottom()
	local x, y = self:GetParent():GetSize()
	self:Center()
	local cx, cy = self:GetPos()
	self:SetPos( cx, y )
end

function panelmeta:WhizzToCenter( time )
	local x, y = self:GetPos()
	self:Center()
	local tx, ty = self:GetPos()
	self:SetPos( x, y )
	self.WhizData = {
		StartX = x, StartY = y, EndX = tx, EndY = ty,
		Time = time,
		EndTime = CurTime() + time
	}
	if (self.Think && !self.OldThink) then self.OldThink = self.Think end
	self.Think = self.WhizzThink
end

function panelmeta:EndWhizz()
	local dat = self.WhizData
	if (dat) then
		self.WhizData = nil
		self:SetPos( dat.EndX, dat.EndY )
	end
end

local function Mid( a, b, dec )
	return a + ((b - a) * dec)
end

function panelmeta:WhizzThink()
	local dat = self.WhizData
	if (dat) then
		local t = math.Clamp( (dat.EndTime - CurTime()) / dat.Time, 1, 0 )
		self:SetPos( Mid( dat.StartX, dat.EndX, t ), Mid( dat.StartY, dat.EndY, t ) )
	else
		self:EndWhizz()
		return
	end
	if (self.OldThink) then self:OldThink() end
end

function panelmeta:MakeIntoRow()
	local panel = self
	panel.Items = {}
	function panel:AddItem( pn )
		table.insert( self.Items, pn )
		pn:SetParent( self )
	end
	function panel:PerformLayout()
		local padding = self.Padding
		local curw = padding
		for _, pn in pairs( self.Items ) do
			pn:SetPos( curw, padding )
			curw = curw + pn:GetWide() + padding
		end
	end
	function panel:SizeToContents()
		local padding = self.Padding or 0
		local curw = padding
		local curh = 0
		for _, pn in pairs( self.Items ) do
			curw = curw + pn:GetWide() + padding
			if (pn:GetTall() > curh) then curh = pn:GetTall() end
		end
		self:SetSize( curw, curh + (padding*2) )
	end
end

function GM:FadePanel( pn, fadestart, fadeend, fadecol )
	pn.OldPaint = pn.Paint
	fadecol = Color( fadecol.r, fadecol.g, fadecol.b, 255 )
	function pn:Paint()
		local w, h = self:GetSize()
		self:OldPaint()
		local dec = 0
		if (CurTime() > fadestart) then dec = (CurTime() - fadestart) / (fadeend - fadestart) end
		if (CurTime() > fadeend) then dec = 1 end
		fadecol.a = (1-dec)*255
		surface.SetDrawColor( fadecol )
		surface.DrawRect( 0, 0, w, h )
	end
end

function GM:CreateWindow( title, closable, draggable, xrat, yrat )
	local win = vgui.Create( "DFrame" )
	win:SetTitle( title )
	win:ShowCloseButton( closable )
	win:SetDraggable( draggable )
	win:SetSize( ScrW()*xrat, ScrH()*yrat )
	win:Center()
	win:MakePopup()
	return win
end

function GM:CreateForm( parent )
	local plist = vgui.Create( "DPanelList", parent )
	plist.Paint = function() end
	plist:SetSpacing( 5 )
	plist:SetPadding( 5 )
	plist.Rows = {}
	function plist:AddFormRow( name )
		local pn = vgui.Create( "DPanel" )
		pn.Paint = function() end
		local lbl = vgui.Create( "DLabel", pn )
		local txt = vgui.Create( "DTextEntry", pn )
		GAMEMODE:ApplyExtraFunctionality( txt )
		lbl:SetText( name .. ":" )
		function pn:PerformLayout()
			self:SetTall( 26 )
			lbl:SizeToContents()
			lbl:SetPos( 5, 0 )
			lbl:CenterVertical()
			txt:SetPos( 0, 3 )
			txt:WedgeRight( lbl, 5 )
		end
		self:AddItem( pn )
		self.Rows[ name ] = txt
	end
	function plist:GetFormValue( name )
		return self.Rows[ name ]:GetValue()
	end
	return plist
end

function GM:QuickLabel( parent, x, y, txt )
	local lbl = vgui.Create( "DLabel", parent )
	lbl:SetPos( x, y )
	lbl:SetText( txt )
	lbl:SizeToContents()
	return lbl
end

function GM:QuickLabelCentered( parent, y, txt )
	local lbl = vgui.Create( "DLabel", parent )
	lbl:SetPos( 0, y )
	lbl:SetText( txt )
	lbl:SizeToContents()
	lbl:CenterHorizontal()
	return lbl
end

function GM:QuickLabelFullyCentered( parent, txt )
	local lbl = vgui.Create( "DLabel", parent )
	lbl:SetText( txt )
	lbl:SizeToContents()
	lbl:Center()
	return lbl
end

local notice
function GM:CreateNotice( txt )
	if (notice && notice:IsValid()) then notice:Remove() end
	local pn = vgui.Create( "DPanel" )
	pn:SetSize( ScrW()*0.5, 30 )
	pn:SetPos( 0, ScrH()*0.05 )
	pn:CenterHorizontal()
	function pn:Paint()
		// GAMEMODE:DrawRoundedBox( 6, 0, 0, self:GetWide(), self:GetTall(), colTransBlue )
		draw.RoundedBoxOutlined( 6, 0, 0, self:GetWide(), self:GetTall(), colTransBlue, color_black )
	end
	self:QuickLabelFullyCentered( pn, txt )
	notice = pn
	return pn
end

local PANEL = {}
function PANEL:Paint()
	if (!self.Text) then self.Text = { "Label" } end
	if (!self.Font) then self.Font = "Default" end
	local w, h = draw.AdvancedText( self.Text, self.Font, 0, 0, self.Shadowed )
end
function PANEL:SizeToContents()
	if (!self.Text) then self.Text = {} end
	if (!self.Font) then self.Font = "Default" end
	local w, h = draw.AdvancedText( self.Text, self.Font, 0, 0, false, true )
	self:SetSize( w, h )
end
function PANEL:PerformLayout()
	self:SizeToContents()
end
vgui.Register( "TDLabel", PANEL, "PANEL" )