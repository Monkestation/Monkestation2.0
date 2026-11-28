/datum/action/cooldown/vampire/unseen_presence
	name = "Unseen Presence"
	desc = "Blend into the shadows and become invisible to the artificial eye."
	button_icon_state = "power_unseen_presence"
	power_explanation = "Activate this Power and you will turn nearly invisible, scaling with your rank.\n\
		Additionally, while Unseen Presence is active, you are completely invisible to silicons."
	vampire_power_flags = BP_AM_TOGGLE
	vampire_check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 50
	constant_vitaecost = 1
	cooldown_time = 5 SECONDS
	var/unseen_alpha = 20

/datum/action/cooldown/vampire/unseen_presence/two
	vitaecost = 40
	constant_vitaecost = 2
	unseen_alpha = 15

/datum/action/cooldown/vampire/unseen_presence/three
	vitaecost = 30
	constant_vitaecost = 3
	unseen_alpha = 10

/datum/action/cooldown/vampire/unseen_presence/four
	vitaecost = 20
	constant_vitaecost = 4
	unseen_alpha = 5

/datum/action/cooldown/vampire/unseen_presence/activate_power()
	. = ..()
	var/mob/living/user = owner
	ADD_TRAIT(user, TRAIT_UNKNOWN, REF(src))
	user.add_movespeed_modifier(/datum/movespeed_modifier/unseen_presence)
	user.AddElement(/datum/element/digitalcamo)
	user.balloon_alert(user, "unseen presence turned on.")
	animate(user, alpha = unseen_alpha, time = 1 SECONDS)
	apply_wibbly_filters(user)

/datum/action/cooldown/vampire/unseen_presence/continue_active()
	. = ..()
	if(!.)
		return FALSE

	if(owner.stat != CONSCIOUS)
		to_chat(owner, span_warning("Your Unseen Presence failed because you fell unconcious!"))
		return FALSE
	return TRUE

/datum/action/cooldown/vampire/unseen_presence/deactivate_power()
	var/mob/living/user = owner

	remove_wibbly_filters(user, 1 SECONDS)
	animate(user, alpha = 255, time = 1 SECONDS)
	REMOVE_TRAIT(user, TRAIT_UNKNOWN, REF(src))
	user.RemoveElement(/datum/element/digitalcamo)
	user.remove_movespeed_modifier(/datum/movespeed_modifier/unseen_presence)
	user.balloon_alert(user, "unseen presence turned off.")
	return ..()

/datum/movespeed_modifier/unseen_presence
	multiplicative_slowdown = 1.5
