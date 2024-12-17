include( "autorun/client/menu/cl_main_menu.lua" )
include( "autorun/client/menu/cl_character_creation.lua" )

function OpenFrame()
	net.Start( "CharacterCreator_RequestCharacter" )
	net.SendToServer()
end

net.Receive( "CharacterCreator_RequestCharacter", function()
	local ply = LocalPlayer()

	CHARACTER_CREATION.characters = net.ReadTable() 

	if ( IsValid( ply.frameCharacterCreation ) ) then
		ply.frameCharacterCreation:Close()
	end

	ply.frameCharacterCreation = vgui.Create( "_char_creation_main" )

	if ( ply.frameCharacterCreation == nil ) then return end

	ply.frameCharacterCreation:MakePopup()
end )

-- hook.Add( "PlayerButtonDown", "_FrameHook", function( ply, button )
-- 	if ( not IsFirstTimePredicted() ) then return end

-- 	if ( button == 93 && not IsValid( ply.frameCharacterCreation ) ) then
-- 		OpenFrame()
-- 	end
-- end )