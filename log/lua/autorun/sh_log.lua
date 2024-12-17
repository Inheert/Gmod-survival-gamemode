LOG = LOG or {}

LOG.category = {
	Character = true,
	Command = true,
	Kill = true,
	Sanction = true,
	Autre = true,
}

if ( SERVER ) then
	util.AddNetworkString( "LogNetwork" )
end

if ( CLIENT ) then
	LOG.msg = {}
	LOG.categorizedmsg = {}

	net.Receive( "LogNetwork", function( len, ply )
		local data = net.ReadTable()

		table.insert( LOG.msg, data )

		if ( LOG.category[ data.category ] ~= nil ) then
			if ( LOG.categorizedmsg[ data.category ] == nil ) then
				LOG.categorizedmsg[ data.category ] = {}
			end
			table.insert( LOG.categorizedmsg[ data.category ], data )
		else
			if ( LOG.categorizedmsg[ "Autre" ] ) then
				LOG.categorizedmsg[ "Autre" ] = {}
			end
			table.insert( LOG.categorizedmsg[ data.category ], data )
		end
	end )
end

LOG_INFO = 1
LOG_WARN = 2
LOG_SEVERE = 3
LOG_SUCCESS = 4

LOG.prefixColor = {
	[LOG_INFO] = Color(41, 28, 233),
	[LOG_WARN] = Color(233, 137, 28),
	[LOG_SEVERE] = Color(170, 0, 0),
	[LOG_SUCCESS] = Color(0, 190, 0)
}
LOG.textColor = {
	[LOG_INFO] = Color(28, 219, 233),
	[LOG_WARN] = Color(233, 219, 28),
	[LOG_SEVERE] = Color(255, 0, 0),
	[LOG_SUCCESS] = Color(0, 220, 0)
}

function Log( level, ... )
	if ( not LOG.textColor[ level ] ) then
		level = LOG_INFO
	end

	MsgC( LOG.prefixColor[ level ], "[NOSALIS] - ", LOG.textColor[ level ], ... )
	MsgC( "\n" )
end

if ( SERVER ) then
	function NWLog( level, perm, category, msg )
		local plys = {}

		for _, ply in ipairs( player.GetAll() ) do
			if ( ADMIN_SYSTEM.HasPermission( ply:GetUserGroup(), perm ) == false ) then continue end
			table.insert( plys, ply )
		end

		if ( not LOG.textColor[ level ] ) then
			level = LOG_INFO
		end

		if ( LOG.category[ category ] == nil ) then
			category = "Autre"
		end

		local data = {
			color = LOG.textColor[ level ],
			message = msg,
			category = category,
			date = os.date("%H:%M:%S")
		}

		net.Start( "LogNetwork" )
		net.WriteTable( data )
		net.Send( plys )

		MsgC( LOG.prefixColor[ level ], "[NOSALIS / " .. category .. "] - ", LOG.textColor[ level ], msg )
		MsgC( "\n" )
	end
	
	function LOG.GetGoodUserLevel( ply )
		if ( IsValid( ply ) ) then
			return ply:GetUserGroup()
		else
			return "admin"
		end
	end
end



