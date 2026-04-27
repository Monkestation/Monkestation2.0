/datum/action/cooldown/vampire/astral_projection
	name = "Astral Projection"
	desc = "The power of your blood empowers your auspex. Become able to project your consciousness outside your body."
	power_explanation = "When Activated, you will become a ghost.\n\
		Visit anywhere you like, watch anyone you want.\n\
		Talk to the spriits, and know all things."
	active_background_icon_state = "tremere_power_gold_on"
	base_background_icon_state = "tremere_power_gold_off"
	button_icon_state = "power_astral_projection"
	vampire_power_flags = BP_AM_TOGGLE
	vampire_check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 400
	cooldown_time = 60 SECONDS

/datum/action/cooldown/vampire/astral_projection/activate_power()
	. = ..()
	owner.playsound_local(null, 'sound/vampires/auspex.ogg', 50, TRUE, pressure_affected = FALSE)
	var/mob/dead/observer/ghost = owner.ghostize(can_reenter_corpse = TRUE)
	ADD_TRAIT(ghost, TRAIT_NO_OBSERVE, TRAIT_VAMPIRE)
	ghost.add_atom_colour(COLOR_VOID_PURPLE, ADMIN_COLOUR_PRIORITY)
	var/ghost_name = "Astral Shade of [ghost.name]"
	ghost.name = ghost_name
	ghost.deadchat_name = ghost_name
	ghost.add_filter("astral_projection", 1, outline_filter(size = 1, color = COLOR_BLOOD))
	deactivate_power()
