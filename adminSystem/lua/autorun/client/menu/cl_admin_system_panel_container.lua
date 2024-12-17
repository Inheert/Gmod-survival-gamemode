include( "autorun/sh_admin_system.lua" )

local PANEL = {}

function PANEL:Init()
	local height = self:GetTall()
	local margin = height * 2

	self.container = vgui.Create( "DPanel", self )
	self.container:Dock( FILL )
	self.container:DockMargin( 50, 50, 50, 50 )

	function self.container:Paint( w, h )
		surface.SetDrawColor( 46, 47, 51 )
		surface.DrawRect( 0, 0, w, h )
	end

	self.panelLabel = self:GetParent():CreateLabel( "", self.container )
	self.panelLabel:Dock( TOP )
	self.panelLabel:DockMargin( 0, 20, 0, 20 )
	self.panelLabel:SetTall( self.panelLabel:GetTall() * 1.5 )
end

function PANEL:Paint( w, h )
	surface.SetDrawColor( 0, 0, 0, 0 )
end

function PANEL:SwitchPanel( newPanelName )
	if ( type( newPanelName ) ~= "string" ) then return end

	local newPanel = vgui.Create( newPanelName, self.container )

	if ( not IsValid( newPanel ) ) then return end

	if ( IsValid( self.corePanel ) ) then
		self.corePanel:Remove()
	end
	newPanel:Dock( FILL )
	newPanel:InvalidateParent( true )
	
	self.corePanel = newPanel
	self.corePanel:_Init()
	
	self.panelLabel:SetText( self.corePanel.name )
end

vgui.Register( "admin_system_panel_container", PANEL, "DPanel" )