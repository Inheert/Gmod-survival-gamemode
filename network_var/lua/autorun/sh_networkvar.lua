DEFINE_BASECLASS("player_sandbox")

local PLAYER = {}

function PLAYER:Init()
end

function PLAYER:ViewModelChanged( viewModel, old, new )
end

function PLAYER:SetupDataTables()
	BaseClass.SetupDataTables( self )

	self.Player:NetworkVar( "Int", "CharacterID" )
	self.Player:NetworkVar( "Int", "CharacterGroup" )
	self.Player:NetworkVar( "Int", "UserGroup" )
end

player_manager.RegisterClass( "NOS_player", PLAYER, "player_sandbox" )
