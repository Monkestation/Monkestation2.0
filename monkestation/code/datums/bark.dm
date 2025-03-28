GLOBAL_LIST_EMPTY(bark_groups)
GLOBAL_LIST_EMPTY(random_barks)
GLOBAL_LIST_INIT(bark_list, gen_barks())

/proc/gen_barks()
	var/output = rustg_read_toml_file("monkestation/code/game/barks.toml")

	var/list/bark_list = list()

	for (var/group_id in output)
		var/group_obj = output[group_id]
		var/group_name = group_obj["name"]
		var/group_path = group_obj["path"]
		var/list/group_barks = list()

		if (!group_name)
			stack_trace("Group " + group_id + " has no name")
			continue

		for (var/bark_name in group_obj)
			if (bark_name == "name" || bark_name == "path")
				continue
			var/bark_obj = group_obj[bark_name]
			var/datum/bark_voice/bark = new()

			bark.id = group_name + "." + bark_name
			bark.name = bark_name
			bark.group = group_name
			if (group_path)
				bark.talk = sound(group_path + "/" + bark_obj["path"])
			else
				bark.talk = sound(bark_obj["path"])
			if (!bark.talk)
				stack_trace("Bark " + bark_name + " has no talk sound")
				continue

			bark.max_pitch = bark_obj["max_pitch"]
			bark.min_pitch = bark_obj["min_pitch"]
			bark.max_speed = bark_obj["max_speed"]
			bark.min_speed = bark_obj["min_speed"]
			if (bark.max_pitch == null)
				bark.max_pitch = BARK_DEFAULT_MAXPITCH
			if (bark.min_pitch == null)
				bark.min_pitch = BARK_DEFAULT_MAXPITCH
			if (bark.max_speed == null)
				bark.max_speed = BARK_DEFAULT_MAXSPEED
			if (bark.min_speed == null)
				bark.min_speed = BARK_DEFAULT_MINSPEED

			group_barks += bark
			bark_list[bark.id] = bark
			if (bark_obj["allow_random"])
				GLOB.random_barks += bark.id

		GLOB.bark_groups[group_name] = group_barks

	return bark_list

/datum/bark_voice
	var/name
	var/id
	var/group

	var/sound/talk
	var/sound/ask_beep = null
	var/sound/exclaim_beep = null

	var/max_pitch
	var/min_pitch
	var/max_speed
	var/min_speed

/// Thank you SPLURT, FluffySTG and Citadel
// /datum/bark
// 	var/name = "None"
// 	var/id = "No Voice"
// 	var/soundpath

// 	var/minpitch = BARK_DEFAULT_MINPITCH
// 	var/maxpitch = BARK_DEFAULT_MAXPITCH
// 	var/minvariance = BARK_DEFAULT_MINVARY
// 	var/maxvariance = BARK_DEFAULT_MAXVARY

// 	// Speed vars. Speed determines the number of characters required for each bark, with lower speeds being faster with higher bark density
// 	var/minspeed = BARK_DEFAULT_MINSPEED
// 	var/maxspeed = BARK_DEFAULT_MAXSPEED

// 	// Visibility vars. Regardless of what's set below, these can still be obtained via adminbus and genetics. Rule of fun.
// 	var/list/ckeys_allowed
// 	var/ignore = FALSE // If TRUE - only for admins
// 	var/allow_random = FALSE

///

/mob/living/carbon/human/Initialize(mapload)
	. = ..()
	// This gives a random vocal bark to a random created person
	if(!client)
		voice.randomise(src)

// we let borgs have some bark too
/mob/living/silicon/Login()
	// This is the only found function that updates the client for borgs.
	voice.set_from_prefs(client?.prefs)
	. = ..()

GLOBAL_VAR_INIT(bark_allowed, TRUE) // For administrators

// Mechanics for Changelings
/datum/changeling_profile
	var/datum/atom_voice/voice

/datum/antagonist/changeling/create_profile(mob/living/carbon/human/target, protect = 0)
	. = ..()
	var/datum/changeling_profile/new_profile = .
	new_profile.voice = new()
	new_profile.voice.copy_from(target.voice)

/datum/antagonist/changeling/transform(mob/living/carbon/human/user, datum/changeling_profile/chosen_profile)
	user.voice.copy_from(chosen_profile.voice)


/datum/smite/normalbark
	name = "Normal bark"

/datum/smite/normalbark/effect(client/user, mob/living/carbon/human/target)
	. = ..()
	target.voice.randomise(target)

/datum/admins/proc/togglebark()
	set category = "Server"
	set desc = "Toggle the annoying voices."
	set name = "Toggle Character Voices"
	toggle_bark()
	log_admin("[key_name(usr)] toggled Voice Barks.")
	message_admins("[key_name_admin(usr)] toggled Voice Barks.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Voice Bark", "[GLOB.bark_allowed ? "Enabled" : "Disabled"]")) // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/proc/toggle_bark(toggle = null)
	if(toggle != null)
		if(toggle != GLOB.bark_allowed)
			GLOB.bark_allowed = toggle
		else
			return
	else
		GLOB.bark_allowed = !GLOB.bark_allowed
	to_chat(world, "<span class='oocplain'><B>Vocal barks have been globally [GLOB.bark_allowed ? "enabled" : "disabled"].</B></span>")

