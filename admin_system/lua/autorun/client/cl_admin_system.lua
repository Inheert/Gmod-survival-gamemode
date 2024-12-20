include( "autorun/sh_admin_system.lua" )
include( "autorun/client/menu/cl_admin_system_main_menu.lua" )
include( "autorun/client/menu/cl_admin_system_panel_container.lua" )
include( "autorun/client/menu/cl_admin_system_panel_board.lua" )
include( "autorun/client/menu/cl_admin_system_panel_player.lua" )
include( "autorun/client/menu/cl_admin_system_panel_log.lua" )
include( "autorun/client/menu/cl_admin_system_panel_command.lua" )
include( "autorun/client/menu/wrapped_ui/cl_admin_system_dbutton.lua" )
include( "autorun/client/menu/wrapped_ui/cl_admin_system_dscrollpanel.lua" )

net.Receive( "AdminSystemCommunicateData", function()
	ADMIN_SYSTEM.commandsCache = net.ReadTable()
end )

surface.CreateFont("Sansation-30-bold", {
    font = "Sansation",      -- Nom de la police
    size = 30,           -- Taille
	weight = 600,
    antialias = true,    -- Anti-aliasing
})

surface.CreateFont("Sansation-25-regular", {
    font = "Sansation",      -- Nom de la police
    size = 25,           -- Taille
	weight = 400,
    antialias = true,    -- Anti-aliasing
})

surface.CreateFont("Sansation-25-bold", {
    font = "Sansation",      -- Nom de la police
    size = 25,           -- Taille
	weight = 600,
    antialias = true,    -- Anti-aliasing
})

surface.CreateFont("Sansation-15-thin", {
    font = "Sansation",      -- Nom de la police
    size = 15,           -- Taille
    antialias = true,    -- Anti-aliasing
})

surface.CreateFont("Sansation-10-thin", {
    font = "Sansation",      -- Nom de la police
    size = 10,           -- Taille
    antialias = true,    -- Anti-aliasing
})

surface.CreateFont("CustomButtonFont", {
    font = "Arial",      -- Nom de la police
    size = 24,           -- Taille
    weight = 200,        -- Épaisseur du texte
    antialias = true,    -- Anti-aliasing
})

surface.CreateFont("CustomButtonFont14", {
    font = "Arial",      -- Nom de la police
    size = 14,           -- Taille
    weight = 200,        -- Épaisseur du texte
    antialias = true,    -- Anti-aliasing
})

surface.CreateFont("CustomButtonFont6", {
    font = "Arial",      -- Nom de la police
    size = 6,           -- Taille
    weight = 200,        -- Épaisseur du texte
    antialias = true,    -- Anti-aliasing
})
