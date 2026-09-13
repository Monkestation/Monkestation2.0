/datum/action/cooldown/borer/toggle_hiding
	name = "Toggle Hiding"
	button_icon_state = "hide"
	var/hidden = FALSE
	ability_explanation = "\
	Turns your hiding abilities on/off\n\
	Whilst on, you will hide under most objects, like tables.\n\
	If you are a diveworm, you will bore into hosts twice as fast whilst not hidden\n\
	"

/datum/action/cooldown/borer/toggle_hiding/Activate(mob/living/basic/cortical_borer/user)
	if(hidden == FALSE)
		user.upgrade_flags |= BORER_HIDING
		owner.balloon_alert(owner, "started hiding")
		owner.plane -= 2 // Its to make the borer move into or out of the WALL_PLANE and its original plane irrespective of level offset
		ADD_TRAIT(owner, TRAIT_IGNORE_ELEVATION, ACTION_TRAIT)
		if((user.upgrade_flags & BORER_ENERGIC))
			user.remove_movespeed_modifier(/datum/movespeed_modifier/borer_speed_bonus)
	else
		user.upgrade_flags &= ~BORER_HIDING
		owner.balloon_alert(owner, "stopped hiding")
		owner.plane += 2
		REMOVE_TRAIT(owner, TRAIT_IGNORE_ELEVATION, ACTION_TRAIT)
		if((user.upgrade_flags & BORER_ENERGIC))
			user.add_movespeed_modifier(/datum/movespeed_modifier/borer_speed_bonus)
	hidden = !hidden
	return ..()
