include( "autorun/sh_conquest_system.lua" )
include( "autorun/client/menu/cl_group_main_frame.lua" )

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
	if not CONQUEST.zones or #CONQUEST.zones == 0 then return end

	local lastDraw = nil

	for _, xAlignedZone in ipairs(CONQUEST.zones) do
		for line, zone in ipairs( xAlignedZone ) do
			if ( IsZoneOutsideMap( zone ) ) then continue end
			render.SetColorMaterial()

			if ( LocalPlayer():GetActualZone() == zone) then
				lastDraw = zone
				continue 
			end
			render.DrawWireframeBox(
				Vector( 0, 0, 0 ), -- Origine du monde
				Angle( 0, 0, 0 ), -- Pas de rotation
				zone.min, -- Coordonnées minimales
				zone.max, -- Coordonnées maximales
				Color( 255, 255, 255 ), -- Couleur de la boîte
				true -- Dessiner en transparence
			)
		end
	end

	if ( lastDraw ) then
		render.DrawWireframeBox(
			Vector( 0, 0, 0 ), -- Origine du monde
			Angle( 0, 0, 0 ), -- Pas de rotation
			lastDraw.min, -- Coordonnées minimales
			lastDraw.max, -- Coordonnées maximales
			Color( 15, 15, 255 ), -- Couleur de la boîte
			true -- Dessiner en transparence
		)
	end
end)

hook.Add("PostDrawOpaqueRenderables", "DrawResourceBars", function()
	for __, xAlignedZone in ipairs( CONQUEST.zones ) do		
		for _, zone in pairs(xAlignedZone) do
			local zoneMin = zone.min
			local zoneMax = zone.max
			local resources = zone.naturalResource
			if resources then
				local barSpacing = 15
				local currentOffset = 0
				
				-- Parcourir chaque ressource dans la zone
				for name, _resource in pairs(resources) do
					local resourceQuantity = _resource.quantity or 0
					local resourceName = _resource.name or "Ressource"
					local barHeight = 10 * resourceQuantity
					local barWidth = (zoneMax.x - zoneMin.x) * (resourceQuantity / 100)
					local rarity = _resource.rarity or 1.0
	
					-- Calculer les dimensions de la barre
					local zoneCenter = (zoneMin + zoneMax) / 2
					local barPosition = Vector(
						zoneCenter.x + currentOffset,
						zoneCenter.y + currentOffset,
						0
					)
					-- Dessiner la barre 3D
					render.SetColorMaterial()
					render.DrawBox(
						Vector( barPosition ),
						Angle(0, 0, 0),
						Vector(-100, -100, 0), -- Dimensions négatives
						Vector(100, 100,barHeight), -- Dimensions positives
						_resource.color
					)
	
					-- Dessiner le texte au-dessus de la barre
					cam.Start3D2D(barPosition + Vector(0, 0, 0 - 10), Angle(0, LocalPlayer():EyeAngles().y - 90, 90), 0.5)
						draw.SimpleText(name .. " QUANTITY: " .. tostring( resourceQuantity ) .. "t", "Trebuchet24", 0, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
						draw.SimpleText(name .. " REFILL: " .. tostring( _resource.refill ) .. "/hour", "Trebuchet24", 0, 20, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					cam.End3D2D()
	
					-- Augmenter l'offset pour la prochaine barre
					currentOffset = currentOffset - 200
				end
			end
		end
	end
end)


hook.Add("HUDPaint", "ConquestZoneInfo", function()
	local zone = LocalPlayer():GetActualZone()

	if ( zone == -1 ) then return end

	-- Définir la police
	surface.SetFont("Trebuchet24")
	
	-- Définir la couleur du texte
	surface.SetTextColor(200, 200, 200, 255) -- Blanc avec transparence pleine
	surface.SetDrawColor( 50, 50, 50 )
	-- Position du texte
	local x, y = 10, 10 -- En haut à gauche de l'écran (10px de marge)


	-- Dessiner le texte
	surface.DrawRect( 0, 0, 300, 300 )
	surface.SetTextPos(x, y)
	surface.DrawText( "Id: " .. tostring(zone.id) )
	surface.SetTextPos(x, y + 20)
	surface.DrawText( "Status: " .. tostring(zone.status) )
	surface.SetTextPos(x, y + 40)
	surface.DrawText( "Occupant id: " .. tostring(zone.occupant) )
	for k, v in pairs( zone.naturalResource ) do
		surface.SetTextPos(x, y + 60)
		surface.DrawText( tostring( k  .. " storage: " .. tostring( v.quantity ) ) )
		y = y + 20
	end
end)
