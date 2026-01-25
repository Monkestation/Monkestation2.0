/datum/discipline/auspex
	name = "Auspex"
	discipline_explanation = "Auspex is a Discipline that grants vampires supernatural senses, letting them peer far further and see things best left unseen.\n\
		The malkavians especially have a bond with it, being seers at heart."
	icon_state = "auspex"

	// Lists of abilities granted per level
	level_1 = list(/datum/action/cooldown/vampire/auspex)
	level_2 = list(/datum/action/cooldown/vampire/auspex/two)
	level_3 = list(/datum/action/cooldown/vampire/auspex/three)
	level_4 = list(/datum/action/cooldown/vampire/auspex/four)

/datum/discipline/auspex/malkavian
	level_5 = list(/datum/action/cooldown/vampire/auspex/four, /datum/action/cooldown/vampire/astral_projection)

/**
 *	# Auspex
 *
 *	Level 1 - Raise sightrange by 2, project sight 2 tiles ahead.
 *	Level 2 - Raise sightrange by 3, project sight 4 tiles ahead. Meson Vision
 *	Level 3 - Raise sightrange by 5, project sight 6 tiles ahead.
 *	Level 4 - Raise sightrange by 7, project sight 8 tiles ahead. Xray Vision
 *	Level 5 - For Malkavians: Gain ability to astral project like a wizard.
 */
/datum/action/cooldown/vampire/auspex
	name = "Auspex"
	desc = "Sense the vitae of any creature directly, and use your keen senses to widen your perception."
	button_icon_state = "power_auspex"
	power_explanation = "- Level 1: When Activated, you will see further. \n\
					- Level 2: When Activated, you will see further, and be able to sense walls and the layout of rooms. \n\
					- Level 3: When Activated, You still have meson vision, same as level 3, but even more range. \n\
					- Level 4: When Activated, you will see further, and be able to sense anything in sight, seeing through walls and barriers as if they were glass."
	vampire_power_flags = BP_AM_TOGGLE | BP_AM_STATIC_COOLDOWN
	vampire_check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 50
	constant_vitaecost = 1
	cooldown_time = 10 SECONDS
	var/add_meson = FALSE
	var/add_xray = FALSE
	var/zoom_out_amt = 2
	var/zoom_amt = 6


	var/looking = FALSE
	var/mob/listening_to

/datum/action/cooldown/vampire/auspex/two
	name = "Auspex"
	vitaecost = 40
	constant_vitaecost = 2
	zoom_out_amt = 4
	zoom_amt = 7
	add_meson = TRUE

/datum/action/cooldown/vampire/auspex/three
	name = "Auspex"
	vitaecost = 30
	constant_vitaecost = 3
	zoom_out_amt = 6
	zoom_amt = 8
	add_meson = TRUE

/datum/action/cooldown/vampire/auspex/four
	name = "Auspex"
	vitaecost = 20
	constant_vitaecost = 4
	zoom_out_amt = 10
	zoom_amt = 10
	add_xray = TRUE

/datum/action/cooldown/vampire/auspex/activate_power()
	. = ..()
	if(!looking)
		lookie()

/datum/action/cooldown/vampire/auspex/deactivate_power()
	. = ..()
	if(looking)
		unlooky()

/datum/action/cooldown/vampire/auspex/proc/lookie()
	SIGNAL_HANDLER

	if(!listening_to)
		RegisterSignals(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_LOGOUT), PROC_REF(deactivate_power))
		RegisterSignal(owner, COMSIG_ATOM_POST_DIR_CHANGE, PROC_REF(lookie))
	listening_to = owner
	var/client/client = owner?.client
	if(!client)
		return
	var/_x = 0
	var/_y = 0
	switch(owner.dir)
		if(NORTH)
			_y = zoom_amt
		if(EAST)
			_x = zoom_amt
		if(SOUTH)
			_y = -zoom_amt
		if(WEST)
			_x = -zoom_amt

	client?.change_view(get_zoomed_view(world.view, zoom_out_amt))
	client?.pixel_x = ICON_SIZE_X * _x
	client?.pixel_y = ICON_SIZE_Y * _y
	looking = TRUE

	if(add_meson)
		ADD_TRAIT(owner, TRAIT_MESON_VISION, REF(src))

	if(add_xray)
		ADD_TRAIT(owner, TRAIT_XRAY_VISION, REF(src))

	owner.update_sight()

/datum/action/cooldown/vampire/auspex/proc/unlooky()
	SIGNAL_HANDLER

	if(listening_to)
		UnregisterSignal(listening_to, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_LOGOUT, COMSIG_ATOM_POST_DIR_CHANGE))
		listening_to = null

	looking = FALSE
	owner.remove_traits(list(TRAIT_MESON_VISION, TRAIT_XRAY_VISION), REF(src))
	owner.update_sight()

	// do this last in case weird client shit happens and runtimes
	var/client/client = owner.client
	if(client)
		client?.change_view(CONFIG_GET(string/default_view))
		client?.pixel_x = 0
		client?.pixel_y = 0

/datum/action/cooldown/vampire/auspex/Destroy()
	listening_to = null
	return ..()
