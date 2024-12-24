CONQUEST = CONQUEST or {}

function util.DeepCopy(orig, exclude_keys, seen)
	exclude_keys = exclude_keys or {}
	seen = seen or {} 

	if seen[orig] then
		return seen[orig]
	end

	local orig_type = type(orig)
	local copy

	if orig_type == 'table' then
		copy = {}
		seen[orig] = copy

		for orig_key, orig_value in next, orig, nil do
			if not exclude_keys[orig_key] then
				copy[util.DeepCopy(orig_key, exclude_keys, seen)] = util.DeepCopy(orig_value, exclude_keys, seen)
			end
		end
		local orig_metatable = getmetatable(orig)
		if orig_metatable and type(orig_metatable) == "table" then
			setmetatable(copy, util.DeepCopy(orig_metatable, exclude_keys, seen))
		end
	else -- number, string, boolean, etc.
		copy = orig
	end

	return copy
end

function util.makeReadOnlyTable( tbl )
	return setmetatable( {}, {
		__index = tbl,
		__newindex = function( _, key, value )
			error( "Attempting to modify a read-only table: " .. key )
		end,
		__metatable = false
	} )
end

CONQUEST.configs = util.makeReadOnlyTable( {
    zoneSize = 1024,
    mapMin = Vector( -5954, -5252, -1000 ),
    mapMax = Vector( 3431, 7151, 3000 ),
    maxZLength = 5000,
    naturalResourcesBaseStock = 100, -- quantité de base
    naturalResourcesBaseRefill = 10, -- réaprovisionnement par heure
    groupeNameMaxLen = 25,
    groupeNameRegex = "^[a-zA-Z0-9 _]+$",
} )

-- Définir une table constante
CONQUEST.CONST = util.makeReadOnlyTable( {
    AREA_FREE = 0,
    AREA_BEING_CAPTURED = 1,
    AREA_CAPTURED = 2,
    AREA_IN_CONFLICT = 3,
    AREA_ABANDONNED = 4,
} )

CONQUEST.STR = {}

CONQUEST.STR.TITLE = util.makeReadOnlyTable( {
    [ CONQUEST.CONST.AREA_FREE ] = "Zone libre.",
    [ CONQUEST.CONST.AREA_BEING_CAPTURED ] = "Zone en cours de capture.",
    [ CONQUEST.CONST.AREA_CAPTURED ] = "Zone capturée.",
    [ CONQUEST.CONST.AREA_IN_CONFLICT ] = "Zone en conflit",
    [ CONQUEST.CONST.AREA_ABANDONNED ] = "Zone abandonnée",
} )

function CONQUEST:GetConstStr( _const )
    if ( type( _const ) ~= "number" ) then return end

    return self.STR[ _const ]
end

CONQUEST.zoneTemplate = {
    id = 0,                             -- Id unique de la zone
    min = Vector( 0, 0, 0 ),            -- Position min de la zone
    max = Vector( 0, 0, 0 ),            -- Poisition max de la zone
    status = CONQUEST.CONST.AREA_FREE,  -- Le status actuel de la zone, libre, en cours de capture, capturée, en conflit, abandonnée
    occupant = 0,                       -- Id de la faction qui occupe la zone 
    naturalResource = {                 -- Liste des ressources naturelles produitent par la zone
    },
}

CONQUEST.naturalResources = {
    steel = {
        name = "Fer",
        hotSpotProbability = 0.3,
        hotSpotIntensity = 0.4,
        hotSpotIntensityNoise = 0.2,
        hotSpotRefillIntensity = 1.2,
        hotSpotRefillIntensityNoise = 0.3,
        color = Color( 255, 0 , 0, 150 ),
        rarity = 0.8,
        quantity = 0,
        refill = 0,
    },
    coal = {
        name = "Charbon",
        hotSpotProbability = 0.2,
        hotSpotIntensity = 0.7,
        hotSpotIntensityNoise = 0.3,
        hotSpotRefillIntensity = 1.2,
        hotSpotRefillIntensityNoise = 0.3,
        color = Color( 0, 0 , 255, 150 ),
        rarity = 0.9,
        quantity = 0,
        refill = 0
    },
    goald = {
        name = "Or",
        hotSpotProbability = 0.2,
        hotSpotIntensity = 0.1,
        hotSpotIntensityNoise = 0.1,
        hotSpotRefillIntensity = 0.5,
        hotSpotRefillIntensityNoise = 0.1,
        color = Color( 255, 255, 0, 150 ),
        rarity = 0.1,
        quantity = 0,
        refill = 0,
    }
}

