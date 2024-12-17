include( "autorun/sh_admin_system.lua" )

local PANEL = {}

function PANEL:Init()
	if ( type( ADMIN_SYSTEM.commandsCache ) == "table" and #ADMIN_SYSTEM.commandsCache == 0 ) then
		net.Start( "AdminSystemCommunicateData" )
		net.SendToServer()
	end

	self.gradientMat = Material( "gui/gradient" )

	local width = ScrW() * 0.95
	local height = ScrH() * 0.95

	self:SetSize( width, height )
	self:SetPos( 0, 0 )
	self:SetVisible( true )
	self:SetDraggable( false )
	self:ShowCloseButton( true )
	self:SetMouseInputEnabled( true )
	self:SetKeyboardInputEnabled( true )
	self:SetDeleteOnClose( true )
	self:SetTitle( "" )
	self:Center()

	self:MenuBar( width * 0.2, height )
	self:CorePanel( width * 0.8, height )

	timer.Simple( 0.1, function()
		if ( not IsValid( self.corePanel ) ) then return end

		self.corePanel:SwitchPanel( "admin_system_panel_board" )
	end )

	local label = vgui.Create( "DLabel", self )
	label:SetText( "Copyright © 2024 - 2025 NosalisHub tous droits réservés" )
	label:SetFont( "CustomButtonFont14" )
	label:SetTextColor( Color( 255, 255, 255 ) )
	label:SetContentAlignment( 5 )
	label:SizeToContents()

	local panelW, panelH = self:GetSize()
	local labelW, labelH = label:GetSize()
	label:SetPos( panelW - labelW - 10, panelH - labelH - 10 )
end

function PANEL:Paint( w, h )
	surface.SetDrawColor( 28, 29, 33 )
	surface.DrawRect( 0, 0, w, h )
end

function PANEL:CorePanel( width, height )
	self.corePanel = vgui.Create( "admin_system_panel_container", self )
	self.corePanel:SetPos( self:GetWide() * 0.2, 0 )
	self.corePanel:SetSize( self:GetWide() * 0.8, self:GetTall() )
end

function PANEL:MenuBar( width, height )
	local menuCategoryHeight = height * 0.1
	local menuButtonHeight = height * 0.05

	local menuContainer = vgui.Create( "DPanel", self )
	menuContainer:SetSize( width, height )
	menuContainer:SetPos( 0, 0 )


	function menuContainer:Paint( w, h )
		surface.SetDrawColor( 49, 50, 54 )
		surface.DrawRect( 0, 0, w, h )
	end


	local menuHeader = vgui.Create( "DPanel", menuContainer )
	menuHeader:SetSize( width, height * 0.1 )
	menuHeader:Dock( TOP )
	menuHeader:DockPadding( 10, 10, 10, 10 )

	local gradient = self.gradientMat

	function menuHeader:Paint( w, h )
		surface.SetDrawColor( 255, 0, 0, 20 )
		surface.SetMaterial( gradient )
		surface.DrawTexturedRectUV( 0, 0, w, h, 0, 1, 1, 0 )

		draw.SimpleText( "NOSALIS", "Sansation-30-bold", w * 0.5, h * 0.3, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( "Admin panel", "Sansation-30-bold", w * 0.5, h * 0.6, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	local scrollPanel = vgui.Create( "admin_system_dscrollpanel", menuContainer )
	scrollPanel:Dock( FILL )

	local category = self:CreateMenuCategory( width, menuCategoryHeight, scrollPanel, "Général" )
	self:CreateMenuButton( width, menuButtonHeight, "Tableau de bord", scrollPanel, "admin_system_panel_board" )
	self:CreateMenuButton( width, menuButtonHeight, "Joueurs", scrollPanel, "admin_system_panel_player" )
	local button = self:CreateMenuButton( width, menuButtonHeight, "Logs", scrollPanel, "admin_system_panel_log" )
	button:DockMargin( 0, 0, 0, 100 )

	category = self:CreateMenuCategory( width, menuCategoryHeight, scrollPanel, "Commandes" )
	self:CreateMenuButton( width, menuButtonHeight, "Charactères", scrollPanel )
	self:CreateMenuButton( width, menuButtonHeight, "Sanctions", scrollPanel )
	self:CreateMenuButton( width, menuButtonHeight, "Autres", scrollPanel )
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

function PANEL:CreateMenuCategory( width, height, parent, name )
	local category = parent:Add( "DPanel" )
	category:SetSize( width, height )
	category:Dock( TOP )

	local gradient = self.gradientMat

	function category:Paint( w, h )
		surface.SetDrawColor( 85, 85, 85, 255 )
		surface.SetMaterial( gradient )
		surface.DrawTexturedRectUV( 0, 0, w, h, 1, 0, 0, 1 )

		draw.SimpleText( name, "Sansation-30-bold", w * 0.5, h * 0.5, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	return category
end

function PANEL:CreateMenuButton( width, height, text, parent, onClickNewPanelName )
	local button = parent:Add( "admin_system_dbutton" )
	button:SetText( "" )
	button:SetSize( width, height )
	button:Dock( TOP )
	button:_Init()

	button.hoverStyle.thicknessIncrease.enable = true
	button.hoverStyle.textColor.enable = true

	function button:WrappedPaint( w, h )
		surface.SetDrawColor( 200, 200, 200 )
		surface.DrawOutlinedRect( 0, 0, w, h, button.hoverStyle.thicknessIncrease.thickness )
		draw.SimpleText( text, "Sansation-25-regular", w * 0.5, h * 0.5, button.hoverStyle.textColor.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end


	button.WrappedDoClick = function( _self )
		self.corePanel:SwitchPanel( onClickNewPanelName )
	end

	return button
end

function PANEL:OnKeyCodePressed( button )
	if ( button == 94 ) then
		timer.Simple( 0.1, function()
			if ( not IsValid( self ) ) then return end

			self:Close()
		end )
	end
end

vgui.Register( "admin_system_main_frame", PANEL, "DFrame" )
