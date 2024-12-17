include( "autorun/sh_admin_system.lua" )

ADMIN_SYSTEM.playersOldPosCache = ADMIN_SYSTEM.playersPosCache or {}

ADMIN_SYSTEM.AddCommand( {
	name = "goto",
	command = "goto",
	usergroup = "admin",
	category = "Téléportation",
	serverCallable = false,
	targetEnts = { "player", "npc", "entity" },
	args = {
		{
			type = "entity"
		}
	},
	callback = function( caller, cmd, args )
		local target = args[ 1 ]

		if ( not IsValid( target ) or not IsValid( caller ) ) then return end

		local oldPos = caller:GetPos()
		local newPos = target:GetPos() + Vector( 100, 100, 100 )

		caller:SetPos( newPos )

		ADMIN_SYSTEM.playersOldPosCache[ caller ] = oldPos
	end
} )

ADMIN_SYSTEM.AddCommand( {
	name = "bring",
	command = "bring",
	usergroup = "admin",
	category = "Téléportation",
	serverCallable = false,
	targetEnts = { "player" },
	args = {
		{
			type = "player"
		}
	},
	callback = function( caller, cmd, args )
		local target = args[ 1 ]

		if ( not IsValid( target ) or not IsValid( caller ) ) then return end

		local oldPos = target:GetPos()
		local newPos = caller:GetPos() + caller:GetForward() * Vector( 100, 100, 300 ) + Vector( 0, 0, 100 )

		target:SetPos( newPos )
	
		ADMIN_SYSTEM.playersOldPosCache[ target ] = oldPos
	end
} )


ADMIN_SYSTEM.AddCommand( {
	name = "return",
	command = "return",
	usergroup = "admin",
	category = "Téléportation",
	serverCallable = true,
	targetEnts = { "player" },
	args = {
		{
			type = "player"
		}
	},
	callback = function( caller, cmd, args )
		local target = args[ 1 ]

		if ( not IsValid( target ) or ADMIN_SYSTEM.playersOldPosCache[ target ] == nil ) then return end

		local oldPos = target:GetPos()

		target:SetPos( ADMIN_SYSTEM.playersOldPosCache[ target ] )

		ADMIN_SYSTEM.playersOldPosCache[ target ] = oldPos
	end
} )