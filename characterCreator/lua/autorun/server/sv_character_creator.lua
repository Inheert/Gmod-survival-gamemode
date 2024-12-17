AddCSLuaFile( "autorun/client/menu/cl_main_menu.lua" )
AddCSLuaFile( "autorun/client/menu/cl_character_creation.lua" )

resource.AddFile( "materials/characterCreation/background.jpg" )

CHARACTER_CREATION.charactersId = CHARACTER_CREATION.charactersId or {}
CHARACTER_CREATION.characterCache = CHARACTER_CREATION.characterCache or {}

--[[
	Hook triggered at the start of the gamemode, it load every characterID so we can use them later without making new request.
]]--
hook.Add( "Initialize", "characterSystemInitialize", function()

	MySQL.Query( "SELECT characterId from characters", {}, function( data, err )
		if ( err ) then return end

		for k, v in ipairs( data ) do
			table.insert( CHARACTER_CREATION.charactersId, v.characterId )
		end

		table.sort( CHARACTER_CREATION.charactersId )
	end )
end )

-- MySQL.Query( "SELECT characterId from characters", {}, function( data, err )
-- 	if ( err ) then return end

-- 	for k, v in ipairs( data ) do
-- 		table.insert( CHARACTER_CREATION.charactersId, v.characterId )
-- 	end

-- 	table.sort( CHARACTER_CREATION.charactersId )
-- end )

--[[
	Load characters data into the character chache.
]]--
hook.Add( "PlayerInitialSpawn", "characterSystemPlayerInitialSpawn", function( ply )
	MySQL.Query( "SELECT c.*, cb.* from characters c INNER JOIN characters_bodygroups cb ON c.characterId = cb.characterId WHERE steamid64 = ?", { ply:SteamID64() }, function( data, err )
		if ( err ) then return end

		if ( data ~= nil and data[ 1 ] ~= nil and data[ 1 ].steamid64 ) then
			CHARACTER_CREATION.characterCache[ data[ 1 ].steamid64 ] = data
		end
	end )
end )

hook.Add( "PlayerSpawn", "characterSystemPlayerSpawn", function( ply )
	timer.Simple( 1, function()
		local characterid = ply:GetCharacterID()
		if ( characterid == 0 ) then
			ply:UpdateCharacters()
		else
			ply:CharacterSpawn()
		end
	end )
end )

hook.Add( "PlayerDisconnected", "characterSystemPlayerDisconnected", function( ply )
	print('data removed!')
	CHARACTER_CREATION.characterCache[ ply:SteamID64() ] = nil
end )

-- for k, ply in ipairs(player.GetAll()) do
-- 	MySQL.Query( "SELECT c.*, cb.* from characters c INNER JOIN characters_bodygroups cb ON c.characterId = cb.characterId WHERE steamid64 = ?", { ply:SteamID64() }, function( data, err )
-- 		if ( err ) then return end

-- 		if ( data ~= nil and data[ 1 ] ~= nil and data[ 1 ].steamid64 ) then
-- 			CHARACTER_CREATION.characterCache[ data[ 1 ].steamid64 ] = data
-- 		end
-- 	end )
-- end

--[[
	Function used to generate a new character based on thos who already exist.
]]--
local function GetNewCharacterIdentifier()
	local newId = 0

	for i = 1, #CHARACTER_CREATION.charactersId - 1 do
		if ( CHARACTER_CREATION.charactersId[ i ] + 1 < CHARACTER_CREATION.charactersId[ i + 1 ] ) then
			return CHARACTER_CREATION.charactersId[ i ] + 1
		elseif ( CHARACTER_CREATION.charactersId[ i ] > i ) then
			return i - 1
		end
		newId = CHARACTER_CREATION.charactersId[ i + 1 ]
	end

	return newId + 1
end


util.AddNetworkString( "CharacterCreator_RequestCharacter" )
net.Receive( "CharacterCreator_RequestCharacter", function( len, ply )
	Log(LOG_INFO, tostring( ply ) .. " data transfert")
	ply:UpdateCharacters()
end )

