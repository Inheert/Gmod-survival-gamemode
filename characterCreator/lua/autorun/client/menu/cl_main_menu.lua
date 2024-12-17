include( "autorun/sh_character_creator.lua" )

local materials = CHARACTER_CREATION.materials

local PANEL = {}

function PANEL:Init()
	local width = ScrW()
	local height = ScrH()

	self:SetSize( width, height )
	self:SetPos( 0, 0 )
	self:SetVisible( true )
	self:SetDraggable( false )
	self:ShowCloseButton( true )
	self:SetMouseInputEnabled( true )
	self:SetKeyboardInputEnabled( true )
	self:SetDeleteOnClose( true )
	self:SetTitle( "" )

	local containerWidth = width / CHARACTER_CREATION.maxSlots

	for i = 1, CHARACTER_CREATION.maxSlots do
		local container = vgui.Create( "DPanel", self )
		container:SetSize( containerWidth, height )
		container:SetPos( ( i - 1 ) * containerWidth, 0 )

		function container:Paint( w, h )
			surface.SetDrawColor( 0, 0, 0, 0 )
		end

		local character = CHARACTER_CREATION.characters[ i ]

		if ( character ) then
			local modelPanel = vgui.Create( "DModelPanel", container )
			modelPanel:SetSize( containerWidth, height * 0.7 )
			modelPanel:SetPos(0, height * 0.05)
			modelPanel:SetModel( character.model )
			function modelPanel:LayoutEntity(ent) end

			local panelEnt = modelPanel:GetEntity()
			panelEnt:SetSkin( character.skin )

			for id, bg in pairs( CHARACTER_CREATION.baseCharacter.bodygroups ) do
				panelEnt:SetBodygroup( id, character[ "bg" .. id ] )
			end
			
			local selectButton = vgui.Create( "DButton", container )
			selectButton:SetSize( containerWidth, height )
			selectButton:SetText( "" )

			function selectButton:Paint( btnW, btnH )
				surface.SetDrawColor( 0, 0, 0, 0 )
				surface.DrawRect( 0, 0, btnW, btnH )
				if self:IsHovered() then
					surface.SetDrawColor( 255, 255, 255, 2 )
					surface.DrawRect( 0, 0, btnW, btnH )
				end
				draw.SimpleText( character.lastname .. " " .. character.firstname, "DermaDefault", containerWidth / 2, height * 0.8, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end

			selectButton.DoClick = function( _self )
				self:Close()
	
				net.Start( "CharacterCreator_SelectCharacter" )
				net.WriteInt( character.characterId, 32 )
				net.SendToServer()
			end
		else
			local selectButton = vgui.Create( "DButton", container )
			selectButton:SetSize( containerWidth, height )
			selectButton:SetText( "" )

			function selectButton:Paint( btnW, btnH )
				surface.SetDrawColor( 0, 0, 0, 0 )
				surface.DrawRect( 0, 0, btnW, btnH )
				if self:IsHovered() then
					surface.SetDrawColor( 255, 255, 255, 2 )
					surface.DrawRect( 0, 0, btnW, btnH )
				end
				draw.SimpleText( "EMPLACEMENT VIDE", "DermaDefault", containerWidth / 2, height / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end

			function selectButton:DoClick()
				if IsValid( self.charCreationMenu ) then
					self.charCreationMenu:Close()
				end
				self.charCreationMenu = vgui.Create( "_char_creation_creation" )
				self.charCreationMenu:MakePopup()
			end
		end
	end
end

function PANEL:Paint( w, h )
	surface.SetDrawColor( 255, 255, 255 )
	surface.SetMaterial( materials.background )
	surface.DrawTexturedRect( 0, 0, w, h )
end

function PANEL:OnKeyCodePressed( button )
	if ( button == 93 ) then
		timer.Simple(0.1, function()
			if ( not IsValid( self ) ) then return end
			self:Close()
		end)
	end
end

vgui.Register( "_char_creation_main", PANEL, "DFrame" )
