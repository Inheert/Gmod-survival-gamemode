include( "autorun/sh_admin_system.lua" )

local PANEL = {}
PANEL.name = "Tableau de bord"

function PANEL:Init()
end

function PANEL:_Init()
	self.topContainer = vgui.Create( "DPanel", self )
	self.topContainer:SetSize( self:GetWide(), self:GetTall() * 0.4 )
	self.topContainer:Dock( TOP )

	function self.topContainer:Paint( w, h )
	end

	self.bottomContainer = vgui.Create( "DPanel", self )
	self.bottomContainer:SetSize( self:GetWide(), self:GetTall() * 0.5 )
	self.bottomContainer:Dock( BOTTOM )
	self.bottomContainer:DockMargin( 10, 0, 10, 10 )

	function self.bottomContainer:Paint( w, h )
		surface.SetDrawColor( 15, 15, 15 )
		surface.DrawRect( 0, 0, w, h )
	end

	self:CreateEntitiesOverview()
	self:CreateConsoleLog()
end

function PANEL:Paint( w, h )
	surface.SetDrawColor( 0, 0, 0, 0 )
end

function PANEL:OnRemove()
	if ( IsValid( self.contextualMenuContainer ) ) then
		self.contextualMenuContainer:Remove()
	end
end

function PANEL:CreateEntitiesOverview()
	local scrollPanelWidth = self.topContainer:GetWide() * 0.3
	local scrollPanelHeight = self.topContainer:GetTall() * 0.95

	local containerMargin = ( self.topContainer:GetWide() - ( scrollPanelWidth * 3 ) ) * 0.5

	self.topContainer:DockPadding( containerMargin, 0, containerMargin, 0 )

	local allEnts = ents.GetAll()
	local players = {}
	local entities = {}
	local npcs = {}

	for _, ent in ipairs( allEnts ) do
		if ( ent:IsPlayer() ) then
			table.insert( players, ent )
		elseif ( ent:IsNPC() ) then
			table.insert( npcs, ent )
		else
			table.insert( entities, ent )
		end
	end

	self:CreateEntitiesScrollPanel( ( scrollPanelWidth + containerMargin ) * 0, 0, scrollPanelWidth, scrollPanelHeight, "Joueurs", players )
	self:CreateEntitiesScrollPanel( ( scrollPanelWidth + containerMargin ) * 1, 0, scrollPanelWidth, scrollPanelHeight, "Entités", entities )
	self:CreateEntitiesScrollPanel( ( scrollPanelWidth + containerMargin ) * 2, 0, scrollPanelWidth, scrollPanelHeight, "NPC's", npcs )
end