--[[ 
	Save the new character created by the player to the database and also add it to the character cache.
]]--
util.AddNetworkString( "CharacterCreator_CreateCharacter" )
net.Receive( "CharacterCreator_CreateCharacter", function( len, ply )
	local steamid64 = ply:SteamID64()

	if ( type( CHARACTER_CREATION.characterCache[ steamid64 ] ) == "table" and #CHARACTER_CREATION.characterCache[ steamid64 ] == CHARACTER_CREATION.maxSlots ) then return end

	local character = net.ReadTable()
	local characterId = GetNewCharacterIdentifier()
	character.characterId = characterId

	MySQL.Query("INSERT INTO characters(`steamid64`, `characterId`, `firstname`, `lastname`, `age`, `size`, `model`) VALUES(?, ?, ?, ?, ?, ?, ?)", {
		steamid64,
		characterId,
		character.firstname,
		character.lastname,
		character.age,
		character.size,
		character.model })

	local baseCharacter = CHARACTER_CREATION.baseCharacter

	character["bg0"] = baseCharacter.bodygroups[0]
	character["bg1"] =baseCharacter.bodygroups[1]
	character["bg2"] =baseCharacter.bodygroups[2]
	character["bg3"] =baseCharacter.bodygroups[3]
	character["bg4"] =baseCharacter.bodygroups[4]
	character["bg5"] =baseCharacter.bodygroups[5]
	character["bg6"] =baseCharacter.bodygroups[6]
	character["bg7"] =baseCharacter.bodygroups[7]
	character["bg8"] =baseCharacter.bodygroups[8]
	character["bg9"] =baseCharacter.bodygroups[9]
	character["bg10"] =baseCharacter.bodygroups[10]
	character["bg11"] =baseCharacter.bodygroups[11]
	character["bg12"] =baseCharacter.bodygroups[12]
	character["bg13"] =baseCharacter.bodygroups[13]
	character["bg14"] =baseCharacter.bodygroups[14]

	MySQL.Query( "INSERT INTO characters_bodygroups(`characterId`, `skin`, `bg0`, `bg1`, `bg2`, `bg3`, `bg4`, `bg5`, `bg6`, `bg7`, `bg8`, `bg9`, `bg10`, `bg11`, `bg12`, `bg13`, `bg14`) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", {
		characterId,
		character.skin,
		baseCharacter.bodygroups[0],
		baseCharacter.bodygroups[1],
		baseCharacter.bodygroups[2],
		baseCharacter.bodygroups[3],
		baseCharacter.bodygroups[4],
		baseCharacter.bodygroups[5],
		baseCharacter.bodygroups[6],
		baseCharacter.bodygroups[7],
		baseCharacter.bodygroups[8],
		baseCharacter.bodygroups[9],
		baseCharacter.bodygroups[10],
		baseCharacter.bodygroups[11],
		baseCharacter.bodygroups[12],
		baseCharacter.bodygroups[13],
		baseCharacter.bodygroups[14],
	} )

	table.insert( CHARACTER_CREATION.charactersId, characterId )
	table.sort( CHARACTER_CREATION.charactersId )

	if ( type( CHARACTER_CREATION.characterCache[ steamid64 ] ) == "table" ) then		
		table.insert( CHARACTER_CREATION.characterCache[ steamid64 ], character )
	else
		CHARACTER_CREATION.characterCache[ steamid64 ] = { character }
	end

	Log(LOG_INFO, tostring( ply ) .. " character created!")

	ply:UpdateCharacters()
end )

--[[
	Used to load character when the player selected.
]]--
util.AddNetworkString( "CharacterCreator_SelectCharacter" )
net.Receive( "CharacterCreator_SelectCharacter", function( len, ply )
	local characterid = net.ReadInt( 32 )

	ply:SetCharacterID( characterid )

	Log(LOG_INFO, tostring( ply ) .. "character selected!")

	ply:CharacterSpawn()
end )

--[[
	Used to communicate characters data to client.
]]--
local metaPly = FindMetaTable( "Player" )

function metaPly:UpdateCharacters()
	local steamid = self:SteamID64()
	local characters = {}

	if ( type( CHARACTER_CREATION.characterCache[ steamid ] ) ~= "table" ) then 
		MySQL.Query( "SELECT c.*, cb.* from characters c INNER JOIN characters_bodygroups cb ON c.characterId = cb.characterId WHERE steamid64 = ?", { self:SteamID64() }, function( data, err )
			if ( err ) then return end
	
			CHARACTER_CREATION.characterCache[ steamid ] = data

			net.Start( "CharacterCreator_RequestCharacter" )
			net.WriteTable( CHARACTER_CREATION.characterCache[ steamid ] )
			net.Send( self )
		end )
	else
		net.Start( "CharacterCreator_RequestCharacter" )
		net.WriteTable( CHARACTER_CREATION.characterCache[ steamid ] )
		net.Send( self )
	end


	Log(LOG_INFO, tostring( self ), " data sended to player!")
end

function metaPly:CharacterSpawn()
	local characters = CHARACTER_CREATION.characterCache[ self:SteamID64() ]
	
	if ( type( characters ) ~= "table" ) then return end
	
	local selectedCharacter = nil 
	for _, v in ipairs( characters ) do
		if ( v.characterId == self:GetCharacterID() ) then
			selectedCharacter = v
			break
		end
	end
	
	if ( type( selectedCharacter ) ~= "table" ) then return end
	
	self:SetModel( selectedCharacter.model )
	self:SetSkin( selectedCharacter.skin )

	for id, bg in pairs( CHARACTER_CREATION.baseCharacter.bodygroups ) do
		self:SetBodygroup( id, selectedCharacter[ "bg" .. id ] )
	end

	Log(LOG_SUCCESS, tostring( self ) .. " character fully spawn!1")
end
