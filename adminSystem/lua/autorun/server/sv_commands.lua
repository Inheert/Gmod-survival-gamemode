include( "autorun/sh_admin_system.lua" )

--[[
	Exemple d'utilisation de AddCommand() :

	ADMIN_SYSTEM.AddCommand( {
	name = "test", -- identifiant utiliser en interne.
	command = "testcmd", -- la string permettant de trigger la commande.
	usergroup = "user", -- le usergroup autorisé à exécuter la commande.
	callback = 	function callbackName(arg1, arg2) -- La fonction callback.
		-- code
	end,
	args = { -- Les règles relatives aux arguments de la fonction callback.
		{
			type = "string"
		},
		{
			type = "number",
			min = 0,
			max = 10,
		}
	}
	
	la clé 'args' prends une table dont les index sont numériques et ordonnées, si la fonction callback est déclarée comme suit:
	function callbackName(arg1, arg2)
		-- code
	end

	En partant du principe que 'arg1' est une string et que 'arg2' est un nombre devant être compris entre 0 et 10,	alors la clé 'args' doit être déclarée comme suit:
	
	args = {
		{
			type = "string" -- Le type de l'argument
		},
		{
			type = "number",
			min = 0, -- La valeur minimum de l'int
			max = 10, -- la valeur maximum de l'int
		}
	}

	les règles des arguments dans la clé 'args' doivent être déclarée dans l'ordre dans lequel les arguments sont censés être reçu dans le callback.
} )
]]--

--[[
	Table permettant de vérifier la validité des données de la nouvelle commande.
]]--
ADMIN_SYSTEM.NewCommandFormat = {
	name = { 						-- Nom de la commande, cette string sert d'index dans le cache du script admin.
		type = "string",
		required = true,
	},
	command = {						-- La commande en question, la string qui pourra trigger la nouvelle commande.
		type = "string",
		required = true,
	},
	usergroup = {					-- Le usergroup nécessaire pour exécuter cette commande.
		type = "string",
		required = true,
	},
	serverCallable = {				-- Est-ce que la commande peut-être appelé depuis le serveur ?
		type = "boolean",
		required = true,
	},
	callback = {					-- La fonction callback de la commande
		type = "function",
		required = true
	},
	args = {						-- Liste des règles relatives aux arguments de la fonction callback, permet de prétraiter les arguments de la commande pour une meilleure sécurité.
		type = "table",
		required = false,
	},
	category = {					-- La catégorie dans laquelle sera rangée la commande dans le menu admin, si la catégorie n'est pas précisée alors la commande sera rangé dans 'autre'.
		type = "string",
		required = false,
	},
	targetEnts = {
		type = "table",
		available = { "player", "entity", "npc" },
		required = false
	}
}

--[[
	Table permettant de vérifier la validité des données de la clé 'args' de la nouvelle commande.
]]--
ADMIN_SYSTEM.NewCommandArgsFormat = {
	type = {						-- Le type attendu de cette argument, la clé 'available' étant les types de valeurs actuellement supportés.
		type = "string",
		available = { "string", "number", "boolean", "player", "entity" },
		required = true,
	},
	min = { 						-- La valeur minimum de l'argument, ne fonctionne qu'avec un nombre. 
		argType = "number",
		type = "number",
		required = false,
	},
	max = {							-- La valeur maximum de l'argument, ne fonctionne qu'avec un nombre.
		argType = "number",
		type = "number",
		required = false,
	},
	allowedValues = {				-- Un tableau de valeur correspond aux valeurs possible de l'argument.
		argType = { "string", "number" },
		type = "table",
		required = false,
	},
}

--[[
	Fonction vérifiant l'intégrité des données avant d'exécuter une commande.
	Chaque argument est cast dans le type qui lui correspond puis vérifié, ces arguments sont ensuites envoyés au callback.
	Pour résumer lorsqu'une commande est exécutée on vérifie:
		- Les permissions du joueur exécutant la commande.
		- Le nombre d'argument est suffisant ( nombre d'argument reçu >= nombre d'argument attendu ).
		- Le type des arguments.
	Les arguments sont ensuites cast dans le type souhaité et retourné dans une nouvelle table.
]]--

