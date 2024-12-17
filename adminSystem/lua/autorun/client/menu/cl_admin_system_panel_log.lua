include( "autorun/sh_admin_system.lua" )

local PANEL = {}
PANEL.name = "Logs"

function PANEL:Init()
end

function PANEL:_Init()
	local buttonContainer = vgui.Create( "DPanel", self )
	buttonContainer:SetSize( self:GetWide(), self:GetTall() * 0.15 )
	buttonContainer:Dock( TOP )
	buttonContainer:DockMargin( 10, 0, 10, 0 )

	function buttonContainer:Paint( w, h )
	end

	local categoryCount = table.Count( LOG.categorizedmsg ) + 1

	self.selectedCategory = "Autre"
	self.totalMsgCount = #LOG.msg

	local resetBtn = self:CreateLogButton( "Reset", buttonContainer, categoryCount )
	resetBtn.WrappedDoClick = function( _self )
		self.logScrollPanel:Clear()

		for _, data in ipairs( LOG.msg ) do
			self:CreateLogLabel( data, self.logScrollPanel )
		end
	end

	timer.Simple( 0.2, function()
		if ( not IsValid( self.logScrollPanel ) ) then return end

		local vbar = self.logScrollPanel:GetVBar()
		vbar:SetScroll( vbar.CanvasSize )
	end )

	for category, data in pairs( LOG.categorizedmsg ) do
		self:CreateLogButton( category, buttonContainer, categoryCount )
	end

	local logContainer = vgui.Create( "DPanel", self )
	logContainer:SetSize( self:GetWide(), self:GetTall() * 0.85 )
	logContainer:Dock( BOTTOM )
	logContainer:DockMargin( 10, 0, 10, 10 )

	function logContainer:Paint( w, h )
		surface.SetDrawColor( 15, 15, 15 )
		surface.DrawRect( 0, 0, w, h )
	end

	local scrollPanel = vgui.Create( "admin_system_dscrollpanel", logContainer )
	scrollPanel:Dock( FILL )

	self.logScrollPanel = scrollPanel

	for _, data in ipairs( LOG.msg ) do
		self:CreateLogLabel( data, self.logScrollPanel )
	end
end

function PANEL:Paint( w, h )
end

function PANEL:Think()
	local msgTable = LOG.msg
	
	if ( LOG.categorizedmsg[ self.selectedCategory ] ) then
		msgTable = LOG.categorizedmsg[ self.selectedCategory ]
	end
	
	if ( not self.logScrollPanel or not msgTable or self.creatingNewLabel ) then return end
	
	if ( self.totalMsgCount >= #msgTable ) then return end
	
	self.creatingNewLabel = true
	
	for count = self.totalMsgCount + 1, #msgTable do
		print( self.selectedCategory, self.totalMsgCount, #msgTable )
		self:CreateLogLabel( msgTable[ count ], self.logScrollPanel )
		self.totalMsgCount = count
	end

	self.creatingNewLabel = false
end

function PANEL:CreateLogButton( categoryName, parent, categoryCount )
	local btn = vgui.Create( "admin_system_dbutton", parent )
	btn:Dock( LEFT )
	btn:SetSize( parent:GetWide() / categoryCount, parent:GetTall() )
	btn:SetText( "" )
	btn:_Init()

	btn.hoverStyle.thicknessIncrease.enable = true
	btn.hoverStyle.textColor.enable = true

	function btn:WrappedPaint( w, h )
		surface.SetDrawColor( 200, 200, 200 )
		surface.DrawOutlinedRect( 0, 0, w, h, btn.hoverStyle.thicknessIncrease.thickness )
		draw.SimpleText( categoryName, "Sansation-25-regular", w * 0.5, h * 0.5, btn.hoverStyle.textColor.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	btn.WrappedDoClick = function( _self )
		self.logScrollPanel:Clear()
		
		self.selectedCategory = categoryName
		self.totalMsgCount = #LOG.categorizedmsg[ categoryName ]

		for _, data in ipairs( LOG.categorizedmsg[ categoryName ] ) do
			self:CreateLogLabel( data, self.logScrollPanel )
		end

		timer.Simple( 0.2, function()
			if ( not IsValid( self.logScrollPanel ) ) then return end

			local vbar = self.logScrollPanel:GetVBar()
			vbar:SetScroll( vbar.CanvasSize )
		end )
	end

	return btn
end

function PANEL:CreateLogLabel( data, scrollPanel )
	if ( not data or not data.date or not data.category or not data.message ) then return end

	local label = self.logScrollPanel:Add( "DLabel" )
	label:Dock( TOP )
	label:DockMargin( 0, 0, 0, 5 )

	label:SetText( data.date .. " - [" .. data.category .. "] - " .. data.message )
	label:SetSize( self.logScrollPanel:GetWide(), self.logScrollPanel:GetTall() - 10 )
	label:SetFont( "TargetID" )
	label:SetTextColor( data.color )
	label:SetWrap( true )
	label:SetAutoStretchVertical( true )

	return label
end

vgui.Register( "admin_system_panel_log", PANEL, "DPanel" )
