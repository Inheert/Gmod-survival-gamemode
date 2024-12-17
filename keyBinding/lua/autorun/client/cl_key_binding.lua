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