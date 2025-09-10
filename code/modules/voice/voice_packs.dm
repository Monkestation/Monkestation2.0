/// Voice packs which can be selected by players, split into groups
GLOBAL_LIST_EMPTY(voice_pack_groups_visible)
/// All voice packs, split into groups
GLOBAL_LIST_EMPTY(voice_pack_groups_all)
/// Voice packs which can be picked randomly
GLOBAL_LIST_EMPTY(random_voice_packs)
/// All voice packs
GLOBAL_LIST_INIT(voice_pack_list, gen_voice_packs())
/// Admin toggle
GLOBAL_VAR_INIT(voices_enabled, TRUE)

/proc/get_voice_pack_sound(voice_pack_obj, group_path, sound_name)
	var/sound_path = voice_pack_obj[sound_name]
	if (!sound_path)
		return null
	if (group_path)
		return sound(group_path + "/" + sound_path)
	else
		return sound(sound_path)

/proc/gen_voice_packs()
	var/output = rustg_read_toml_file("config/monkestation/voice_packs.toml")

	var/list/voice_pack_list = list()

	for (var/group_id in output)
		var/group_obj = output[group_id]
		var/group_name = group_obj["name"]
		var/group_path = group_obj["path"]
		// Alls voice_packs in this group which do not have `hidden = true`
		var/list/visible_voice_packs = list()
		// All voice_packs in this group, is only created if needed
		var/list/all_voice_packs = null

		if (!group_name)
			stack_trace("Group " + group_id + " has no name")
			continue

		for (var/voice_pack_id in group_obj)
			if (voice_pack_id == "name" || voice_pack_id == "path")
				continue
			var/voice_pack_obj = group_obj[voice_pack_id]
			var/datum/voice_pack/voice_pack = new()

			voice_pack.id = group_id + "." + voice_pack_id
			voice_pack.name = voice_pack_obj["name"]
			voice_pack.group_name = group_name

			if (!voice_pack.name)
				stack_trace("Voice pack " + voice_pack.name + " has no name")
				continue

			voice_pack.sounds = list(
				get_voice_pack_sound(voice_pack_obj, group_path, "path"),
				get_voice_pack_sound(voice_pack_obj, group_path, "ask"),
				get_voice_pack_sound(voice_pack_obj, group_path, "exclaim"),
			)
			if (!voice_pack.sounds[1])
				stack_trace("Voice_pack " + voice_pack_id + " has no talk sound")
				continue
			for (var/i in 2 to 3)
				if (!voice_pack.sounds[i])
					voice_pack.sounds[i] = voice_pack.sounds[1]

			// Setup parameters
			voice_pack.max_pitch = voice_pack_obj["max_pitch"]
			voice_pack.min_pitch = voice_pack_obj["min_pitch"]
			voice_pack.max_speed = voice_pack_obj["max_speed"]
			voice_pack.min_speed = voice_pack_obj["min_speed"]
			voice_pack.volume = voice_pack_obj["volume"]
			if (voice_pack.max_pitch == null)
				voice_pack.max_pitch = VOICE_DEFAULT_MAXPITCH
			if (voice_pack.min_pitch == null)
				voice_pack.min_pitch = VOICE_DEFAULT_MINPITCH
			if (voice_pack.max_speed == null)
				voice_pack.max_speed = VOICE_DEFAULT_MAXSPEED
			if (voice_pack.min_speed == null)
				voice_pack.min_speed = VOICE_DEFAULT_MINSPEED
			if (voice_pack.volume == null)
				voice_pack.volume = 1

			// Add to the voice_pack lists
			voice_pack_list[voice_pack.id] = voice_pack
			if (voice_pack_obj["allow_random"])
				GLOB.random_voice_packs += voice_pack.id
			// Add to the group lists
			if (voice_pack_obj["hidden"] && !all_voice_packs)
				all_voice_packs = visible_voice_packs.Copy()
			if (!voice_pack_obj["hidden"])
				visible_voice_packs += voice_pack
				voice_pack.hidden = FALSE
			if (all_voice_packs)
				all_voice_packs += voice_pack

			voice_pack.is_goon = group_id == "goon" || voice_pack.hidden

		if (length(visible_voice_packs))
			GLOB.voice_pack_groups_visible[group_name] = visible_voice_packs
		if (all_voice_packs)
			GLOB.voice_pack_groups_all[group_name] = all_voice_packs
		else if (length(visible_voice_packs))
			GLOB.voice_pack_groups_all[group_name] = visible_voice_packs

	// Setup goon-only voice_packs system
	for (var/voice_pack_id in voice_pack_list)
		var/datum/voice_pack/voice_pack = voice_pack_list[voice_pack_id]
		if (!voice_pack.is_goon)
			voice_pack.goon_equiv = voice_pack_list[pick(GLOB.random_voice_packs)]

	return voice_pack_list

/// Thank you SPLURT, FluffySTG and Citadel
/datum/voice_pack
	var/name
	var/id
	var/group_name

	/// List of voice_pack sounds
	// 1 : talk
	// 2 : ask
	// 3 : exclaim
	var/list/sounds

	var/max_pitch
	var/min_pitch
	var/max_speed
	var/min_speed
	var/volume = 1

	var/hidden = TRUE

	var/is_goon
	var/datum/voice_pack/goon_equiv
