/mob/living/carbon/human/Initialize(mapload)
	. = ..()
	// This gives a random vocal bark to a random created person
	if(!client && !voice)
		voice = new()
		voice.randomise(src)

// we let borgs have some bark too
/mob/living/silicon/Login()
	if (!voice)
		voice = new()
	// This is the only found function that updates the client for borgs.
	voice.set_from_prefs(client?.prefs)
	. = ..()

/mob/living/basic/cow/initial_bark_id()
	return "goon.cow"

/*
	---- Changeling Profile ----
*/

/datum/changeling_profile
	var/datum/atom_voice/voice

/datum/antagonist/changeling/create_profile(mob/living/carbon/human/target, protect = 0)
	. = ..()
	var/datum/changeling_profile/new_profile = .
	new_profile.voice = new()
	new_profile.voice.copy_from(target.get_voice())

/datum/antagonist/changeling/transform(mob/living/carbon/human/user, datum/changeling_profile/chosen_profile)
	user.get_voice().copy_from(chosen_profile.voice)

/*
	---- Admin Tools ----
*/

/datum/smite/normalbark
	name = "Normal bark"

/datum/smite/normalbark/effect(client/user, mob/living/carbon/human/target)
	. = ..()
	target.get_voice().randomise(target)

/datum/admins/proc/togglebark()
	set category = "Server"
	set desc = "Toggles atom talk sounds."
	set name = "Toggle Barks"

	GLOB.barking_enabled = !GLOB.barking_enabled
	to_chat(world, "<span class='oocplain'><B>Vocal barks have been globally [GLOB.barking_enabled ? "enabled" : "disabled"].</B></span>")

	log_admin("[key_name(usr)] toggled Voice Barks.")
	message_admins("[key_name_admin(usr)] toggled Voice Barks.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Voice Bark", "[GLOB.barking_enabled ? "Enabled" : "Disabled"]")) // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/reload_bark_sounds_file()
	set category = "Server"
	set name = "Reload Barks"

	GLOB.bark_groups_visible = list()
	GLOB.bark_groups_all = list()
	GLOB.random_barks = list()
	GLOB.bark_list = gen_barks()
