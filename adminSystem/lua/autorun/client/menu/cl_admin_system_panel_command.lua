include( "autorun/sh_admin_system.lua" )

local PANEL = {}

function PANEL:Init()
end

function PANEL:_Init()
end

function PANEL:Paint( w, h )
end

vgui.Register( "admin_system_panel_command", PANEL, "DPanel" )
