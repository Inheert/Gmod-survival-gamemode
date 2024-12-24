include( "autorun/sh_conquest_system.lua" )

PANEL = {}

PANEL.borderColor = Color( 0, 0, 0, 0 )

function PANEL:Init()
    local width, height = ScrW(), ScrH()
    
    local panelWidth, panelHeight = width * 0.3, height * 0.2
    self:SetSize( panelWidth, panelHeight )
    self:SetPos( width * 0.5 - panelWidth * 0.5, height * 0.5 - panelHeight * 0.5 )

    local textEntry = vgui.Create( "DTextEntry", self )
    textEntry:Dock( TOP )
    textEntry:SetSize( panelWidth * 0.8, panelHeight * 0.2 )
    textEntry:SetPlaceholderText( "Nom du groupe a crée" )
    textEntry:SetPlaceholderColor( Color( 200, 200, 200 ) )

    textEntry.AllowInput = function( _, stringValue )
        local currentText = textEntry:GetValue()
        if ( #currentText >= CONQUEST.configs.groupeNameMaxLen ) then return true end

        return false
    end

    function textEntry:Paint( w, h )
        draw.RoundedBox( 4, 0, 0, w, h, Color( 40, 40, 40 ) )
        self:DrawTextEntryText( Color( 200, 200, 200 ), Color( 100, 100, 100 ), Color( 200, 200, 200 ) )
    end

    local button = vgui.Create( "admin_system_dbutton", self )
	button:SetText( "" )
	button:SetSize( panelWidth * 0.3, panelHeight * 0.2 )
	button:Dock( BOTTOM )
	button:_Init()

	button.hoverStyle.thicknessIncrease.enable = true
	button.hoverStyle.textColor.enable = true

	function button:WrappedPaint( w, h )
		surface.SetDrawColor( 200, 200, 200 )
		surface.DrawOutlinedRect( 0, 0, w, h, button.hoverStyle.thicknessIncrease.thickness )
		draw.SimpleText( "Valider", "Sansation-25-regular", w * 0.5, h * 0.5, button.hoverStyle.textColor.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end


	button.WrappedDoClick = function( _self )
        local text = textEntry:GetValue()

        if ( #text > CONQUEST.configs.groupeNameMaxLen or string.match( text, CONQUEST.configs.groupeNameRegex ) == nil ) then 
            self.borderColor = Color( 255, 0, 0, 250 )
            return
        end

        self.borderColor = Color( 0, 255, 0, 250 )
        timer.Simple( 0.2, function()
            net.Start( "ConquestGroupeCreation" )
            net.WriteString( text )
            net.SendToServer()
            self:Remove()
        end )
	end
end

function PANEL:Paint( w, h )
    surface.SetDrawColor( 45, 45, 45, 255 )
    surface.DrawRect( 0, 0, w, h )
    surface.SetDrawColor( self.borderColor.r, self.borderColor.g, self.borderColor.b, self.borderColor.a )
    surface.DrawOutlinedRect( 0, 0, w, h, 2 )
end

vgui.Register( "conquest_groupe_main_frame", PANEL, "DFrame" )
