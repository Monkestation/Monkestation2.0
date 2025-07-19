/*
 * # Umbrellas!
 * This file has code for umbrellas!
 * Umbrellas you can hold, and open and close.
 * Currently not coding for protecting against rain as ???I dont think??? rain exists. Does protect bloodsuckers from Sol, tho.
 * The rest don't and it just for looks.
 */
/obj/item/umbrella
	name = "umbrella"
	desc = "A plain umbrella."
	icon = 'icons/obj/weapons/umbrellas.dmi'
	icon_state = "umbrella"
	inhand_icon_state = "umbrella_closed"
	lefthand_file = 'icons/mob/inhands/weapons/umbrellas_inhand_lh.dmi'
	righthand_file = 'icons/mob/inhands/weapons/umbrellas_inhand_rh.dmi'
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	custom_materials = list(/datum/material/iron= SMALL_MATERIAL_AMOUNT * 0.5)
	attack_verb_continuous = list("bludgeons", "whacks", "disciplines", "pummels")
	attack_verb_simple = list("bludgeon", "whack", "discipline", "pummel")
	drop_sound = 'sound/items/drop/wooden.ogg'
	pickup_sound = 'sound/items/pickup/wooden.ogg'
	hitsound = 'sound/weapons/genhit1.ogg'

	//open umbrella offsets for the inhands
	var/open_x_offset = 2
	var/open_y_offset = 2

	//Whether it's open or not
	var/open = FALSE

	/// The sound effect played when our umbrella is opened
	var/on_sound = 'sound/weapons/batonextend.ogg'
	/// The inhand icon state used when our umbrella is opened.
	var/on_inhand_icon_state = "umbrella_on"

	//greyscale stuff
	greyscale_config = /datum/greyscale_config/umbrella
	greyscale_config_inhand_left = /datum/greyscale_config/umbrella_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/umbrella_inhand_right
	greyscale_colors = "#dddddd"
	/// If the item should be assigned a random color
	var/random_color = TRUE
	/// List of possible random colors
	var/static/list/umbrella_colors = list(
		COLOR_BLUE,
		COLOR_RED,
		COLOR_PINK,
		COLOR_BROWN,
		COLOR_GREEN,
		COLOR_CYAN,
		COLOR_YELLOW,
		COLOR_WHITE
	)
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/umbrella/Initialize(mapload)
	. = ..()
	if(random_color)
		set_greyscale(colors = list(pick(umbrella_colors)))
	AddComponent( \
		/datum/component/transforming, \
		force_on = 7, \
		hitsound_on = "sound/weapons/genhit1.ogg", \
		w_class_on = WEIGHT_CLASS_BULKY, \
		clumsy_check = FALSE, \
		attack_verb_continuous_on = list("swooshes", "whacks", "fwumps"), \
		attack_verb_simple_on = list("swoosh", "whack", "fwump"), \
	)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/obj/item/umbrella/worn_overlays(mutable_appearance/standing, isinhands)
	. = ..()
	if(!isinhands)
		return
	var/mob/holder = loc
	if(open)
		if(ISODD(holder.get_held_index_of_item(src))) //left hand or right hand?
			. += mutable_appearance(lefthand_file, inhand_icon_state + "_BACK", BELOW_MOB_LAYER)
		else
			. += mutable_appearance(righthand_file, inhand_icon_state + "_BACK", BELOW_MOB_LAYER)


/obj/item/umbrella/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER
	inhand_icon_state = active ? on_inhand_icon_state : inhand_icon_state
	open = active
	if(user)
		balloon_alert(user, active ? "opened" : "closed")
	if(active)
		ADD_TRAIT(user, TRAIT_SHADED, REF(src))
	else
		REMOVE_TRAIT(user, TRAIT_SHADED, REF(src))
	playsound(src, on_sound, 50, TRUE)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/umbrella/pickup(mob/user)
	. = ..()
	RegisterSignal(user, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_dir_change))
	if(open)
		ADD_TRAIT(user, TRAIT_SHADED, REF(src))

/obj/item/umbrella/dropped(mob/user, silent)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_SHADED, REF(src))
	UnregisterSignal(user, COMSIG_ATOM_DIR_CHANGE)

/obj/item/umbrella/proc/on_dir_change(mob/living/carbon/owner, olddir, newdir)
	SIGNAL_HANDLER
	owner.update_held_items()

/obj/item/umbrella/get_worn_offsets(isinhands)
	. = ..()
	var/mob/holder = loc
	if(open)
		.[2] += open_y_offset
		switch(loc.dir)
			if(NORTH)
				.[1] += ISODD(holder.get_held_index_of_item(src)) ? -open_x_offset : open_x_offset
			if(SOUTH)
				.[1] += ISODD(holder.get_held_index_of_item(src)) ? open_x_offset : -open_x_offset
			if(EAST)
				.[1] -= open_x_offset
			if(WEST)
				.[1] += open_x_offset



//other umbrellas

/obj/item/umbrella/parasol
	name = "parasol"
	desc = "A black laced parsol, how intricate."
	icon_state = "parasol"
	inhand_icon_state = "parasol_closed"
	on_inhand_icon_state = "parasol_on"
	random_color = FALSE
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
