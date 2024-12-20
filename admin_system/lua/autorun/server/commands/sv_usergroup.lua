include( "autorun/sh_admin_system.lua" )

ADMIN_SYSTEM.AddCommand( {
	name = "setUserGroup",
	command = "setUserGroup",
	usergroup = "superadmin",
	category = "UserGroup",
	serverCallable = true,
	args = {
		{
			type = "player"
		},
		{
			type = "string"
		}
	},
	callback = function( caller, cmd, args, argStr )
		if ( ADMIN_SYSTEM.GROUPS[ args[ 2 ] ] == nil ) then
			NWLog( LOG_WARN, LOG.GetGoodUserLevel( caller ), "Command", ADMIN_SYSTEM.CommandExecFail( caller, cmd, argStr, "Usergroup invalide." ) )
			return
		elseif ( caller == args[ 1 ] ) then
			NWLog( LOG_WARN, LOG.GetGoodUserLevel( caller ), "Command", ADMIN_SYSTEM.CommandExecFail( caller, cmd, argStr, "Tentative de set son propre groupe." ) )
			return
		end

		local steamid64 = args[ 1 ]:SteamID64()

		MySQL.Query( "INSERT INTO admin(`steamid64`, `usergroup`) VALUES (?, ?) ON DUPLICATE KEY UPDATE `usergroup` = VALUES(`usergroup`)", { steamid64, args[ 2 ] } )
		ADMIN_SYSTEM.userCache[ steamid64 ] = args[ 2 ]
		args[ 1 ]:SetUserGroup( args[ 2 ] )
		
		NWLog( LOG_SUCCESS, LOG.GetGoodUserLevel( caller ), "Command", ADMIN_SYSTEM.CommandExecSuccess( caller, cmd, argStr ) )
	end
} )
