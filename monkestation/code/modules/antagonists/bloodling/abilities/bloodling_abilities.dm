/datum/action/cooldown/mob_cooldown/bloodling
	name = "debug"
	desc = "Yell at coders if you see this"
	button_icon = 'monkestation/code/modules/antagonists/bloodling/sprites/bloodling_abilities.dmi'
	background_icon = 'monkestation/icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_bloodling"
	/// The biomass cost of the ability
	var/biomass_cost = 0

/datum/action/cooldown/mob_cooldown/bloodling/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	// Basically we only want bloodlings to have this
	if(!istype(owner, /mob/living/basic/bloodling))
		stack_trace("A non-bloodling mob has obtained a bloodling action!")
		return FALSE

	var/mob/living/basic/bloodling/our_mob = owner
	if(our_mob.biomass <= biomass_cost)
		return FALSE

	return TRUE

/datum/action/cooldown/mob_cooldown/bloodling/PreActivate(atom/target)
	if(get_dist(owner, target) > 1)
		return FALSE

	var/mob/living/basic/bloodling/our_mob = owner
	. = ..()
	if(!.)
		return FALSE

	// Since bloodlings evolve it may result in them or their abilities going away
	// so we can just return true here
	if(QDELETED(src) || QDELETED(owner))
		return TRUE

	if(click_to_activate && our_mob.biomass < biomass_cost)
		unset_click_ability(owner, refund_cooldown = FALSE)

	our_mob.add_biomass(-biomass_cost)

	return TRUE

// A non mob version for certain abilities (mainly hide, build, slam, shriek, whiplash)
/datum/action/cooldown/bloodling
	name = "debug"
	desc = "Yell at coders if you see this"
	button_icon = 'monkestation/code/modules/antagonists/bloodling/sprites/bloodling_abilities.dmi'
	background_icon = 'monkestation/code/modules/antagonists/bloodling/sprites/bloodling_abilities.dmi'
	background_icon_state = "button_bg"
	// The biomass cost of the ability
	var/biomass_cost = 0
	// If the spell is free but instead requires a biomass cap
	var/biomass_cap = FALSE

/datum/action/cooldown/bloodling/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	// Basically we only want bloodlings to have this
	if(!istype(owner, /mob/living/basic/bloodling))
		return FALSE
	var/mob/living/basic/bloodling/our_mob = owner
	if(our_mob.biomass <= biomass_cost)
		return FALSE
	// Hardcoded for the bloodling biomass system. So it will not function on non-bloodlings
	return istype(owner, /mob/living/basic/bloodling)

/datum/action/cooldown/bloodling/PreActivate(atom/target)
	var/mob/living/basic/bloodling/our_mob = owner
	. = ..()
	if(!.)
		return FALSE
	// Since bloodlings evolve it may result in them or their abilities going away
	// so we can just return true here
	if(QDELETED(src) || QDELETED(owner))
		return TRUE

	if(biomass_cap)
		return TRUE

	our_mob.add_biomass(-biomass_cost)

	return TRUE
