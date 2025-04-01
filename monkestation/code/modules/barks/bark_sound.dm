/// Barks which can be selected by players, split into groups
GLOBAL_LIST_EMPTY(bark_groups_visible)
/// All barks, split into groups
GLOBAL_LIST_EMPTY(bark_groups_all)
/// Barks which can be picked randomly
GLOBAL_LIST_EMPTY(random_barks)
/// All barks
GLOBAL_LIST_INIT(bark_list, gen_barks())
/// Admin toggle
GLOBAL_VAR_INIT(barking_enabled, TRUE)

/proc/get_bark_sound(bark_obj, group_path, sound_name)
	var/sound_path = bark_obj[sound_name]
	if (!sound_path)
		return null
	if (group_path)
		return sound(group_path + "/" + sound_path)
	else
		return sound(sound_path)

/proc/gen_barks()
	var/output = rustg_read_toml_file("monkestation/code/game/barks.toml")

	var/list/bark_list = list()

	for (var/group_id in output)
		var/group_obj = output[group_id]
		var/group_name = group_obj["name"]
		var/group_path = group_obj["path"]
		// Alls barks in this group which do not have `hidden = true`
		var/list/visible_barks = list()
		// All barks in this group, is only created if needed
		var/list/all_barks = null

		if (!group_name)
			stack_trace("Group " + group_id + " has no name")
			continue

		for (var/bark_id in group_obj)
			if (bark_id == "name" || bark_id == "path")
				continue
			var/bark_obj = group_obj[bark_id]
			var/datum/bark_sound/bark = new()

			bark.id = group_id + "." + bark_id
			bark.name = bark_obj["name"]
			bark.group_name = group_name

			if (!bark.name)
				stack_trace("Bark " + bark.name + " has no name")
				continue

			bark.talk = get_bark_sound(bark_obj, group_path, "path")
			bark.ask = get_bark_sound(bark_obj, group_path, "ask")
			bark.exclaim = get_bark_sound(bark_obj, group_path, "exclaim")
			if (!bark.talk)
				stack_trace("Bark " + bark_id + " has no talk sound")
				continue

			// Setup parameters
			bark.max_pitch = bark_obj["max_pitch"]
			bark.min_pitch = bark_obj["min_pitch"]
			bark.max_speed = bark_obj["max_speed"]
			bark.min_speed = bark_obj["min_speed"]
			if (bark.max_pitch == null)
				bark.max_pitch = BARK_DEFAULT_MAXPITCH
			if (bark.min_pitch == null)
				bark.min_pitch = BARK_DEFAULT_MINPITCH
			if (bark.max_speed == null)
				bark.max_speed = BARK_DEFAULT_MAXSPEED
			if (bark.min_speed == null)
				bark.min_speed = BARK_DEFAULT_MINSPEED

			// Add to the bark lists
			bark_list[bark.id] = bark
			if (bark_obj["allow_random"])
				GLOB.random_barks += bark.id
			// Add to the group lists
			if (bark_obj["hidden"] && !all_barks)
				all_barks = visible_barks.Copy()
			if (!bark_obj["hidden"])
				visible_barks += bark
				bark.hidden = FALSE
			if (all_barks)
				all_barks += bark

		if (length(visible_barks))
			GLOB.bark_groups_visible[group_name] = visible_barks
		if (all_barks)
			GLOB.bark_groups_all[group_name] = all_barks
		else if (length(visible_barks))
			GLOB.bark_groups_all[group_name] = visible_barks

	return bark_list

/// Thank you SPLURT, FluffySTG and Citadel
/datum/bark_sound
	var/name
	var/id
	var/group_name

	var/sound/talk
	var/sound/ask = null
	var/sound/exclaim = null

	var/max_pitch
	var/min_pitch
	var/max_speed
	var/min_speed

	var/hidden = TRUE