local function CheckCommandValidity( newCommandData, ply, cmd, args, argStr )
	if ( not IsValid( ply ) and not newCommandData.serverCallable ) then
		NWLog( LOG_WARN, newCommandData.usergroup, "Command", ADMIN_SYSTEM.CommandExecFail( ply, cmd, argStr, "commande non disponible depuis le serveur." ) )
		return false
	end

	if ( IsValid( ply ) and ADMIN_SYSTEM.HasPermission( ply:GetUserGroup(), newCommandData.usergroup ) == false ) then
		ply:ChatPrint( "Vous n'avez pas la capacité d'utiliser cette commande." )
		NWLog( LOG_WARN, newCommandData.usergroup, "Command", ADMIN_SYSTEM.CommandExecFail( ply, cmd, argStr, "Le joueur n'a pas les permissions requises." ) )
		return false
	end
	
	if ( type( newCommandData.args ) == "table" and #newCommandData.args > #args ) then
		if ( IsValid( ply ) ) then
			ply:ChatPrint( "Le nombre d'argument n'est pas égale au nombre souhaité." )
		end
		Log( LOG_WARN, ADMIN_SYSTEM.CommandExecFail( ply, cmd, argStr, "Nombre d'argument insuffisant." ) )
		return false
	end

	local newArgs = {}
	local tmp = nil

	for k, v in ipairs( newCommandData.args ) do
		local castedArg = nil

		if ( v.type == "string" ) then
			castedArg = tostring( args[ k ] )
		elseif( v.type == "number" ) then
			castedArg = tonumber( args[ k ] )
		elseif( v.type == "boolean" ) then
			if ( args[ k ] == "1" or args[ k ] == "true" ) then
				castedArg = true
			elseif ( args[ k ] == "0" or args[ k ] == "false" ) then
				castedArg = false
			end
		elseif ( v.type == "player" ) then
			if ( IsValid( args[ k ] ) and args[ k ]:IsPlayer() ) then
				castedArg = args[ k ]
			else
				tmp = player.GetBySteamID64( args[ k ] )
				if ( IsValid( tmp ) ) then
					castedArg = tmp
				else
					tmp = player.GetByID( tonumber(args[ k ] ))
					if ( IsValid( tmp ) )then
						castedArg = tmp
					end
				end
			end
		elseif ( v.type == "entity" ) then
			if ( IsValid( args[ k ] ) and isentity( args[ k ] ) ) then
				castedArg = args[ k ]
			elseif ( tonumber( args[ k ] ) ~= nil ) then
				tmp = ents.GetByIndex( tonumber( args[ k ] ) )

				if ( IsValid( tmp ) ) then
					castedArg = tmp
				end
			end
		end

		if ( castedArg == nil ) then
			if ( IsValid( ply ) ) then
				ply:ChatPrint( "Un argument ne possède pas le type souhaité." )
			end
			Log( LOG_WARN, ADMIN_SYSTEM.CommandExecFail( ply, cmd, argStr, "Type d'argument non valide." ) )
			return false
		end

		if ( type( v.allowedValues ) == "table" and #v.allowedValues > 0 ) then
			local valid = false

			for _, value in pairs( v.allowedValues ) do
				if ( value == castedArg ) then
					valid = true
					break
				end
			end

			if ( not valid ) then
				if ( IsValid( ply ) ) then
					ply:ChatPrint( "Un argument ne respecte pas la liste d'argument autorisée." )
				end
				Log( LOG_WARN, ADMIN_SYSTEM.CommandExecFail( ply, cmd, argStr, "La valeur d'un des arguments ne respecte pas les valeurs qui lui sont autorisées." ) )
				return false
			end
		end

		if ( v.type == "number" and type( v.min ) == "number" and castedArg < v.min ) then
			if ( IsValid( ply ) ) then
				ply:ChatPrint( "Un argument est inférieur à son minimum." )
			end
			Log( LOG_WARN, ADMIN_SYSTEM.CommandExecFail( ply, cmd, argStr, "Un des arguments est inférieur à son minimum." ) )
			return false
		elseif ( v.type == "number" and type( v.max ) == "number" and castedArg > v.max ) then
			if ( IsValid( ply ) ) then
				ply:ChatPrint( "Un argument est supérieur à son maximum." )
			end
			Log( LOG_WARN, ADMIN_SYSTEM.CommandExecFail( ply, cmd, argStr, "Un des arguments est supérieur à son maximum." ) )
			return false
		end

		table.insert( newArgs, castedArg )
	end
	return newArgs
end

--[[
	Enregistre la commande, encapsule le callback de la commande afin de vérifier que les arguments sont valides, ça ne veut pas pour autant
	dire qu'aucune vérification n'est à faire lors de la déclaration du callback dans l'appel de ADMIN_SYSTEM.AddCommand().
]]--
local function RegisterCommand( newCommandData )
	concommand.Add( newCommandData.command, function( ply, cmd, args, argStr )
		local newArgs = CheckCommandValidity( newCommandData, ply, cmd, args, argStr )

		if ( newArgs == false ) then return end
		
		local msg = ADMIN_SYSTEM.CommandExecSuccess( ply, cmd, argStr )
		
		NWLog( LOG_INFO, LOG.GetGoodUserLevel( ply ), "Command", msg )
		
		newCommandData.callback( ply, cmd, newArgs, argStr )
	end )
end

--[[
	Fonction permettant d'ajouter une commande, celle-ci vérifie que la table de la commande à ajouter est valide,
	Elle crée également la commande et encapsule la fonction callback dans une autre fonction afin de vérifier les arguments fournis.
]]--
function ADMIN_SYSTEM.AddCommand( newCommandData )
	local cmdFormat = ADMIN_SYSTEM.NewCommandFormat

	-- Vérifie le format de la table relative à la commande.
	for k, v in pairs( cmdFormat ) do
		if ( v.required and newCommandData[ k ] == nil ) then
			Log( LOG_WARN, ADMIN_SYSTEM.CommandExecFail( ply, cmd, argStr, "Une clé obligatoire à la création de la commande est manquante." ) )
			return
		elseif ( ( v.required and v.type ~= type( newCommandData[ k ] ) ) or ( not v.required and newCommandData[ k ] ~= nil and v.type ~= type( newCommandData[ k ] ) ) ) then
			Log( LOG_WARN, ADMIN_SYSTEM.CommandExecFail( ply, cmd, argStr, "Une des valeurs de la nouvelle commande ne possède pas le bon type." ) )
			return
		end

		if ( type( v.available ) == "table" ) then
			
		end
	end

	if ( ADMIN_SYSTEM.GROUPS[ newCommandData.usergroup ] == nil ) then
		Log( LOG_WARN, ADMIN_SYSTEM.CommandExecFail( ply, cmd, argStr, "Le usergroup fourni pour la nouvelle commande n'existe pas." ) )
		return
	end

	if ( type( newCommandData.targetEnts ) ~= "table" ) then
		newCommandData.targetEnts = {}
	end

	for _, targetEnt in ipairs( newCommandData.targetEnts ) do
		if (  targetEnt ~= "player" and targetEnt ~= "entity" and targetEnt ~= "npc" ) then
			Log( LOG_WARN, ADMIN_SYSTEM.CommandExecFail( ply, cmd, argStr, "Une valeur de la clé 'targetEnts' n'est pas valide." ) )
		end
	end

	local argsFormat = ADMIN_SYSTEM.NewCommandArgsFormat

	-- Vérifie le format de la table relative aux arguments.

	if ( type( newCommandData.args ) ~= "table" ) then
		newCommandData.args = {}
	end

	for _, cmdArgs in ipairs( newCommandData.args ) do		
		for k, v in pairs( argsFormat ) do
			if ( type( cmdArgs ) ~= "table" ) then break end
	
			if ( v.required and cmdArgs[ k ] == nil ) then
				Log( LOG_WARN, ADMIN_SYSTEM.CommandExecFail( ply, cmd, argStr, "Une clé obligatoire des arguments de la nouvelle commande est manquante." ) )
				return
			end
	
			-- Certaines valeurs peuvent avoir plusieurs types, c'est à ça que sert cette condition + boucle.
			if ( type( v.type ) == "table" ) then
				local valid = false
	
				for _, j in ipairs( v.type ) do
					if ( ( v.required and j == type( cmdArgs[ k ] ) ) or ( not v.required and cmdArgs[ k ] == nil ) ) then
						valid = true
						break
					end
				end
			
				if ( not valid ) then
					Log( LOG_WARN, ADMIN_SYSTEM.CommandExecFail( ply, cmd, argStr, "Un paramètre d'un des arguments de la nouvelle commande ne possède pas le bon type." ) )
					return 
				end
			elseif ( ( v.required and v.type ~= type( cmdArgs[ k ] ) ) or ( not v.required and cmdArgs[ k ] ~= nil and v.type ~= type( cmdArgs[ k ] ) ) ) then
				Log( LOG_WARN, ADMIN_SYSTEM.CommandExecFail( ply, cmd, argStr, "Un paramètre d'un des arguments de la nouvelle commande ne possède pas le bon type." ) )
				return
			end
	
			if ( type( v.available ) == "table" ) then
				local valid = false
	
				for _, j in ipairs( v.available ) do
					if ( cmdArgs[ k ] == j ) then
						valid = true 
						break
					end
				end
	
				if ( not valid ) then
					Log( LOG_WARN, ADMIN_SYSTEM.CommandExecFail( ply, cmd, argStr, "Un des paramètres d'un argument ne respecte pas sa liste de valeur autorisée." ) )
					return
				end
			end
		end
	end
	RegisterCommand( newCommandData )
	ADMIN_SYSTEM.commandsCache[ newCommandData.name ] = newCommandData
end

util.AddNetworkString( "adminPanelCommandExecution" )

net.Receive( "adminPanelCommandExecution", function( len, ply )
	if ( not IsValid( ply ) ) then return end

	local name = net.ReadString()
	local cmd = net.ReadString()
	local args = net.ReadEntity()
	local argStr = net.ReadString()

	local commandData = ADMIN_SYSTEM.commandsCache[ name ]

	if ( commandData == nil ) then return end

	if ( ADMIN_SYSTEM.HasPermission( ply:GetUserGroup(), commandData.usergroup ) == false ) then
		Log( LOG_WARN, ADMIN_SYSTEM.CommandExecFail( ply, cmd, argStr, "Le joueur n'a pas les permissions requises." ) )
		return
	end

	local newArgs = CheckCommandValidity( commandData, ply, cmd, {args}, argStr )

	if ( newArgs == false ) then return end

	local msg = ADMIN_SYSTEM.CommandExecSuccess( ply, cmd, argStr )
	
	NWLog( LOG_INFO, LOG.GetGoodUserLevel( ply ), "Command", msg )

	commandData.callback( ply, cmd, newArgs, argStr )
end )
