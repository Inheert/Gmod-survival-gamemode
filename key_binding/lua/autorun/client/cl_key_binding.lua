hook.Add( "PlayerButtonDown", "_FrameHook", function( ply, button )
	if ( not IsFirstTimePredicted() ) then return end

	if ( button == 93 && not IsValid( ply.frameCharacterCreation ) ) then
		net.Start( "CharacterCreator_RequestCharacter" )
		net.SendToServer()
	elseif ( button == 94 && not IsValid( ply.adminSystemFrame ) ) then
		ply.adminSystemFrame = vgui.Create( "admin_system_main_frame" )

		if ( not IsValid( ply.adminSystemFrame ) ) then return end

		ply.adminSystemFrame:MakePopup()
	end
end )

local Z_MIN = -1000
local Z_MAX = 2000
local ZONE_SIZE = 1024

local zones = {}

local function GenerateZones()
    local mapMin, mapMax = game.GetWorld():GetModelBounds()
	local mapMin = Vector(-5954, -5252, -954) -- X min, Y min, Z min
	local mapMax = Vector(3431, 7151, 2919) -- X max, Y max, Z max
	
    
    for x = mapMin.x, mapMax.x, ZONE_SIZE do
        for y = mapMin.y, mapMax.y, ZONE_SIZE do
            local zone = {
                min = Vector(x, y, Z_MIN),
                max = Vector(x + ZONE_SIZE, y + ZONE_SIZE, Z_MAX)
            }
            table.insert(zones, zone)
        end
    end

    print("Zones générées : ", #zones)
end

GenerateZones()

local function IsZoneOutsideMap(zone)
    local mapMin, mapMax = game.GetWorld():GetModelBounds()

    -- Vérifie si la zone est totalement à l'extérieur
    if zone.max.x < mapMin.x or zone.min.x > mapMax.x then return true end
    if zone.max.y < mapMin.y or zone.min.y > mapMax.y then return true end
    if zone.max.z < mapMin.z or zone.min.z > mapMax.z then return true end

    return false
end

-- Dessine les zones à l'écran
hook.Add("PostDrawOpaqueRenderables", "DrawGeneratedZones", function()
	if not zones or #zones == 0 then return end

	for _, zone in ipairs(zones) do
		if ( IsZoneOutsideMap( zone ) ) then continue end
		render.SetColorMaterial()
		render.DrawWireframeBox(
			Vector(0, 0, 0), -- Origine du monde
			Angle(0, 0, 0), -- Pas de rotation
			zone.min, -- Coordonnées minimales
			zone.max, -- Coordonnées maximales
			Color(255, 255, 255), -- Couleur de la boîte
			true -- Dessiner en transparence
		)
	end
end)

