include( "autorun/sh_admin_system.lua" )
include( "autorun/server/sv_commands.lua" )
include( "autorun/server/commands/sv_teleport.lua" )
include( "autorun/server/commands/sv_usergroup.lua" )

AddCSLuaFile( "autorun/client/menu/cl_admin_system_main_menu.lua" )
AddCSLuaFile( "autorun/client/menu/cl_admin_system_panel_container.lua" )
AddCSLuaFile( "autorun/client/menu/cl_admin_system_panel_board.lua" )
AddCSLuaFile( "autorun/client/menu/cl_admin_system_panel_player.lua" )
AddCSLuaFile( "autorun/client/menu/cl_admin_system_panel_log.lua" )
AddCSLuaFile( "autorun/client/menu/wrappedUI/cl_admin_system_dbutton.lua" )
AddCSLuaFile( "autorun/client/menu/wrappedUI/cl_admin_system_dscrollpanel.lua" )

resource.AddFile( "sound/adminSystem/Abstract2.wav" )
resource.AddFile( "sound/adminSystem/Minimalist12.wav" )

local files, _ = file.Find( "resource/fonts/*.ttf", "GAME" )

for _, font in ipairs( files ) do
	resource.AddSingleFile( "resource/fonts/" .. font )
end

util.AddNetworkString( "AdminSystemCommunicateData" )

ADMIN_SYSTEM.userCache = ADMIN_SYSTEM.userCache or {}

hook.Add( "Initialize", "AdminSystemInitialize", function()
	MySQL.Query( "SELECT * FROM admin", {}, function( data, err )
		if ( err ) then return end

		for k, v in ipairs( data ) do
			ADMIN_SYSTEM.userCache[ v.steamid64 ] = v.usergroup
		end
	end )
end )

hook.Add( "PlayerInitialSpawn", "AdminSystemPlayerInitialSpawn", function( ply )
	local steamid64 = ply:SteamID64()
	local usergroup = ADMIN_SYSTEM.userCache[ steamid64 ]

	if ( usergroup == nil ) then
		if ( ADMIN_SYSTEM.GROUPS[ ADMIN_SYSTEM.DEFAULTGROUP ] == nil ) then
			Log(LOG_WARN, ADMIN_SYSTEM.logHeader .. "AdminSystemPlayerInitialSpawn: le groupe n'est pas valide." )
			return
		end

		MySQL.Query( "INSERT INTO admin(`steamid64`, `usergroup`) VALUES (?, ?) ON DUPLICATE KEY UPDATE `usergroup` = VALUES(`usergroup`)", { steamid64, ADMIN_SYSTEM.DEFAULTGROUP })
		ply:SetUserGroup( ADMIN_SYSTEM.DEFAULTGROUP )
	else
		ply:SetUserGroup( usergroup )
	end
end )

net.Receive( "AdminSystemCommunicateData", function( len, ply )
	ADMIN_SYSTEM.SendCommandsDataToPlayer( ply )
end )

function ADMIN_SYSTEM.SendCommandsDataToPlayer( ply )
	local allowedCommands = {}

	local usergroup = ply:GetUserGroup()
	
	if ( usergroup == "user" ) then return end

	for k, v in pairs( ADMIN_SYSTEM.commandsCache ) do
		if ( ADMIN_SYSTEM.HasPermission( usergroup, v.usergroup ) == true ) then
			table.insert( allowedCommands, v )
		end
	end

	if ( #allowedCommands == 0 ) then return end

	local allowedCommandsCopy = util.DeepCopy( allowedCommands, { callback = true } )

	net.Start( "AdminSystemCommunicateData" )
	net.WriteTable( allowedCommandsCopy )
	net.Send( ply )
end

-- MySQL.Query( "SELECT * FROM admin", {}, function( data, err )
-- 	if ( err ) then return end

-- 	for k, v in ipairs( data ) do
-- 		ADMIN_SYSTEM.userCache[ v.steamid64 ] = v.usergroup
-- 	end
-- end )

function ADMIN_SYSTEM.HasPermission( perm, neededPerm )
	if ( type( perm ) ~= "string" or type( neededPerm ) ~= "string" ) then return false end
	local permGroup = ADMIN_SYSTEM.GROUPS[ perm ]
	local neededPermGroup = ADMIN_SYSTEM.PERMISSIONS[ neededPerm ]
	
	if ( permGroup == nil or neededPermGroup == nil ) then return false end

	if ( bit.band( permGroup, neededPermGroup ) > 0 ) then return true end

	return false
end
