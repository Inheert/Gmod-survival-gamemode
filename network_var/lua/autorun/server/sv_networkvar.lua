hook.Add( "PlayerInitialSpawn", "setNetworkVarAndBaseclassForPlayer", function( ply )
	player_manager.SetPlayerClass( ply, "NOS_player" )
end )
