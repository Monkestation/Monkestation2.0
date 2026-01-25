/datum/action/cooldown/vampire/astral_projection
	name = "Astral Projection"
	desc = "The power of your blood empowers your auspex. Become able to project your consciousness outside your body."
	power_explanation = "When Activated, you will become a ghost.\n\
		Visit anywhere you like, watch anyone you want.\n\
		Talk to the spriits, and know all things."
	active_background_icon_state = "tremere_power_gold_on"
	base_background_icon_state = "tremere_power_gold_off"
	button_icon_state = "power_auspex"
	vampire_power_flags = BP_AM_TOGGLE
	vampire_check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 400
	cooldown_time = 60 SECONDS

/datum/action/cooldown/vampire/astral_projection/activate_power()
	. = ..()
	var/mob/dead/observer/ghost = owner.ghostize(can_reenter_corpse = TRUE)
	ghost.add_atom_colour(COLOR_VOID_PURPLE, ADMIN_COLOUR_PRIORITY)
	ghost.name = "Astral Shade of [ghost.name]"
	deactivate_power()
