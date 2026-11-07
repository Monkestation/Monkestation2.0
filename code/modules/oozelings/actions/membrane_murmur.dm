/// Use your core to attempt to call out for help or attention.
/datum/action/cooldown/membrane_murmur
	name = "Membrane Murmur"
	desc = "Force your core to pass gasses to make noticable sounds."
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	button_icon_state = "gel_cocoon"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"

	cooldown_time = 25 SECONDS
	check_flags = NONE

	var/static/list/possible_cries = list(
		"Blorp... glub... help...",
		"Glooop... save me...",
		"Alone... burbble too quiet...",
		"What's left... of me...?",
		"Can't feel... can't... think...",
		"Plasma... need... plasma...",
		"It's so... quiet...",
	)

/datum/action/cooldown/membrane_murmur/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return
	var/mob/living/brain/brainmob = astype(owner)
	if(!istype(brainmob?.loc, /obj/item/organ/internal/brain/slime))
		return FALSE

/datum/action/cooldown/membrane_murmur/Activate()
	. = ..()
	var/mob/living/brain/brainmob = owner
	if(!istype(brainmob))
		CRASH("[src] cast by non-brainmob [owner?.type || "(null)"]")
	var/obj/item/organ/internal/brain/slime/brainitem = brainmob.loc
	var/final_cry = brainmob.Ellipsis(pick(possible_cries), chance = 30)
	brainitem.say(final_cry, "slime", forced = "[src]", message_range = 2)
