require( "mysqloo" )

MySQL = MySQL or {}

local sqlConn = {
	host = "localhost",
	port = "3306",
	ddb = "nosalis",
	username = "nosalisServer",
	password = "123456"
}

local db = db or nil

local setQueryArgs = {
	["string"] = "setString",
	["number"] = "setNumber",
	["boolean"] = "setBoolean",
}

hook.Add( "Initialize", "sqlInitialize", function()
	db = mysqloo.connect( sqlConn.host, sqlConn.username, sqlConn.password, sqlConn.ddb, sqlConn.port )
	
	function db:onConnected()
		Log( LOG_SUCCESS, "Connection à la base de donnée MySQL réussi!" )
	end
	
	function db:onConnectionFailed( db, error )
		Log( LOG_SEVERE, "Tentative de connection échouée à la base de donnée MySQL:" .. tostring(error) )
	end
	
	db:connect()

	MySQL.Query( "CREATE TABLE IF NOT EXISTS characters(pk INT PRIMARY KEY AUTO_INCREMENT, steamid64 BIGINT NOT NULL, characterId INT, firstname VARCHAR(20), lastname VARCHAR(30), age INT, size INT, model VARCHAR(100))" )
	MySQL.Query( "CREATE TABLE IF NOT EXISTS characters_bodygroups(pk INT PRIMARY KEY AUTO_INCREMENT, characterId INT, skin INT, bg0 INT, bg1 INT, bg2 INT, bg3 INT, bg4 INT, bg5 INT, bg6 INT, bg7 INT, bg8 INT, bg9 INT, bg10 INT, bg11 INT, bg12 INT, bg13 INT, bg14 INT)" )
	MySQL.Query( "CREATE TABLE IF NOT EXISTS admin(pk INT PRIMARY KEY AUTO_INCREMENT, steamid64 VARCHAR(20) NOT NULL UNIQUE, usergroup VARCHAR(25))" )
end )

concommand.Add( "connect_ddb", function( ply, cmd, arg, argStr )
	if ( db ) then
		db:disconnect( true )
	end

	db = mysqloo.connect( sqlConn.host, sqlConn.username, sqlConn.password, sqlConn.ddb, sqlConn.port )
	
	function db:onConnected()
		Log( LOG_SUCCESS, "Connection à la base de donnée MySQL réussi!" )
	end
	
	function db:onConnectionFailed( db, error )
		Log( LOG_SEVERE, "Tentative de connection échouée à la base de donnée MySQL:" .. error )
	end
	
	db:connect()

	MySQL.Query( "CREATE TABLE IF NOT EXISTS characters(pk INT PRIMARY KEY AUTO_INCREMENT, steamid64 VARCHAR(32), characterId INT, firstname VARCHAR(20), lastname VARCHAR(30), age INT, size INT, model VARCHAR(100))" )
	MySQL.Query( "CREATE TABLE IF NOT EXISTS characters_bodygroups(pk INT PRIMARY KEY AUTO_INCREMENT, characterId INT, skin INT, bg0 INT, bg1 INT, bg2 INT, bg3 INT, bg4 INT, bg5 INT, bg6 INT, bg7 INT, bg8 INT, bg9 INT, bg10 INT, bg11 INT, bg12 INT, bg13 INT, bg14 INT)" )
	MySQL.Query( "CREATE TABLE IF NOT EXISTS admin(pk INT PRIMARY KEY AUTO_INCREMENT, steamid64 VARCHAR(20) NOT NULL UNIQUE, usergroup VARCHAR(25))" )
end )

function MySQL.PrepareQuery( request, args )
	if ( not db ) then return nil end

	local query = db:prepare( request )

	if ( args ~= nil and  #args > 0 ) then
		for i = 1, #args do
			local arg = args[ i ]

			if ( arg == nil ) then
				query:setNull( i )
			else
				if ( query[ setQueryArgs[ type(arg) ] ] ) then
					query[ setQueryArgs[ type(arg) ] ]( query, i, arg )
				end
			end
		end
	end

	return query
end

function MySQL.Query( request, args, callbackOrShouldWait )
	if ( not db ) then return end
	
	local isCallbackFunc = isfunction( callbackOrShouldWait )
	
	if ( not request ) then
		if ( isCallbackFunc ) then
			callbackOrShouldWait( false, "Empty request!" )
		else
			return false, "Empty request!"
		end
	end
	
	local query = MySQL.PrepareQuery( request, args )

	if ( not query ) then
		if ( isCallbackFunc ) then
			callbackOrShouldWait( false, "Server can't connect to database." )
		else
			return false, "Server can't connect to database."
		end
	end

	if ( isCallbackFunc ) then
		function query:onSuccess( data )
			callbackOrShouldWait( data, nil )
		end
	end
	
	function query:onError( err )
		Log( LOG_SEVERE, "Une erreur est survenue lors d'une requête SQL: " .. err )

		if ( isCallbackFunc ) then
			callbackOrShouldWait( false, err )
		end
	end
	
	query:start()

	if ( callbackOrShouldWait == true ) then
		query:wait( true )
		return query:getData(), query:error()
	end
end