CONQUEST.zones = {}

function CONQUEST:GenerateZones()
    local zoneSize, mapMin, mapMax, maxZLength = CONQUEST.configs.zoneSize, CONQUEST.configs.mapMin, CONQUEST.configs.mapMax, CONQUEST.configs.maxZLength

    local id = 1

    for x = mapMin.x, mapMax.x, zoneSize do
        local XalignedZone = {}
        for y = mapMin.y, mapMax.y, zoneSize do
            local zone = util.DeepCopy( self.zoneTemplate, {} )
            zone.min = Vector( x, y, mapMin.z )
            zone.max = Vector( x + zoneSize, y + zoneSize, math.Clamp( mapMax.z, mapMin.z, mapMin.z + maxZLength ) )
            zone.id = id
            id = id + 1

            table.insert( XalignedZone, zone )
        end
        table.insert( CONQUEST.zones, XalignedZone )
    end
end

function CONQUEST:GenerateHotSpotResource( _resource )
    local isHotSpot = math.Rand( 0, 1 )

    if ( isHotSpot > _resource.hotSpotProbability ) then return false end

    local intensity, noise = _resource.hotSpotIntensity, _resource.hotSpotIntensityNoise

    local hotSpotIntensity = math.Round( math.Rand( intensity - noise, intensity + noise ), 3 )
    local hotSpotBaseStock = self.configs.naturalResourcesBaseStock * hotSpotIntensity

    intensity, noise = _resource.hotSpotRefillIntensity, _resource.hotSpotRefillIntensityNoise

    local hotSpotRefillIntensity = math.Round( math.Rand( intensity - noise, intensity + noise ), 3 )
    local hotSpotBaseRefill = self.configs.naturalResourcesBaseRefill * hotSpotRefillIntensity
    
    return hotSpotBaseStock, hotSpotBaseRefill
end

function CONQUEST:DispatchResources()
    if ( not self.zones or #self.zones == 0 ) then return end

    local xSize = #self.zones
    local ySize = #self.zones[ 1 ]

    local steel, coal, zoneCount = 0, 0, 0

    for _, xAlignedZone in ipairs( self.zones ) do
        for __, zone in ipairs( xAlignedZone ) do            
            zoneCount = zoneCount + 1
            local zoneNaturalResources = {}
            for name, _resource in pairs( self.naturalResources ) do
                local baseStock, baseRefill = self:GenerateHotSpotResource( _resource )

                if ( not baseStock and not baseRefill ) then continue end

                if ( name == "steel" ) then
                    steel = steel + 1
                elseif (name == "coal") then
                    coal = coal + 1
                end
                
                local resourceHotSpot = util.DeepCopy( _resource, {} )
                resourceHotSpot.quantity = baseStock
                resourceHotSpot.refill = baseRefill

                zone.naturalResource[ name ] = resourceHotSpot
            end

        end
    end
    -- print( "Nombre de zone: " .. tostring( zoneCount ) .. " Fer hotspot: " .. tostring( steel ) .. " Charbon hotspot: " .. tostring( coal ) )
    -- print(xSize, ySize)
end

CONQUEST:GenerateZones()
CONQUEST:DispatchResources()

local playerMetatable = FindMetaTable( "Player" )

function playerMetatable:GetActualZone()
    local pos = self:GetPos()
    local configs = CONQUEST.configs

    if ( not pos:WithinAABox( configs.mapMin, configs.mapMax ) ) then return -1 end

    local xDist = pos.x - configs.mapMin.x
    local xIdx = math.floor(1 + xDist / configs.zoneSize)

    local yDist = pos.y - configs.mapMin.y
    local yIdx = math.floor(1 + yDist / configs.zoneSize)
    return CONQUEST.zones[ xIdx ][ yIdx ]
end
