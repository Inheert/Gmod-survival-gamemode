include( "autorun/sh_conquest_system.lua" )

AddCSLuaFile( "autorun/client/menu/cl_group_main_frame.lua" )

CONQUEST.groupId = CONQUEST.groupId or {}
CONQUEST.groupCache = CONQUEST.groupCache or {}

PrintTable( CONQUEST.groupCache )

hook.Add( "Initialize", "conquestSystemInitialize", function()
    MySQL.Query( "SELECT * FROM conquest_groups", {}, function( data, err )
        if ( err ) then return end

        for k, v in ipairs( data ) do
            CONQUEST.groupCache[ v.groupe_id ] = v
            table.insert( CONQUEST.groupId, v.groupe_id )
        end

        table.sort( CONQUEST.groupCache )
    end )
end )

hook.Add( "PlayerSpawn", "conquestSystemPlayerSpawn", function( ply )
    for k, v in pairs( CONQUEST.groupCache ) do
        if ( ply:SteamID64() == v.leader_id ) then
            ply:SetCharacterGroup( v.groupe_id )
            break
        end
    end
end )

hook.Add( "PlayerDisconnected", "conquestSystemPlayerDisconnected", function( ply )
	print('data removed!')
	CHARACTER_MANAGER.characterCache[ ply:SteamID64() ] = nil
end )


-- MySQL.Query( "SELECT * FROM conquest_groups", {}, function( data, err )
--     if ( err ) then return end

--     for k, v in ipairs( data ) do
--         CONQUEST.groupCache[ v.groupe_id ] = v
--         table.insert( CONQUEST.groupId, v.groupe_id )
--     end

--     table.sort( CONQUEST.groupCache )
-- end )

local function GetNewGroupIdentifier()
	local newId = 0

	for i = 1, #CONQUEST.groupId - 1 do
		if ( CONQUEST.groupId[ i ] + 1 < CONQUEST.groupId[ i + 1 ] ) then
			return CONQUEST.groupId[ i ] + 1
		elseif ( CONQUEST.groupId[ i ] > i ) then
			return i - 1
		end
		newId = CONQUEST.groupId[ i + 1 ]
	end

	return newId + 1
end

util.AddNetworkString( "ConquestGroupeCreation" )
net.Receive( "ConquestGroupeCreation", function( len, ply )
    local steamid64 = ply:SteamID64()
    print( ply:GetCharacterGroup() )
    if ( not IsValid( ply ) or not steamid64 or not CHARACTER_MANAGER.characterCache[ steamid64 ] ) then return end
    if ( true ) then return end
    local characterId = ply:GetCharacterID()

    if ( ply:GetCharacterGroup() > 0 ) then return end

    local groupeName = net.ReadString()
    if ( #groupeName > CONQUEST.configs.groupeNameMaxLen or string.match( groupeName, CONQUEST.configs.groupeNameRegex ) == nil ) then return end

    local newGroupId = GetNewGroupIdentifier()
    MySQL.Query( "INSERT INTO conquest_groups(`groupe_id`, `groupe_name`, `leader_id`) VALUES (?, ?, ?)", { newGroupId, groupeName, characterId }, function( data, err )
        if ( err ) then return end

        CONQUEST.groupCache[ newGroupId ] = { groupe_id = newGroupId, groupe_name = groupeName, leader_id = characterId }
        table.insert( CONQUEST.groupId, newGroupId )
        table.sort( CONQUEST.groupId )

        ply:SetCharacterGroup( newGroupId )
    end )
end )
