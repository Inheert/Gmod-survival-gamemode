ADMIN_SYSTEM = ADMIN_SYSTEM or {}

ADMIN_SYSTEM.logHeader = "Admin System - "

ADMIN_SYSTEM.PERMISSIONS = {
	["user"] = bit.lshift( 1, 0 ),
	["admin"] = bit.lshift( 1, 1 ),
	["superadmin"] = bit.lshift( 1, 2 )
}

ADMIN_SYSTEM.GROUPS = {
	[ "user" ] = ADMIN_SYSTEM.PERMISSIONS.user,
	[ "admin" ] = bit.bor( ADMIN_SYSTEM.PERMISSIONS.user, ADMIN_SYSTEM.PERMISSIONS.admin ),
	[ "superadmin" ] = bit.bor( ADMIN_SYSTEM.PERMISSIONS.user, ADMIN_SYSTEM.PERMISSIONS.admin, ADMIN_SYSTEM.PERMISSIONS.superadmin )
}

ADMIN_SYSTEM.DEFAULTGROUP = "user"

ADMIN_SYSTEM.commandsCache = ADMIN_SYSTEM.commandsCache or {}

function ADMIN_SYSTEM.CommandExecFail( ply, cmd, args, reason )
	local str = ADMIN_SYSTEM.logHeader

	if ( IsValid( ply ) ) then
		str = str .. "Le joueur " .. tostring( ply )
	else
		str = str .. "Le serveur"
	end
	str = str .. " a rencontré un problème lors du prétraitement de la commande suivante: '" .. tostring( cmd ) .. " " .. tostring( args ) .. "', raison: '" .. tostring( reason ) .. "'."
	return str
end

function ADMIN_SYSTEM.CommandExecSuccess( ply, cmd, args )
	local str = ADMIN_SYSTEM.logHeader

	if ( IsValid( ply ) ) then
		str = str .. "Le joueur " .. tostring( ply )
	else
		str = str .. "Le serveur"
	end
	str = str .. " a passé le prétraitement de la commande suivante: '" .. tostring( cmd ) .. " " .. tostring( args ) .. "'."
	return str
end
