include( "autorun/sh_admin_system.lua" )

local PANEL = {}
PANEL.name = "Joueurs"

function PANEL:Init()
end

function PANEL:_Init()
	self.selectedPlayer = player.GetAll()[ 1 ]
	self:PlayerSelectionBar()
	self:PlayerFocusPanel()
end

function PANEL:Paint( w, h )
end

function PANEL:PlayerSelectionBar()
	local container = vgui.Create( "DPanel", self )
	container:SetSize( self:GetWide() * 0.15, self:GetTall() )
	container:Dock( LEFT )

	function container:Paint( w, h )
		surface.SetDrawColor( 41, 41, 41 )
		surface.DrawRect( 0, 0, w, h )
	end

	local playerScrollbar = vgui.Create( "admin_system_dscrollpanel", container )
	playerScrollbar:Dock( FILL )

	local ply = player.GetAll()[ 1 ]
	for i = 1, 50 do
		if ( not IsValid( ply ) ) then continue end

		local button = playerScrollbar:Add( "admin_system_dbutton" )
		button:_Init()
		button:Dock( TOP )
		button:SetSize( playerScrollbar:GetWide(), playerScrollbar:GetWide() )
		button:SetText( "" )

		button.hoverStyle.thicknessIncrease.enable = true
		button.hoverStyle.textColor.enable = true
	
		function button:WrappedPaint( w, h )
			surface.SetDrawColor( 50, 50, 50 )
			surface.DrawRect( 0, 0, w, h )
			surface.SetDrawColor( 200, 200, 200 )
			surface.DrawOutlinedRect( 0, 0, w, h, self.hoverStyle.thicknessIncrease.thickness )
	
			draw.SimpleText(tostring( ply ), "Sansation-10-thin", w * 0.5, h * 0.5, self.hoverStyle.textColor.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end	

		button.WrappedDoClick = function( _self )
			if ( not IsValid( ply ) ) then return end
			
			self.selectedPlayer = ply
			self:PlayerFocusPanel()
		end
	end
end

function PANEL:PlayerFocusPanel()
	if ( not IsValid( self.selectedPlayer ) ) then return end

	local playerContainer = vgui.Create( "DPanel", self )
	
	if ( IsValid( self.playerContainer ) ) then
		self.playerContainer:Remove()
	end

	self.playerContainer = playerContainer

	playerContainer:Dock( FILL )
	playerContainer:InvalidateParent( true )

	
	function playerContainer:Paint( w, h )
		surface.SetDrawColor( 0, 0, 0, 0 )
		surface.DrawRect( 0, 0, w, h )
	end
	
	local playerCam = vgui.Create( "DPanel", playerContainer )
	playerCam:SetSize( playerContainer:GetWide(), playerContainer:GetTall() * 0.5 )
	playerCam:Dock ( TOP )
	playerCam:InvalidateParent( true )

	function playerCam:Paint( w, h )
		local x, y = self:LocalToScreen(0, 0)
		local old = DisableClipping( true ) -- Avoid issues introduced by the natural clipping of Panel rendering
		render.RenderView( {
			origin = self:GetParent():GetParent().selectedPlayer:EyePos(),
			angles = self:GetParent():GetParent().selectedPlayer:EyeAngles(),
			x = x, y = y,
			w = w, h = h
		} )
		DisableClipping( old )
	end

	local playerData = vgui.Create( "DPanel", playerContainer )
	playerData:SetSize( playerContainer:GetWide() * 0.2, playerContainer:GetTall() * 0.4 )
	playerData:Dock( LEFT )
	playerData:DockMargin( 15, 15, 15,15 )

	function playerData:Paint( w, h )
		surface.SetDrawColor( 37, 37, 37, 255 )
		surface.DrawRect( 0, 0, w, h )
		
		draw.SimpleText( "Charactère ID:	5", "Sansation-25-bold" , 0, 0, Color( 250, 250, 250), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
		draw.SimpleText( "Nom:				zapeof,n", "Sansation-25-bold" , 0, 20, Color( 250, 250, 250), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
		draw.SimpleText( "Prénom:			efinz", "Sansation-25-bold" , 0, 40, Color( 250, 250, 250), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
		draw.SimpleText( "Âge:				42ans", "Sansation-25-bold" , 0, 60, Color( 250, 250, 250), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
	end

	local commands = vgui.Create( "admin_system_dscrollpanel", playerContainer )
	commands:Dock( LEFT )
	commands:SetSize( playerContainer:GetWide() * 0.3, playerContainer:GetTall() * 0.4 )

	for _, v in ipairs( ADMIN_SYSTEM.commandsCache ) do
		if ( type ( v.targetEnts ) ~= "table" ) then continue end

		local valid = false
		for _, target in ipairs( v.targetEnts ) do
			if ( target == "player" ) then
				valid = true
				break
			end
		end

		if ( not valid ) then continue end

		local button = commands:Add( "admin_system_dbutton" )
		button:SetText( "" )
		button:Dock( TOP )
		button:SetSize( commands:GetWide(), 100 )
		button:_Init()

		button.hoverStyle.thicknessIncrease.enable = true
		button.hoverStyle.textColor.enable = true
	
		function button:WrappedPaint( w, h )
			surface.SetDrawColor( 200, 200, 200 )
			surface.DrawOutlinedRect( 0, 0, w, h, button.hoverStyle.thicknessIncrease.thickness )
			draw.SimpleText( v.name, "Sansation-25-regular", w * 0.5, h * 0.5, button.hoverStyle.textColor.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end

		button.WrappedDoClick = function( _self )
			net.Start( "adminPanelCommandExecution" )
			net.WriteString( v.name )
			net.WriteString( v.command )
			net.WriteEntity( self.selectedPlayer )
			net.WriteString( tostring( self.selectedPlayer ) )
			net.SendToServer()
		end
	end

	local modelPanel = vgui.Create( "DModelPanel", playerContainer )
	modelPanel:SetSize( playerContainer:GetWide() * 0.4, playerContainer:GetTall() * 0.4 )
	modelPanel:Dock( LEFT )
	modelPanel:SetModel( self.selectedPlayer:GetModel() )
	modelPanel.Entity:SetSkin( self.selectedPlayer:GetSkin() )

	for i = 0, self.selectedPlayer:GetNumBodyGroups() - 1 do
		modelPanel.Entity:SetBodygroup(i, self.selectedPlayer:GetBodygroup(i))
	end

	modelPanel:SetCamPos( Vector( 15, 15, 60 ) )
	modelPanel:SetLookAt( Vector( 0, 0, 65 ) )
	modelPanel:SetFOV( 60 )

	function modelPanel:LayoutEntity( ent )
	end
end

vgui.Register( "admin_system_panel_player", PANEL, "DPanel" )