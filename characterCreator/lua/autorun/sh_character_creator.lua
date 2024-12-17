CHARACTER_CREATION = CHARACTER_CREATION or {}

CHARACTER_CREATION.maxSlots = 3

CHARACTER_CREATION.charactersData = nil

CHARACTER_CREATION.baseCharacter = {
	model = "models/somali/somali_soldier.mdl",
	skin = { 0, 12 },
	bodygroups = {
		[0] = 0,
		[1] = 0,
		[2] = 0,
		[3] = 7,
		[4] = 0,
		[5] = 0,
		[6] = 0,
		[7] = 0,
		[8] = 0,
		[9] = 0,
		[10] = 0,
		[11] = 0,
		[12] = 0,
		[13] = 0,
		[14] = 0,
	},
	loadout = {}
}

if ( CLIENT ) then
	CHARACTER_CREATION.materials = {
		["background"] = Material( "characterCreation/background.jpg" )
	}
end