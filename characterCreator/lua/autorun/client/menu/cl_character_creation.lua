include( "autorun/sh_character_creator.lua" )

local materials = CHARACTER_CREATION.materials
local baseCharacter = CHARACTER_CREATION.baseCharacter

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

	-- Prévisualisation du modèle
	local modelPanel = vgui.Create( "DModelPanel", self )
	modelPanel:SetSize( width * 0.4, height * 0.8 )
	modelPanel:SetPos( width * 0.05, height * 0.1 )
	modelPanel:SetModel( baseCharacter.model )
	function modelPanel:LayoutEntity(ent) end

	local modelEnt = modelPanel:GetEntity()
	for k, v in ipairs(baseCharacter.bodygroups) do
		modelEnt:SetBodygroup(k, v)
	end

	-- Champ Nom
	local nameEntry = vgui.Create( "DTextEntry", self )
	nameEntry:SetSize( width * 0.3, height * 0.05 )
	nameEntry:SetPos( width * 0.55, height * 0.2 )
	nameEntry:SetPlaceholderText( "Nom" )

	-- Champ Prénom
	local firstNameEntry = vgui.Create( "DTextEntry", self )
	firstNameEntry:SetSize( width * 0.3, height * 0.05 )
	firstNameEntry:SetPos( width * 0.55, height * 0.3 )
	firstNameEntry:SetPlaceholderText( "Prénom" )

	-- Slider Âge
	local ageSlider = vgui.Create( "DNumSlider", self )
	ageSlider:SetSize( width * 0.3, height * 0.05 )
	ageSlider:SetPos( width * 0.55, height * 0.4 )
	ageSlider:SetText( "Âge" )
	ageSlider:SetMin( 18 )
	ageSlider:SetMax( 30 )
	ageSlider:SetValue( 25 )
	ageSlider:SetDecimals( 0 )
	function ageSlider:OnValueChanged( value )
		self:SetValue( math.Round( value ) )
	end

	-- Slider taille
	local sizeSlider = vgui.Create( "DNumSlider", self )
	sizeSlider:SetSize( width * 0.3, height * 0.05 )
	sizeSlider:SetPos( width * 0.55, height * 0.5 )
	sizeSlider:SetText( "Taille (cm)" )
	sizeSlider:SetMin( 160 )
	sizeSlider:SetMax( 190 )
	sizeSlider:SetValue( 175 )
	sizeSlider:SetDecimals( 0 )
	function sizeSlider:OnValueChanged( value )
		self:SetValue( math.Round( value ) )

		local baseHeight = 180
		local scaleFactor = baseHeight / value
		modelPanel:SetCamPos(Vector(50 * scaleFactor, 50, 50 * scaleFactor))
		modelPanel:SetLookAt(Vector(0, 0, 40 * scaleFactor))
	end
	
	-- Slider Modèle
	local faceSlider = vgui.Create( "DNumSlider", self )
	faceSlider:SetSize( width * 0.3, height * 0.05 )
	faceSlider:SetPos( width * 0.55, height * 0.6 )
	faceSlider:SetText( "Modèle" )
	faceSlider:SetMin( baseCharacter.skin[ 1 ] )
	faceSlider:SetMax( baseCharacter.skin[ 2 ] )
	faceSlider:SetValue( 0 )
	faceSlider:SetDecimals( 0 )
	function faceSlider:OnValueChanged( value )
		local roundedValue = math.Round( value )
		self:SetValue( roundedValue )
		modelPanel:GetEntity():SetSkin( roundedValue )
	end

	-- Bouton de Validation
	local submitButton = vgui.Create( "DButton", self )
	submitButton:SetText( "Créer Personnage" )
	submitButton:SetSize( width * 0.3, height * 0.05 )
	submitButton:SetPos( width * 0.55, height * 0.7 )
	submitButton.DoClick = function( _self )
		local name = nameEntry:GetValue()
		local firstName = firstNameEntry:GetValue()
		local age = ageSlider:GetValue()
		local size = sizeSlider:GetValue()
		local model = faceSlider:GetValue()

		if ( not (name ~= "" and firstName ~= "" ) ) then
			return
		end

		local character = {
			firstname = firstName,
			lastname = name,
			age = age,
			size = size,
			model = baseCharacter.model,
			skin = modelEnt:GetSkin(),
		}

		self:Close()

		net.Start( "CharacterCreator_CreateCharacter" )
		net.WriteTable( character )
		net.SendToServer()
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

vgui.Register( "_char_creation_creation", PANEL, "DFrame" )
