include( "autorun/sh_admin_system.lua" )

local PANEL = {}
PANEL.name = "Joueurs"

function PANEL:Init()
end

function PANEL:Paint( w, h )
	surface.SetDrawColor( 0, 255, 0 )
	surface.DrawRect( 0, 0, w, h )
end

vgui.Register( "admin_system_panel_player", PANEL, "DPanel" )