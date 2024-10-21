
// IPCs were once not allowed to have genders - and thus, not allowed to have pronouns. Due to
// gender not being saved unless it's been changed, this means plenty of IPCs don't have a gender in
// their save data, or may even have a old gender.
//
// If the old data has no gender, the game will normally randomly pick a gender to give them. For
// IPCs, this is no concern, as they get set back to PLURAL immediately. But, with the change
// allowing them to have genders, this means they'll normally get a random gender - which can lead
// to confusion among players when their IPC suddenly has a random gender that they didn't expect.
//
// The same can also happen if the save data has an old gender that they don't even remember
// setting - or assumed that it was changed to plural.
//
// To solve this, if the character is an IPC and the character data is too old, we set their gender
// to plural during loading of the character.
/datum/preferences/proc/monkestation_set_ipc_genders(list/save_data)
	if(save_data["species"] == SPECIES_IPC)
		save_data["gender"] = PLURAL
