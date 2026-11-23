/datum/action/cooldown/borer/toggle_hiding
	name = "Toggle Hiding"
	button_icon_state = "hide"
	ability_explanation = "\
	Turns your hiding abilities on/off\n\
	Whilst on, you will hide under most objects, like tables.\n\
	If you are a diveworm, you will bore into hosts twice as fast whilst not hidden\n\
	"
	/// The layer we are on while hiding
	var/hide_layer = ABOVE_NORMAL_TURF_LAYER

/datum/action/cooldown/borer/toggle_hiding/Activate(mob/living/basic/cortical_borer/user)
	if(user.layer == hide_layer)
		user.layer = initial(user.layer)
		user.balloon_alert(user, "stopped hiding")
		REMOVE_TRAIT(user, TRAIT_IGNORE_ELEVATION, ACTION_TRAIT)
		user.upgrade_flags &= ~BORER_HIDING
		if((user.upgrade_flags & BORER_ENERGIC))
			user.add_movespeed_modifier(/datum/movespeed_modifier/borer_speed_bonus)
	else
		user.layer = hide_layer
		user.balloon_alert(user, "started hiding")
		ADD_TRAIT(user, TRAIT_IGNORE_ELEVATION, ACTION_TRAIT)
		user.upgrade_flags |= BORER_HIDING
		if((user.upgrade_flags & BORER_ENERGIC))
			user.remove_movespeed_modifier(/datum/movespeed_modifier/borer_speed_bonus)

	return ..()
