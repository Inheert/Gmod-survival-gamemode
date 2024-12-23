include( "autorun/sh_conquest_system.lua" )

AddCSLuaFile( "autorun/client/menu/cl_group_main_frame.lua" )

CONQUEST.groupCache = CONQUEST.groupCache or {}

hook.Add( "Initialize", "ConquestInitialize", function()
    MySQL.Query( "SELECT * FROM conquest_groups", {}, function( data, err )
        if ( err ) then return end

        for k, v in ipairs( data ) do
            CONQUEST.groupCache[ v.groupe_id ] = v
        end
    end )
end )

util.AddNetworkString( "ConquestGroupeCreation" )
net.Receive( function( len, ply )
    local steamid64 = ply:SteamID64()
    if ( not IsValid( ply ) or not steamid64 or not CHARACTER_MANAGER.characterCache[ steamid64 ] ) then return end

    local groupeName = net.ReadString()

    if ( #text > CONQUEST.configs.groupeNameMaxLen or string.match( text, CONQUEST.configs.groupeNameRegex ) == nil ) then return end


end )