function PANEL:CreateEntitiesScrollPanel( xPos, yPos, width, height, panelType, panelEnts )
	local container = vgui.Create( "DPanel", self.topContainer )
	container:SetSize( width, height )
	container:SetPos( xPos, yPos )
	container:DockMargin( 10, 0, 10, 0 )

	function container:Paint( w, h )
	end

	local label = self:CreateLabel( panelType .. " (" .. #panelEnts .. ")", container )
	label:Dock( TOP )
	label:DockPadding(10, 10, 10, 10)
	label:SetTall( label:GetTall() * 1.5 )

	local scrollPanel = vgui.Create( "admin_system_dscrollpanel", container )
	scrollPanel:Dock( FILL )

	function scrollPanel:WrappedPaint( w, h )
		surface.SetDrawColor( 41, 41, 41 )
		surface.DrawRect( 0, 0, w, h )
	end

	if ( panelType == "Joueurs" ) then
		for _, ply in ipairs( panelEnts ) do
			self:CreateScrollPanelItem( tostring( ply ), ply, scrollPanel, "player" )
		end
	elseif ( panelType == "Entités" ) then
		for _, ent in ipairs( panelEnts ) do
			self:CreateScrollPanelItem( tostring( ent ) .. " - " .. tostring( ent:GetOwner() ), ent, scrollPanel, "entity" )
		end
	elseif ( panelType == "NPC's" ) then
		for _, ent in ipairs( panelEnts ) do
			self:CreateScrollPanelItem( tostring( ent ) .. " - " .. tostring( ent:GetOwner() ), ent, scrollPanel, "npc" )
		end 
	end
end

function PANEL:CreateScrollPanelItem( name, ent, parent, category )
	local button = parent:Add( "admin_system_dbutton" )
	button:Dock( TOP )
	button:DockMargin( 0, 0, 0, 5 )
	button:SetText( "" )
	button:_Init()

	button.hoverStyle.thicknessIncrease.enable = true
	button.hoverStyle.textColor.enable = true

	function button:WrappedPaint( w, h )
		surface.SetDrawColor( 50, 50, 50 )
		surface.DrawRect( 0, 0, w, h )
		surface.SetDrawColor( 200, 200, 200 )
		surface.DrawOutlinedRect( 0, 0, w, h, self.hoverStyle.thicknessIncrease.thickness )

		draw.SimpleText(name, "Sansation-10-thin", w * 0.5, h * 0.5, self.hoverStyle.textColor.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	button.WrappedDoClick = function( _self )
		if ( type( ADMIN_SYSTEM.commandsCache ) ~= "table" ) then return end
		local contextualCommands = {}

		for _, command in ipairs( ADMIN_SYSTEM.commandsCache ) do
			if ( type( command.targetEnts ) ~= "table" ) then continue end
				
			for _, targetEnt in ipairs( command.targetEnts ) do
				if ( targetEnt == category ) then
					table.insert( contextualCommands, command )
					break
				end
			end
		end

		local xPos, yPos = _self:LocalToScreen( -100, 0 )
		self:CreateContextualMenu( xPos, yPos, contextualCommands, ent )
	end
end

function PANEL:CreateContextualMenu( xPos, yPos, contextualCommands, ent )
	local dScrollPanelMaxHeight = 800
	local dScrollPanelHeight = 0

	local container = vgui.Create( "DPanel", self:GetParent():GetParent() )
	container:SetPos( xPos, yPos )
	container:SetSize( 100, 0 )
	container:DockPadding( 1, 1, 1, 1 )

	if ( IsValid( self.contextualMenuContainer ) ) then
		self.contextualMenuContainer:Remove()
	end

	self.contextualMenuContainer = container

	if ( IsValid( self.contextualMenu ) ) then
		self.contextualMenu:Remove()
	end

	function container:Paint( w, h )
		surface.SetDrawColor( 69, 69, 69 )
		surface.DrawOutlinedRect( 0, 0, w, h )
	end

	self.contextualMenu = container
	
	local contextualMenu = vgui.Create( "admin_system_dscrollpanel", container )
	contextualMenu:Dock( FILL )

	for k, v in ipairs( contextualCommands ) do
		local button = contextualMenu:Add( "admin_system_dbutton" )
		button:Dock( TOP )
		button:SetText( "" )
		button:_Init()

		button.hoverStyle.thicknessIncrease.enable = true
		button.hoverStyle.textColor.enable = true

		function button:WrappedPaint( w, h )
			surface.SetDrawColor( 50, 50, 50 )
			surface.DrawRect( 0, 0, w, h )
			surface.SetDrawColor( 200, 200, 200 )
			surface.DrawOutlinedRect( 0, 0, w, h, self.hoverStyle.thicknessIncrease.thickness )
	
			draw.SimpleText( v.name, "Sansation-15-thin", w * 0.5, h * 0.5, self.hoverStyle.textColor.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end

		button.WrappedDoClick = function( _self )
			net.Start( "adminPanelCommandExecution" )
			net.WriteString( v.name )
			net.WriteString( v.command )
			net.WriteEntity( ent )
			net.WriteString( tostring( ent ) )
			net.SendToServer()
		end

		dScrollPanelHeight = math.Clamp( dScrollPanelHeight + button:GetTall(), 0, dScrollPanelMaxHeight )
		container:SetTall( dScrollPanelHeight )
	end
end

function PANEL:CreateLabel( text, parent )
	local label = vgui.Create( "DLabel", parent )
	label:Dock( FILL )
	label:Center()
	label:SetText( text )
	label:SetFont( "DermaLarge" )
	label:SetTextColor( Color( 255, 255, 255 ) )
	label:SetContentAlignment( 5 )

	return label
end

--[[
	CONSOLE LOG
]]--

function PANEL:CreateConsoleLog()
	local scrollPanel = vgui.Create( "admin_system_dscrollpanel", self.bottomContainer )
	scrollPanel:Dock( FILL )

	if ( IsValid( self.logMsgScrollPanel ) ) then
		self.logMsgScrollPanel:Remove()
	end

	self.logMsgScrollPanel = scrollPanel
	self.totalMsg = #LOG.msg

	for _, data in ipairs( LOG.msg ) do
		local label = scrollPanel:Add( "DLabel" )
		label:Dock( TOP )
		label:DockMargin( 0, 0, 0, 5 )
		label:SetText( data.date .. " - " .. data.message )
		label:SetSize( self.bottomContainer:GetWide(), self.bottomContainer:GetTall() - 10 )
		label:SetFont( "TargetID" )
		label:SetTextColor( data.color )
		label:SetWrap( true )
		label:SetAutoStretchVertical( true )
	end

	timer.Simple( 0.05, function()
		if ( not IsValid( self.logMsgScrollPanel ) ) then return end

		local vbar = self.logMsgScrollPanel:GetVBar()
		vbar:SetScroll( vbar.CanvasSize )
	end )
end

function PANEL:Think()
	if ( self.totalMsg < #LOG.msg ) then
		self.totalMsg = #LOG.msg
	
		local label = self.logMsgScrollPanel:Add( "DLabel" )
		label:Dock( TOP )
		label:DockMargin( 0, 0, 0, 5 )
		label:SetText( LOG.msg[ #LOG.msg ].date .. " - " .. LOG.msg[ #LOG.msg ].message )
		label:SetSize( self.bottomContainer:GetWide(), self.bottomContainer:GetTall() - 10 )
		label:SetFont( "TargetID" )
		label:SetTextColor( LOG.msg[ #LOG.msg ].color )
		label:SetWrap( true )
		label:SetAutoStretchVertical( true )
		print('opinerg')

		timer.Simple( 0.2, function()
			if ( not IsValid( self.logMsgScrollPanel ) ) then return end

			local vbar = self.logMsgScrollPanel:GetVBar()
			vbar:SetScroll( vbar.CanvasSize )
		end )
	end
end

vgui.Register( "admin_system_panel_board", PANEL, "DPanel" )
