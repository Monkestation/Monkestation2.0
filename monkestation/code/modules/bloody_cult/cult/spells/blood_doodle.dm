/obj/effect/decal/cleanable/blood/writing
	icon = 'monkestation/code/modules/bloody_cult/icons/effects.dmi'
	icon_state = "nothing"
	can_dry = FALSE

/datum/action/cooldown/blood_doodle
	name = "Blood Doodle"
	desc = "Draw a blood rune message on the ground for others to see."
	button_icon_state = "cult_word"
	button_icon = 'monkestation/code/modules/bloody_cult/icons/spells.dmi'
	background_icon = 'monkestation/code/modules/bloody_cult/icons/spells.dmi'
	background_icon_state = "const_spell_base"

	var/override = FALSE

/datum/action/cooldown/blood_doodle/PreActivate(atom/target)
	. = ..()
	if(!override)
		var/datum/team/cult/cult_team = locate_team(/datum/team/cult)
		if(!cult_team)
			return

		if(!GLOB.eclipse.eclipse_start_time || GLOB.eclipse.eclipse_finished)
			return


/datum/action/cooldown/blood_doodle/Activate(atom/target)
	. = ..()
	var/turf/parent_turf = get_turf(owner)

	if(locate(/obj/effect/decal/cleanable/blood/writing) in parent_turf)
		to_chat(span_cultbold("There is already a blood drawing here"))
		return

	var/obj/effect/decal/cleanable/blood/blood = locate(/obj/effect/decal/cleanable/blood) in parent_turf
	if(!blood)
		to_chat(span_cultbold("There is no blood to draw with here!"))
		return

	var/blood_color = blood.color

	var/maximum_length = 30
	var/message = stripped_input(owner, "Write a message. You will be able to preview it.", "Bloody writings", "")
	if(!message)
		return
	message = copytext(message, 1, maximum_length)

	var/letter_amount = length(replacetext(message, " ", ""))
	if(!letter_amount) //If there is no text
		return

	var/angle = rand(-25, 25)
	var/image/preview = image(icon = null)
	preview.maptext = MAPTEXT_YOU_MURDERER("<span style = 'text-align: center; -dm-text-outline: 1px black; color:[blood_color]'> [message] </span>")
	preview.maptext_height = 64
	preview.maptext_width = 128
	preview.maptext_x = -48
	preview.maptext_y = 8
	preview.alpha = 180
	preview.loc = parent_turf
	preview.transform = matrix(angle, MATRIX_ROTATE)

	owner.client?.images.Add(preview)
	var/continue_drawing = alert(owner, "This is how your message will look. Continue?", "Bloody writings", "Yes", "Cancel")
	owner.client?.images.Remove(preview)
	animate(preview)
	preview.loc = null
	qdel(preview)

	if(continue_drawing != "Yes")
		return

	message_admins("[owner] created a blood doodle containing the phrase:[message][ADMIN_JMP(parent_turf)]")
	var/obj/effect/decal/cleanable/blood/writing/spawned_writing = new /obj/effect/decal/cleanable/blood/writing(parent_turf)
	spawned_writing.color = blood_color

	spawned_writing.maptext = MAPTEXT_YOU_MURDERER("<span style = 'text-align: center; -dm-text-outline: 1px black; color:[blood_color]'> [message] </span>")
	spawned_writing.maptext_height = 64
	spawned_writing.maptext_width = 128
	spawned_writing.maptext_x = -48
	spawned_writing.maptext_y = 8
	spawned_writing.transform = matrix(angle, MATRIX_ROTATE)
	qdel(blood)
